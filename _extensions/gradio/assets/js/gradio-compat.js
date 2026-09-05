(() => {
  const script = document.currentScript;
  if (!(script instanceof HTMLScriptElement)) {
    return;
  }

  const requirementsUrl = new URL(
    "runtime-requirements.txt",
    script.src,
  ).href;
  const workerPattern = /^importScripts\("(https:\/\/cdn\.jsdelivr\.net\/npm\/@gradio\/lite@5\.45\.0\/dist\/assets\/webworker-[^"]+\.js)"\);$/;
  const installMarker =
    'await i.add_mock_package("ffmpy","0.3.0"),await E(s,i,r)';
  const NativeBlob = globalThis.Blob;

  // Gradio Lite 5.45.0 resolves both bundled wheels in one micropip call.
  // Load the Pyodide-compatible versions first, then run that frozen worker.
  globalThis.Blob = class extends NativeBlob {
    constructor(parts = [], options = {}) {
      const workerMatch = parts
        .find((part) => typeof part === "string")
        ?.match(workerPattern);

      if (workerMatch) {
        parts = [createWorkerLoader(workerMatch[1])];
        globalThis.Blob = NativeBlob;
      }

      super(parts, options);
    }
  };

  function createWorkerLoader(workerUrl) {
    return `
const pendingEvents = [];
const dedicated = "postMessage" in self;

if (dedicated) {
  self.onmessage = (event) => pendingEvents.push(event);
} else {
  self.onconnect = (event) => pendingEvents.push(event);
}

(async () => {
  const [workerResponse, requirementsResponse] = await Promise.all([
    fetch(${JSON.stringify(workerUrl)}),
    fetch(${JSON.stringify(requirementsUrl)}),
  ]);
  if (!workerResponse.ok || !requirementsResponse.ok) {
    throw new Error("Failed to load the pinned Gradio Lite runtime");
  }

  const source = await workerResponse.text();
  const requirements = (await requirementsResponse.text())
    .split("\\n")
    .map((requirement) => requirement.trim())
    .filter(Boolean);
  const replacement =
    'await i.add_mock_package("ffmpy","0.3.0"),await(async()=>{for(const n of ' +
    JSON.stringify(requirements) +
    ')await E(s,i,[n]);await E(s,i,r)})()';
  const patchedSource = source.replace(
    ${JSON.stringify(installMarker)},
    replacement,
  );
  if (patchedSource === source) {
    throw new Error("The Gradio Lite worker bootstrap has changed");
  }

  const patchedWorkerUrl = URL.createObjectURL(
    new Blob([patchedSource], { type: "text/javascript" }),
  );
  importScripts(patchedWorkerUrl);
  URL.revokeObjectURL(patchedWorkerUrl);
  const handler = dedicated ? self.onmessage : self.onconnect;
  for (const event of pendingEvents) {
    await handler.call(self, event);
  }
})().catch((error) => {
  const message = {
    type: "python-error",
    data: { traceback: error.stack ?? String(error) },
  };
  if (dedicated) {
    self.postMessage(message);
  } else {
    for (const event of pendingEvents) {
      for (const port of event.ports) {
        port.postMessage(message);
      }
    }
  }
});
`;
  }
})();
