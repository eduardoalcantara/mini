import { GetConfig, SetConfig, ResolveFont } from "./wailsjs/go/app/App.js";

export async function getConfig() {
  return GetConfig();
}

export async function setConfig(cfg) {
  return SetConfig(cfg);
}

export async function resolveFont(fileExt) {
  return ResolveFont(fileExt);
}
