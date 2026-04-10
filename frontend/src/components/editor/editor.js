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
import { Compartment, EditorState } from "@codemirror/state";
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

const gutterCompartment = new Compartment();
const wrapCompartment = new Compartment();

function gutterExtensions(showLineNumbers) {
  if (!showLineNumbers) {
    return [];
  }
  return [lineNumbers(), highlightActiveLineGutter()];
}

const sharedCore = [
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
      fontFamily: "var(--font-editor-active)",
      fontSize: "var(--text-editor-active)",
      lineHeight: "var(--line-height-editor)",
    },
    ".cm-content": {
      caretColor: "var(--color-accent)",
      fontFamily: "var(--font-editor-active)",
      fontSize: "var(--text-editor-active)",
    },
    ".cm-cursor": { borderLeftColor: "var(--color-accent)" },
    "&.cm-focused .cm-selectionBackground": {
      backgroundColor: "var(--color-selection) !important",
    },
    ".cm-selectionBackground": {
      backgroundColor: "var(--color-selection-inactive) !important",
    },
    ".cm-content ::selection": {
      color: "var(--color-text-on-selection) !important",
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
 * @param {string} slug
 * @returns {string}
 */
export function fontFamilyFromSlug(slug) {
  if (slug === "jetbrains-mono") {
    return 'var(--font-editor-code)';
  }
  return 'var(--font-editor-text)';
}

/**
 * @param {HTMLElement} mountEl
 * @param {object} cfg
 * @param {{ font: string, font_size: number }} fontResult
 */
export function applyChromeToMount(mountEl, cfg, fontResult) {
  if (cfg?.theme) {
    document.documentElement.dataset.theme = cfg.theme;
  }
  const slug = fontResult?.font ?? "eb-garamond";
  const size = fontResult?.font_size ?? cfg?.font_size ?? 16;
  mountEl.style.setProperty("--font-editor-active", fontFamilyFromSlug(slug));
  mountEl.style.setProperty("--text-editor-active", `${size}px`);
}

/**
 * @param {import("@codemirror/view").EditorView} view
 * @param {object} cfg
 */
export function applyEditorConfig(view, cfg) {
  view.dispatch({
    effects: [
      gutterCompartment.reconfigure(gutterExtensions(!!cfg.line_numbers)),
      wrapCompartment.reconfigure(cfg.line_wrap ? EditorView.lineWrapping : []),
    ],
  });
}

/**
 * @param {HTMLElement} parentEl
 * @param {string} [initialContent]
 * @param {object} [cfg]
 * @param {{ font: string, font_size: number } | null} [fontResult]
 */
export function createEditor(parentEl, initialContent = "", cfg = {}, fontResult = null) {
  const lineWrap = cfg.line_wrap !== false;
  const lineNums = cfg.line_numbers !== false;

  const extensions = [
    gutterCompartment.of(gutterExtensions(lineNums)),
    ...sharedCore,
    wrapCompartment.of(lineWrap ? EditorView.lineWrapping : []),
    markdown(),
    editorTheme,
  ];

  const state = EditorState.create({
    doc: initialContent,
    extensions,
  });
  const view = new EditorView({ state, parent: parentEl });

  const fr =
    fontResult ??
    ({
      font: "eb-garamond",
      font_size: cfg.font_size ?? 16,
    });

  const applyAll = (nextCfg, nextFont) => {
    applyChromeToMount(parentEl, nextCfg, nextFont);
    applyEditorConfig(view, nextCfg);
  };

  applyChromeToMount(parentEl, cfg, fr);
  applyEditorConfig(view, cfg);

  return {
    view,
    applyEditorChrome: applyAll,
  };
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
