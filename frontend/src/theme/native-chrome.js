import { setWindowBackground, setWindowTitle } from "../bindings/index.js";

/** RGB de fundo por tema (alinhado a tokens.css) */
const THEME_BG = {
  "perplexity-dark": [26, 26, 31],
  "github-light-default": [255, 255, 255],
  "claude-code-light": [250, 249, 245],
  "moleskine-light": [247, 244, 238],
};

/**
 * Sincroniza a cor de fundo nativa da janela com o tema (Windows/WebView).
 * @param {string} themeSlug
 */
export async function syncNativeWindowBackground(themeSlug) {
  const rgb = THEME_BG[themeSlug] ?? THEME_BG["perplexity-dark"];
  const [r, g, b] = rgb;
  await setWindowBackground(r, g, b);
}

/** Título inicial na taskbar (ficheiros: spec futura). */
export async function setAppWindowTitle(title) {
  await setWindowTitle(title);
}
