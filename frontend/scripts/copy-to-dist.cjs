/* Copia assets estaticos e node_modules para dist/ (embed Wails em producao). */
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const dist = path.join(root, "dist");

fs.mkdirSync(dist, { recursive: true });
fs.copyFileSync(path.join(root, "index.html"), path.join(dist, "index.html"));
fs.cpSync(path.join(root, "src"), path.join(dist, "src"), { recursive: true });

const nmSrc = path.join(root, "node_modules");
const nmDist = path.join(dist, "node_modules");
if (fs.existsSync(nmSrc)) {
  fs.cpSync(nmSrc, nmDist, { recursive: true });
}
