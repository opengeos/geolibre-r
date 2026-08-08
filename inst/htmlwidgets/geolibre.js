(function () {
  "use strict";

  const instances = new Map();

  function embedUrl(base, mapOnly) {
    const url = new URL(base, window.location.href);
    url.searchParams.set("embed", "1");
    if (mapOnly) url.searchParams.set("maponly", "1");
    return url.toString();
  }

  function createFrame(el, x) {
    const iframe = document.createElement("iframe");
    iframe.className = "geolibre-frame";
    iframe.title = "GeoLibre interactive map";
    iframe.allow = "fullscreen; clipboard-read; clipboard-write; geolocation";
    iframe.allowFullscreen = true;
    iframe.src = embedUrl(x.appUrl, x.mapOnly);
    el.replaceChildren(iframe);
    return iframe;
  }

  HTMLWidgets.widget({
    name: "geolibre",
    type: "output",
    factory: function (el) {
      let iframe = null;
      let project = null;
      let origin = null;
      let ready = false;
      let sequence = 0;

      function postProject() {
        if (!ready || !iframe || !iframe.contentWindow || !project) return;
        iframe.contentWindow.postMessage(
          { type: "geolibre:load-project", project: project, seq: ++sequence },
          origin
        );
      }

      function resizeFrame(width, height) {
        if (!iframe) return;
        iframe.style.width = Math.max(0, width) + "px";
        iframe.style.height = Math.max(0, height) + "px";
      }

      function receive(event) {
        if (!iframe || event.source !== iframe.contentWindow || event.origin !== origin) return;
        const message = event.data;
        if (!message || typeof message !== "object") return;
        if (message.type === "geolibre:ready") {
          ready = true;
          postProject();
        } else if (message.type === "geolibre:state" && message.project) {
          project = message.project;
          if (window.Shiny) {
            Shiny.setInputValue(el.id + "_project", project, { priority: "event" });
          }
        } else if (message.type === "geolibre:error") {
          console.error("[geolibre R]", message.message || "GeoLibre rejected the project");
          if (window.Shiny) {
            Shiny.setInputValue(el.id + "_error", message.message || "Unknown error", { priority: "event" });
          }
        }
      }

      window.addEventListener("message", receive);
      const instance = {
        renderValue: function (x) {
          project = x.project;
          ready = false;
          if (!iframe || iframe.dataset.appUrl !== x.appUrl || iframe.dataset.mapOnly !== String(x.mapOnly)) {
            iframe = createFrame(el, x);
            iframe.dataset.appUrl = x.appUrl;
            iframe.dataset.mapOnly = String(x.mapOnly);
            origin = new URL(x.appUrl, window.location.href).origin;
          } else {
            postProject();
          }
        },
        resize: function (width, height) {
          resizeFrame(width, height);
        },
        updateProject: function (nextProject) {
          project = nextProject;
          postProject();
        }
      };
      instances.set(el.id, instance);
      return instance;
    }
  });

  if (window.Shiny) {
    Shiny.addCustomMessageHandler("geolibre:update", function (message) {
      const instance = instances.get(message.id);
      if (instance) instance.updateProject(message.project);
    });
  } else {
    document.addEventListener("shiny:connected", function () {
      if (!window.Shiny || window.__geolibreHandlerInstalled) return;
      window.__geolibreHandlerInstalled = true;
      Shiny.addCustomMessageHandler("geolibre:update", function (message) {
        const instance = instances.get(message.id);
        if (instance) instance.updateProject(message.project);
      });
    });
  }
})();
