import {
  GetConfig,
  SetConfig,
  ResolveFont,
  SetWindowBackground,
  SetWindowTitle,
} from "./wailsjs/go/app/App.js";

export async function getConfig() {
  return GetConfig();
}

export async function setConfig(cfg) {
  return SetConfig(cfg);
}

export async function resolveFont(fileExt) {
  return ResolveFont(fileExt);
}

export function setWindowBackground(r, g, b) {
  return SetWindowBackground(r, g, b);
}

export function setWindowTitle(title) {
  return SetWindowTitle(title);
}
