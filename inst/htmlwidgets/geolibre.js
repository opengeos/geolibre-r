(function () {
  "use strict";

  const instances = new Map();

  // Build the embed URL. `embed=1` turns on the project bridge the widget speaks;
  // `layout`, `theme`, and `panels` select the application chrome.
  function embedUrl(base, layout, theme, panels) {
    const url = new URL(base, window.location.href);
    url.searchParams.set("embed", "1");
    if (theme) url.searchParams.set("theme", theme);
    if (panels === "collapsed") url.searchParams.set("panels", "collapsed");
    if (panels === "hidden") url.searchParams.set("panels", "none");
    if (layout === "maponly") {
      url.searchParams.set("maponly", "1");
    } else if (layout !== "full") {
      url.searchParams.set("layout", "embed");
    }
    return url.toString();
  }

  function createFrame(el, x) {
    const iframe = document.createElement("iframe");
    iframe.className = "geolibre-frame";
    iframe.title = "GeoLibre interactive map";
    iframe.allow = "fullscreen; clipboard-read; clipboard-write; geolocation";
    iframe.allowFullscreen = true;
    iframe.src = embedUrl(x.appUrl, x.layout, x.theme, x.panels);
    el.replaceChildren(iframe);
    return iframe;
  }

  function setInput(name, value) {
    if (window.Shiny) {
      Shiny.setInputValue(name, value, { priority: "event" });
    }
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
      // Commands issued before the application signals readiness are held here
      // and flushed on "geolibre:ready", mirroring the first project push. The
      // cap keeps a misbehaving app from growing the queue without limit.
      const pendingCommands = [];
      // Method name by request id, so a reply can report which command it
      // answers without the caller having to track ids itself.
      const inFlight = new Map();

      function post(message) {
        if (!iframe || !iframe.contentWindow) return;
        iframe.contentWindow.postMessage(message, origin);
      }

      function postProject() {
        if (!ready || !project) return;
        post({
          type: "geolibre:load-project",
          project: project,
          seq: ++sequence,
          trustedWidget: true
        });
      }

      function flushCommands() {
        if (!ready) return;
        while (pendingCommands.length) post(pendingCommands.shift());
      }

      function sendCommand(message) {
        const command = {
          type: "geolibre:command",
          requestId: message.requestId,
          method: message.method,
          params: message.params || {}
        };
        inFlight.set(command.requestId, command.method);
        if (ready) {
          post(command);
        } else if (pendingCommands.length < 500) {
          pendingCommands.push(command);
        } else {
          console.warn(
            "[geolibre R] command queue full (500); dropping \"" + command.method + "\""
          );
          inFlight.delete(command.requestId);
        }
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
          flushCommands();
        } else if (message.type === "geolibre:state" && message.project) {
          project = message.project;
          setInput(el.id + "_project", project);
        } else if (message.type === "geolibre:error") {
          const text = message.message || "GeoLibre rejected the project";
          console.error("[geolibre R]", text);
          setInput(el.id + "_error", text);
        } else if (message.type === "geolibre:result") {
          const method = inFlight.get(message.requestId) || null;
          inFlight.delete(message.requestId);
          setInput(el.id + "_result", {
            requestId: message.requestId,
            method: method,
            ok: !!message.ok,
            value: typeof message.value === "undefined" ? null : message.value,
            error: message.error || null
          });
        } else if (message.type === "geolibre:event") {
          setInput(el.id + "_event", {
            event: message.event,
            payload: typeof message.payload === "undefined" ? null : message.payload
          });
        }
      }

      window.addEventListener("message", receive);
      const instance = {
        renderValue: function (x) {
          project = x.project;
          const signature = [x.appUrl, x.layout, x.theme, x.panels].join("|");
          if (!iframe || iframe.dataset.signature !== signature) {
            ready = false;
            pendingCommands.length = 0;
            inFlight.clear();
            iframe = createFrame(el, x);
            iframe.dataset.signature = signature;
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
        },
        sendCommand: sendCommand
      };
      instances.set(el.id, instance);
      return instance;
    }
  });

  function installHandlers() {
    if (window.__geolibreHandlersInstalled) return;
    window.__geolibreHandlersInstalled = true;
    Shiny.addCustomMessageHandler("geolibre:update", function (message) {
      const instance = instances.get(message.id);
      if (instance) instance.updateProject(message.project);
    });
    Shiny.addCustomMessageHandler("geolibre:command", function (message) {
      const instance = instances.get(message.id);
      if (instance) instance.sendCommand(message);
    });
  }

  if (window.Shiny) {
    installHandlers();
  } else {
    document.addEventListener("shiny:connected", function () {
      if (window.Shiny) installHandlers();
    });
  }
})();
