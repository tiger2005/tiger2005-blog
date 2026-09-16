const GISCUS_CLIENT_URL = "https://giscus.app/client.js";
const GISCUS_ORIGIN = "https://giscus.app";
const GISCUS_CONTAINER = ".giscus";
const GISCUS_IFRAME = "iframe.giscus-frame";

const THEME_MAP = {
  white: "/assets/giscus-white.css",
  "gray-10": "/assets/giscus-gray-10.css",
  "gray-90": "/assets/giscus-gray-90.css",
  "gray-100": "/assets/giscus-gray-100.css",
};

const getConfig = () => {
  const el = document.getElementById("giscus-config");
  if (!el) return null;
  try {
    return JSON.parse(el.textContent);
  } catch (e) {
    console.warn("[giscus] failed to parse giscus config:", e);
    return null;
  }
};

const validateConfig = (cfg) =>
  cfg &&
  typeof cfg === "object" &&
  ["repo", "repo-id", "category", "category-id"].every(
    (k) => typeof cfg[k] === "string" && cfg[k].trim().length > 0
  );

const getTheme = () => {
  const theme = document.documentElement.getAttribute("data-theme");
  return THEME_MAP[theme] || THEME_MAP["gray-10"];
};

const createScript = (cfg, theme) => {
  const script = document.createElement("script");
  script.src = GISCUS_CLIENT_URL;
  script.async = true;
  script.crossOrigin = "anonymous";

  for (const [key, value] of Object.entries(cfg)) {
    if (key === "theme") continue;
    script.setAttribute("data-" + key, String(value));
  }
  script.setAttribute("data-theme", theme);
  return script;
};

const setTheme = (theme) => {
  const iframe = document.querySelector(GISCUS_IFRAME);
  if (!iframe || !iframe.contentWindow) return;
  iframe.contentWindow.postMessage(
    { giscus: { setConfig: { theme } } },
    GISCUS_ORIGIN
  );
};

const syncGiscusTheme = () => {
  setTheme(getTheme());
};
window.syncGiscusTheme = syncGiscusTheme;

const init = () => {
  const container = document.querySelector(GISCUS_CONTAINER);
  if (!container) return;

  const cfg = getConfig();
  if (!validateConfig(cfg)) {
    console.warn(
      "[giscus] missing repo, repo-id, category or category-id; comments disabled."
    );
    return;
  }

  container.appendChild(createScript(cfg, getTheme()));
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true });
} else {
  init();
}
