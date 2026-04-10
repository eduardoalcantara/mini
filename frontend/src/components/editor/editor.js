import {
  EditorView,
  lineNumbers,
  highlightActiveLineGutter,
  highlightSpecialChars,
  drawSelection,
  dropCursor,
  rectangularSelection,
  crosshairCursor,
  highlightActiveLine,
  keymap,
} from "@codemirror/view";
import { EditorState } from "@codemirror/state";
import {
  history,
  defaultKeymap,
  historyKeymap,
  indentWithTab,
} from "@codemirror/commands";
import {
  indentOnInput,
  bracketMatching,
  syntaxHighlighting,
  defaultHighlightStyle,
} from "@codemirror/language";
import { closeBrackets, closeBracketsKeymap } from "@codemirror/autocomplete";
import { highlightSelectionMatches, searchKeymap } from "@codemirror/search";
import { markdown } from "@codemirror/lang-markdown";

const minimalSetup = [
  lineNumbers(),
  highlightActiveLineGutter(),
  highlightSpecialChars(),
  history(),
  drawSelection(),
  dropCursor(),
  EditorState.allowMultipleSelections.of(true),
  indentOnInput(),
  syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
  bracketMatching(),
  closeBrackets(),
  rectangularSelection(),
  crosshairCursor(),
  highlightActiveLine(),
  highlightSelectionMatches(),
  keymap.of([
    ...closeBracketsKeymap,
    ...defaultKeymap,
    ...searchKeymap,
    ...historyKeymap,
    indentWithTab,
  ]),
];

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
      ...minimalSetup,
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
