import { getConfig, setConfig } from "../../../bindings/index.js";

/** @typedef {{ theme: string, font: string, font_size: number, line_wrap: boolean, line_numbers: boolean }} AppConfig */

let menuEl = null;
let hoverTimer = null;

/**
 * @param {unknown} c
 * @returns {AppConfig}
 */
function normalizeConfig(c) {
  const o = c && typeof c === "object" ? c : {};
  return {
    theme: /** @type {string} */ (o.theme ?? o.Theme ?? "perplexity-dark"),
    font: /** @type {string} */ (o.font ?? o.Font ?? "auto"),
    font_size: Number(o.font_size ?? o.FontSize ?? 16),
    line_wrap: o.line_wrap ?? o.LineWrap ?? true,
    line_numbers: o.line_numbers ?? o.LineNumbers ?? true,
  };
}

/**
 * @param {Partial<AppConfig>} patch
 */
async function patchConfig(patch) {
  const cur = normalizeConfig(await getConfig());
  const next = { ...cur, ...patch };
  await setConfig(next);
  const fresh = normalizeConfig(await getConfig());
  document.dispatchEvent(new CustomEvent("config-changed", { detail: fresh }));
}

function closeMenu() {
  if (menuEl && menuEl.parentNode) {
    menuEl.parentNode.removeChild(menuEl);
  }
  menuEl = null;
}

/**
 * @param {HTMLElement} el
 * @param {number} x
 * @param {number} y
 */
function placeWithinWindow(el, x, y) {
  el.style.left = "0px";
  el.style.top = "0px";
  const w = el.offsetWidth;
  const h = el.offsetHeight;
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  let nx = x;
  let ny = y;
  if (nx + w > vw - 8) {
    nx = vw - w - 8;
  }
  if (ny + h > vh - 8) {
    ny = vh - h - 8;
  }
  el.style.left = `${Math.max(8, nx)}px`;
  el.style.top = `${Math.max(8, ny)}px`;
}

/**
 * @param {HTMLElement} item
 * @param {HTMLElement} sub
 */
function wireSubmenuHover(item, sub) {
  let showT = null;
  item.addEventListener("mouseenter", () => {
    showT = window.setTimeout(() => {
      item.classList.add("context-menu-item--open");
    }, 150);
  });
  item.addEventListener("mouseleave", () => {
    if (showT) {
      window.clearTimeout(showT);
      showT = null;
    }
    window.setTimeout(() => {
      if (!item.matches(":hover") && !sub.matches(":hover")) {
        item.classList.remove("context-menu-item--open");
      }
    }, 120);
  });
  sub.addEventListener("mouseenter", () => {
    item.classList.add("context-menu-item--open");
  });
  sub.addEventListener("mouseleave", () => {
    item.classList.remove("context-menu-item--open");
  });
}

/**
 * @param {object} opts
 * @param {() => import("@codemirror/view").EditorView | null} opts.getEditorView
 */
export function initContextMenu(opts) {
  const getView = opts.getEditorView;

  document.addEventListener(
    "contextmenu",
    async (e) => {
      e.preventDefault();
      closeMenu();

      const cfg = normalizeConfig(await getConfig());
      const inEditor = !!e.target.closest?.(".cm-editor");

      const root = document.createElement("div");
      root.className = "context-menu";
      root.setAttribute("role", "menu");

      if (inEditor) {
        appendEditorBlock(root, getView);
        appendSeparator(root);
      }

      appendFileBlock(root);
      appendSeparator(root);
      await appendSettingsBlock(root, cfg);

      document.body.appendChild(root);
      menuEl = root;
      placeWithinWindow(root, e.clientX, e.clientY);
    },
    true,
  );

  document.addEventListener("click", (e) => {
    if (menuEl && !menuEl.contains(e.target)) {
      closeMenu();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      closeMenu();
    }
  });
}

/**
 * @param {HTMLElement} root
 * @param {() => import("@codemirror/view").EditorView | null} getView
 */
function appendEditorBlock(root, getView) {
  const items = [
    {
      icon: "content_cut",
      label: "Recortar",
      shortcut: "Ctrl+X",
      run: () => {
        const v = getView();
        v?.focus();
        document.execCommand("cut");
      },
    },
    {
      icon: "content_copy",
      label: "Copiar",
      shortcut: "Ctrl+C",
      run: () => {
        const v = getView();
        v?.focus();
        document.execCommand("copy");
      },
    },
    {
      icon: "content_paste",
      label: "Colar",
      shortcut: "Ctrl+V",
      run: () => {
        const v = getView();
        v?.focus();
        document.execCommand("paste");
      },
    },
    { sep: true },
    {
      icon: "select_all",
      label: "Selecionar tudo",
      shortcut: "Ctrl+A",
      run: () => {
        const v = getView();
        v?.focus();
        document.execCommand("selectAll");
      },
    },
  ];

  for (const it of items) {
    if (it.sep) {
      appendSeparator(root);
      continue;
    }
    root.appendChild(
      itemRow(it.icon, it.label, it.shortcut, () => {
        it.run();
        closeMenu();
      }),
    );
  }
}

function appendFileBlock(root) {
  const head = sectionHeader("description", "Arquivo");
  root.appendChild(head);
  const stub = () => closeMenu();
  root.appendChild(itemRow("note_add", "Novo", "Ctrl+N", stub));
  root.appendChild(itemRow("folder_open", "Abrir…", "Ctrl+O", stub));
  root.appendChild(itemRow("save", "Salvar", "Ctrl+S", stub));
  root.appendChild(itemRow("save_as", "Salvar como…", "Ctrl+Shift+S", stub));
}

/**
 * @param {HTMLElement} root
 * @param {AppConfig} cfg
 */
