// idea from https://github.com/xiaohongrsx/xiaohongrsx.github.io/commit/58e8b6eac1ee3da2586d16ec965a80e40206a445 
const GISCUS_CLIENT_URL = "https://giscus.app/client.js";
const GISCUS_ORIGIN = "https://giscus.app";
const GISCUS_CONTAINER = ".giscus";
const GISCUS_IFRAME = "iframe.giscus-frame";

const toAbsoluteUrl = (path) => new URL(path, window.location.origin).href;

const THEME_MAP = {
  white: toAbsoluteUrl("/assets/giscus-white.css"),
  "gray-10": toAbsoluteUrl("/assets/giscus-gray-10.css"),
  "gray-90": toAbsoluteUrl("/assets/giscus-gray-90.css"),
  "gray-100": toAbsoluteUrl("/assets/giscus-gray-100.css"),
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

const prefetchThemes = () => {
  for (const href of Object.values(THEME_MAP)) {
    if (document.querySelector('link[rel="prefetch"][href="' + href + '"]')) continue;
    const link = document.createElement("link");
    link.rel = "prefetch";
    link.as = "style";
    link.crossOrigin = "anonymous";
    link.href = href;
    document.head.appendChild(link);
  }
};

const init = () => {
  prefetchThemes();

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

  new MutationObserver((mutations) => {
    for (const m of mutations) {
      if (m.type === "attributes" && m.attributeName === "data-theme") {
        setTheme(getTheme());
        return;
      }
    }
  }).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
  });
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true });
} else {
  init();
}
