import { createEditor } from "./components/editor/editor.js";
import { initContextMenu } from "./components/ui/context-menu/context-menu.js";
import { getConfig, resolveFont } from "./bindings/index.js";

const mountEl = document.getElementById("editor-mount");

if (!mountEl) {
  console.error("[mini] #editor-mount não encontrado");
} else {
  (async () => {
    const cfg = await getConfig();
    const fontRes = await resolveFont(".md");
    const { view, applyEditorChrome } = createEditor(mountEl, "", cfg, fontRes);
    window.__editorView = view;
    window.__applyEditorChrome = applyEditorChrome;

    document.addEventListener("config-changed", async (e) => {
      const c = e.detail;
      const fr = await resolveFont(".md");
      applyEditorChrome(c, fr);
    });

    initContextMenu({ getEditorView: () => window.__editorView ?? null });
  })().catch((err) => console.error("[mini] falha ao iniciar", err));
}
