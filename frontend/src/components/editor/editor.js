import { EditorView, basicSetup } from "codemirror";
import { EditorState } from "@codemirror/state";
import { markdown } from "@codemirror/lang-markdown";

const editorTheme = EditorView.theme(
  {
    "&": {
      height: "100%",
      backgroundColor: "var(--color-bg)",
      color: "var(--color-text)",
      fontFamily: "var(--font-editor-text)",
      fontSize: "var(--text-editor)",
      lineHeight: "var(--line-height-editor)",
    },
    ".cm-content": { caretColor: "var(--color-accent)" },
    ".cm-cursor": { borderLeftColor: "var(--color-accent)" },
    ".cm-focused .cm-selectionBackground, ::selection": {
      backgroundColor: "var(--color-surface-2)",
    },
    ".cm-gutters": {
      backgroundColor: "var(--color-bg)",
      color: "var(--color-text-muted)",
      border: "none",
    },
    ".cm-activeLineGutter": { backgroundColor: "var(--color-surface)" },
    ".cm-activeLine": { backgroundColor: "var(--color-surface)" },
  },
  { dark: true },
);

/**
 * @param {HTMLElement} parentEl
 * @param {string} [initialContent]
 * @returns {import("@codemirror/view").EditorView}
 */
export function createEditor(parentEl, initialContent = "") {
  const state = EditorState.create({
    doc: initialContent,
    extensions: [
      basicSetup,
      markdown(),
      EditorView.lineWrapping,
      editorTheme,
    ],
  });
  return new EditorView({ state, parent: parentEl });
}

/**
 * @param {import("@codemirror/view").EditorView} view
 * @returns {string}
 */
export function getContent(view) {
  return view.state.doc.toString();
}

/**
 * @param {import("@codemirror/view").EditorView} view
 * @param {string} text
 */
export function setContent(view, text) {
  view.dispatch({
    changes: { from: 0, to: view.state.doc.length, insert: text },
  });
}
