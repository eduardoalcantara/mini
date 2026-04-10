import { createEditor } from "./components/editor/editor.js";

const mountEl = document.getElementById("editor-mount");

if (!mountEl) {
  console.error("[mini] #editor-mount não encontrado");
} else {
  const view = createEditor(mountEl, "");
  window.__editorView = view;
}
