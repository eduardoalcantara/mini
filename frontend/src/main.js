import { createEditor } from "./components/editor/editor.js";
import { initContextMenu } from "./components/ui/context-menu/context-menu.js";
import { getConfig, resolveFont } from "./bindings/index.js";
import {
  setAppWindowTitle,
  syncNativeWindowBackground,
} from "./theme/native-chrome.js";

const mountEl = document.getElementById("editor-mount");

if (!mountEl) {
  console.error("[mini] #editor-mount não encontrado");
} else {
  (async () => {
    const cfg = await getConfig();
    await setAppWindowTitle("Mini");
    await syncNativeWindowBackground(cfg.theme ?? "perplexity-dark");
    const fontRes = await resolveFont(".md");
    const { view, applyEditorChrome } = createEditor(mountEl, "", cfg, fontRes);
    window.__editorView = view;
    window.__applyEditorChrome = applyEditorChrome;

    document.addEventListener("config-changed", async (e) => {
      const c = e.detail;
      await syncNativeWindowBackground(c.theme ?? "perplexity-dark");
      const fr = await resolveFont(".md");
      applyEditorChrome(c, fr);
    });

    initContextMenu({ getEditorView: () => window.__editorView ?? null });
  })().catch((err) => console.error("[mini] falha ao iniciar", err));
}
