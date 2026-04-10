import { setWindowBackground, setWindowTitle, setWindowsTheme } from "../bindings/index.js";

/** RGB de fundo por tema (alinhado a tokens.css) */
const THEME_BG = {
  "perplexity-dark": [26, 26, 31],
  "github-light-default": [255, 255, 255],
  "claude-code-light": [250, 249, 245],
  "moleskine-light": [247, 244, 238],
};

/**
 * @param {string} themeSlug
 * @returns {boolean}
 */
export function isLightTheme(themeSlug) {
  const t = themeSlug ?? "";
  return t.includes("light") || t === "github-light-default";
}

/**
 * Sincroniza cor de fundo da janela + tema do chrome nativo Windows (barra de título).
 * @param {string} themeSlug
 */
export async function syncNativeWindowChrome(themeSlug) {
  const slug = themeSlug ?? "perplexity-dark";
  const rgb = THEME_BG[slug] ?? THEME_BG["perplexity-dark"];
  const [r, g, b] = rgb;
  await setWindowBackground(r, g, b);
  await setWindowsTheme(isLightTheme(slug));
}

/** Título inicial na taskbar (ficheiros: spec futura). */
export async function setAppWindowTitle(title) {
  await setWindowTitle(title);
}