async function appendSettingsBlock(root, cfg) {
  const head = sectionHeader("settings", "Configurações");
  root.appendChild(head);

  const themeItem = submenuParent("palette", "Tema", "›");
  const themeSub = document.createElement("div");
  themeSub.className = "context-submenu";
  const themes = [
    ["perplexity-dark", "Perplexity Dark"],
    ["github-light-default", "GitHub Light Default"],
    ["claude-code-light", "Claude Code Light"],
    ["moleskine-light", "Moleskine Light"],
  ];
  for (const [id, label] of themes) {
    themeSub.appendChild(
      checkableRow(label, cfg.theme === id, async () => {
        await patchConfig({ theme: id });
        closeMenu();
      }),
    );
  }
  themeSub.appendChild(sep());
  themeSub.appendChild(itemRow("add", "Novo tema…", "", () => closeMenu()));
  themeSub.appendChild(itemRow("upload", "Importar tema…", "", () => closeMenu()));
  themeItem.appendChild(themeSub);
  root.appendChild(themeItem);
  wireSubmenuHover(themeItem, themeSub);

  const fontItem = submenuParent("font_download", "Fonte", "›");
  const fontSub = document.createElement("div");
  fontSub.className = "context-submenu";
  const fonts = [
    ["auto", "De acordo com o tipo de arquivo"],
    ["eb-garamond", "EB Garamond"],
    ["jetbrains-mono", "JetBrains Mono"],
  ];
  for (const [id, label] of fonts) {
    fontSub.appendChild(
      checkableRow(label, cfg.font === id, async () => {
        await patchConfig({ font: id });
        closeMenu();
      }),
    );
  }
  fontSub.appendChild(sep());
  fontSub.appendChild(itemRow("more_horiz", "Outra…", "", () => closeMenu()));
  fontItem.appendChild(fontSub);
  root.appendChild(fontItem);
  wireSubmenuHover(fontItem, fontSub);

  const sizeItem = submenuParent("format_size", "Tamanho da fonte", "›");
  const sizeSub = document.createElement("div");
  sizeSub.className = "context-submenu";
  for (let s = 10; s <= 18; s++) {
    const n = s;
    sizeSub.appendChild(
      checkableRow(String(n), cfg.font_size === n, async () => {
        await patchConfig({ font_size: n });
        closeMenu();
      }),
    );
  }
  sizeItem.appendChild(sizeSub);
  root.appendChild(sizeItem);
  wireSubmenuHover(sizeItem, sizeSub);

  const wrapItem = submenuParent("wrap_text", "Quebra de linha", "›");
  const wrapSub = document.createElement("div");
  wrapSub.className = "context-submenu";
  wrapSub.appendChild(
    checkableRow("Quebrar linha", cfg.line_wrap === true, async () => {
      await patchConfig({ line_wrap: true });
      closeMenu();
    }),
  );
  wrapSub.appendChild(
    checkableRow("Não quebrar linha", cfg.line_wrap === false, async () => {
      await patchConfig({ line_wrap: false });
      closeMenu();
    }),
  );
  wrapItem.appendChild(wrapSub);
  root.appendChild(wrapItem);
  wireSubmenuHover(wrapItem, wrapSub);

  const lnItem = submenuParent("numbers", "Números de linha", "›");
  const lnSub = document.createElement("div");
  lnSub.className = "context-submenu";
  lnSub.appendChild(
    checkableRow("Visível", cfg.line_numbers === true, async () => {
      await patchConfig({ line_numbers: true });
      closeMenu();
    }),
  );
  lnSub.appendChild(
    checkableRow("Invisível", cfg.line_numbers === false, async () => {
      await patchConfig({ line_numbers: false });
      closeMenu();
    }),
  );
  lnItem.appendChild(lnSub);
  root.appendChild(lnItem);
  wireSubmenuHover(lnItem, lnSub);
}

function sectionHeader(icon, label) {
  const d = document.createElement("div");
  d.className = "context-menu-item";
  d.style.fontWeight = "600";
  d.style.cursor = "default";
  d.innerHTML = `<span class="icon">${icon}</span><span class="context-menu-item__label">${label}</span>`;
  d.addEventListener("click", (e) => e.stopPropagation());
  return d;
}

function submenuParent(icon, label, arrow) {
  const d = document.createElement("div");
  d.className = "context-menu-item context-menu-item--has-submenu";
  d.innerHTML = `<span class="icon">${icon}</span><span class="context-menu-item__label">${label}</span><span class="context-menu-item__shortcut"></span><span class="context-menu-item__arrow">${arrow}</span>`;
  return d;
}

function sep() {
  const s = document.createElement("div");
  s.className = "context-menu-separator";
  return s;
}

function appendSeparator(root) {
  root.appendChild(sep());
}

/**
 * @param {string} iconName
 * @param {string} label
 * @param {string} shortcut
 * @param {() => void} onClick
 */
function itemRow(iconName, label, shortcut, onClick) {
  const d = document.createElement("div");
  d.className = "context-menu-item";
  d.innerHTML = `<span class="icon">${iconName}</span><span class="context-menu-item__label">${label}</span><span class="context-menu-item__shortcut">${shortcut}</span>`;
  d.addEventListener("click", (e) => {
    e.stopPropagation();
    onClick();
  });
  return d;
}

/**
 * @param {string} label
 * @param {boolean} checked
 * @param {() => void | Promise<void>} onClick
 */
function checkableRow(label, checked, onClick) {
  const d = document.createElement("div");
  d.className = "context-menu-item" + (checked ? " context-menu-item--checked" : "");
  d.innerHTML = `<span class="icon"></span><span class="context-menu-item__label">${label}</span>`;
  d.addEventListener("click", async (e) => {
    e.stopPropagation();
    await onClick();
  });
  return d;
}
