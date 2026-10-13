/*
 * 主页头像三幕动画
 */
(function () {
  const stage = document.querySelector(".hero-stage");
  if (!stage) return;

  if ("scrollRestoration" in history) history.scrollRestoration = "manual";
  window.scrollTo(0, 0);

  const CX = 150, CY = 150, LEN = 210, COUNT = 9;
  const SP = LEN / (COUNT - 1);
  const PU = SP / Math.sqrt(3);
  const T_SWITCH = 1200;
  const T_SHRINK = 320;
  const T_DONE = T_SWITCH + T_SHRINK;

  // 缓动函数
  function cubicBezier(x1, y1, x2, y2) {
    return function (t) {
      let u = t;
      for (let i = 0; i < 5; i++) {
        const x = 3*u*(1-u)*(1-u)*x1 + 3*u*u*(1-u)*x2 + u*u*u - t;
        const dx = 3*(1-u)*(1-u)*x1 + 6*u*(1-u)*(x2-x1) + 3*u*u*(1-x2);
        if (Math.abs(dx) < 1e-6) break;
        u -= x / dx;
        u = Math.min(1, Math.max(0, u));
      }
      return 3*u*(1-u)*(1-u)*y1 + 3*u*u*(1-u)*y2 + u*u*u;
    };
  }
  const easeDraw = cubicBezier(0.4, 0.14, 0.3, 1);
  const easeStd = cubicBezier(0.25, 0.1, 0.25, 1);

  function rot2(p, deg, cx, cy) {
    const r = (deg * Math.PI) / 180;
    const dx = p[0] - cx, dy = p[1] - cy;
    return [
      cx + dx * Math.cos(r) - dy * Math.sin(r),
      cy + dx * Math.sin(r) + dy * Math.cos(r),
    ];
  }

  const gridLines = [];
  for (let i = 0; i < COUNT; i++) {
    const x = CX - LEN / 2 + i * SP;
    const rlen = LEN / 2 + Math.min(i, COUNT - 1 - i) * (Math.sqrt(3) / 3) * SP + LEN / 40;
    gridLines.push([x, CY - rlen, x, CY + rlen]);
  }
  for (const ang of [120, 240]) {
    for (let i = 0; i < COUNT; i++) {
      const x = CX - LEN / 2 + i * SP;
      const rlen = LEN / 2 + Math.min(i, COUNT - 1 - i) * (Math.sqrt(3) / 3) * SP + LEN / 40;
      const p1 = rot2([x, CY - rlen], ang, CX, CY);
      const p2 = rot2([x, CY + rlen], ang, CX, CY);
      gridLines.push([p1[0], p1[1], p2[0], p2[1]]);
    }
  }

  // 红色部分
  const redCodes = [
    ["L", -1, -5], ["R", 1, -5], ["L", 1, -5], ["L", 0, -6], ["R", 2, -6],
    ["R", -1, 3], ["L", -2, 4], ["R", -1, 5], ["L", -2, 6], ["R", 0, 6],
    ["L", -1, 5], ["R", 0, 4], ["L", -1, 3], ["R", 1, 5], ["L", 0, 4],
    ["R", 1, 3], ["L", 0, 2], ["R", 1, 1], ["L", 0, 0], ["R", 2, 4],
    ["L", 1, 3], ["R", 2, 2], ["L", 1, 1], ["R", 2, 0],
  ];

  function triOf(code) {
    const [t, a, b] = code;
    const x = a * SP, y = b * PU;
    if (t === "L") {
      return [
        [CX + x, CY + y],
        [CX + x + SP, CY + y - PU],
        [CX + x + SP, CY + y + PU],
      ];
    }
    return [
      [CX + x, CY + y],
      [CX + x - SP, CY + y - PU],
      [CX + x - SP, CY + y + PU],
    ];
  }

  // 2D 预览三角
  const previewTris = [];
  const shuffled = (n, seed) => {
    const arr = [...Array(n).keys()];
    let s = BigInt(seed);
    const next = () => {
      s = (1103515245n * s + 12345n) % 2147483648n;
      return Number(s);
    };
    for (let i = n - 1; i > 0; i--) {
      const j = next() % (i + 1);
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  };
  const shuffleIdx = shuffled(72, 2005);
  for (let gi = 0; gi < 3; gi++) {
    const deg = gi === 0 ? 0 : gi === 1 ? 120 : 240;
    const preCol = gi === 0 ? "#D73A34" : gi === 1 ? "#444FC3" : "#58AC59";
    for (let i = 0; i < redCodes.length; i++) {
      previewTris.push({
        pts: triOf(redCodes[i]).map((p) => rot2(p, deg, CX, CY)),
        col: preCol,
        delay: 0.4 + 0.006 * shuffleIdx[gi * redCodes.length + i],
      });
    }
  }

  // ========== 第三幕：6 个 U 组
  const layers = [...stage.querySelectorAll(".piece-group")].map((el) => ({
    el,
    axis: Number(el.dataset.axis),
    half: Number(el.dataset.half),
  }));

  const FLY_A = 120;
  const EXIT_0 = 300;
  const flyCfg = new Map();
  flyCfg.set(2 * 2 + 0, { order: 0, d: 0 });   // 红上
  flyCfg.set(1 * 2 + 0, { order: 1, d: -20 }); // 绿上
  flyCfg.set(0 * 2 + 0, { order: 2, d: -30 }); // 蓝上
  flyCfg.set(0 * 2 + 1, { order: 3, d: 30 });  // 蓝下
  flyCfg.set(1 * 2 + 1, { order: 4, d: 20 });  // 绿下
  flyCfg.set(2 * 2 + 1, { order: 5, d: 0 });   // 红下

  // 动态飞行参数
  //   flyV     匀速段上飘速度
  //   exitGap  相邻构件完全离场的滚动间隔
  let flyV = 1;
  let exitGap = 100;
  // 最后一个 U 完全飞离视口的滚动位置
  let pieceExitEnd = Infinity;

  function flyDist(t) {
    if (t <= 0) return 0;
    if (t < FLY_A) return (flyV * t * t) / (2 * FLY_A);
    return flyV * (t - FLY_A / 2);
  }
  function flyDistInv(x) {
    if (x <= 0) return 0;
    const xA = (flyV * FLY_A) / 2;
    if (x < xA) return Math.sqrt((2 * FLY_A * x) / flyV);
    return x / flyV + FLY_A / 2;
  }

  function computeFlyStarts() {
    if (!unitPx) return;
    const H = unitPx * 12;
    flyV = Math.max(0.7, H / 420);
    exitGap = Math.round(Math.min(110, Math.max(70, H / 5)));
    let shift = 0;
    for (let pass = 0; pass < 2; pass++) {
      let minStart = Infinity;
      for (const L of layers) {
        const cfg = flyCfg.get(L.axis * 2 + L.half);
        if (!cfg) continue;
        const r = L.el.getBoundingClientRect();
        const top0 = r.top - (L.curY || 0);
        const E = EXIT_0 + shift + cfg.order * exitGap;
        const need = top0 + r.height - 0.35 * E;
        cfg.start = E - flyDistInv(Math.max(0, need)) + cfg.d;
        minStart = Math.min(minStart, cfg.start);
      }
      if (minStart >= 0 || pass === 1) break;
      shift = -minStart;
    }
    pieceExitEnd = Math.max(
      ...[...flyCfg.values()].map((c) => c.exit || 0)
    );
    syncPlaceholder();
  }

  // 计算占位框高度
  function syncPlaceholder() {
    if (!placeholderEl || !socialEl) return;
    const lastCfg = flyCfg.get(2 * 2 + 1);
    if (!lastCfg || lastCfg.start === undefined) return;
    const fade1 = lastCfg.start + FLY_A;
    // 最低六边形相对容器中心的纵向距离
    const ch = socialEl.offsetHeight;
    let maxBottomRel = 0;
    for (const hex of socialEl.querySelectorAll(".social-hex")) {
      maxBottomRel = Math.max(maxBottomRel, hex.offsetTop + hex.offsetHeight / 2 - ch / 2);
    }
    // 容器中心在 --grid-y=0 时的视口位置
    const gridNow = parseFloat(socialEl.style.getPropertyValue("--grid-y")) || 0;
    const sr = socialEl.getBoundingClientRect();
    const containerCenterVp = (sr.top + sr.bottom) / 2 - gridNow;
    const bottomAtFade = containerCenterVp + maxBottomRel - 0.35 * fade1;
    const rootEm = parseFloat(getComputedStyle(document.documentElement).fontSize) || 16;
    const targetHeadingTop = bottomAtFade + 2.5 * rootEm;
    // 占位框之后第一个元素
    const heading = placeholderEl.nextElementSibling;
    if (!heading) return;
    const headingAtFade = heading.getBoundingClientRect().top + (window.scrollY - fade1);
    const nextHeight = Math.max(
      placeholderEl.offsetHeight + (targetHeadingTop - headingAtFade),
      pieceExitEnd + 1
    );
    placeholderEl.style.height = Math.round(nextHeight) + "px";
  }

  let unitPx = 1;
  function measure() {
    const first = layers[0];
    if (first) unitPx = first.el.getBoundingClientRect().height / 12;
  }

  function computeHeroSize() {
    return Math.max(
      Math.min(
        window.innerHeight * 0.5,
        (window.innerHeight - 48) * 0.6316,
        window.innerWidth * 0.84
      ),
      200
    );
  }
  measure();

  function pieceY(axis, half, p) {
    const sceneOff = -p * 0.35;
    const cfg = flyCfg.get(axis * 2 + half);
    let fly = 0;
    if (cfg && cfg.start !== undefined) fly = flyDist(p - cfg.start); // px
    return Math.round(sceneOff - fly);
  }

  // 2.5D 构件淡入时的起始缩放
  const PIECE_SCALE_FROM = 1.2;

  // 更新全部层
  function updatePieces(q) {
    const p = window.scrollY;
    const active = q < 0.999 || p <= pieceExitEnd + 64;
    if (stage.classList.contains("pieces-active") !== active) {
      stage.classList.toggle("pieces-active", active);
    }
    const ps = PIECE_SCALE_FROM + (1 - PIECE_SCALE_FROM) * q;
    const psStr = ps.toFixed(4);
    const qStr = q.toFixed(3);
    const sceneOff = Math.round(-p * 0.35);
    for (const L of layers) {
      const y = pieceY(L.axis, L.half, p);
      L.curY = y;
      if (L.lastY !== y) {
        L.el.style.setProperty("--piece-y", `${y}px`);
        L.lastY = y;
      }
      if (L.lastScale !== psStr) {
        L.el.style.setProperty("--piece-scale", psStr);
        L.lastScale = psStr;
      }
      if (L.lastOpacity !== qStr) {
        L.el.style.opacity = qStr;
        L.lastOpacity = qStr;
      }
    }
    // 背景淡出
    let bgFade = 0;
    const firstCfg = flyCfg.get(2 * 2 + 0);
    const lastCfg = flyCfg.get(2 * 2 + 1);
    if (firstCfg && lastCfg && firstCfg.start !== undefined) {
      const fade0 = firstCfg.start;
      const fade1 = lastCfg.start + FLY_A;
      bgFade = Math.max(0, Math.min(1, (p - fade0) / (fade1 - fade0)));
    }
    const bgA = q * (1 - bgFade);

    const bgAStr = bgA.toFixed(3);
    // 方框部分
    if (frameEl) {
      if (stage.lastY !== sceneOff) {
        stage.style.setProperty("--frame-y", `${sceneOff}px`);
        stage.lastY = sceneOff;
      }
      const svg = frameEl.querySelector("svg");
      if (svg) {
        if (bgFade > 0 && svg.style.animation !== "none") svg.style.animation = "none";
        if (svg.lastOpacity !== bgAStr) {
          svg.style.opacity = bgAStr;
          svg.lastOpacity = bgAStr;
        }
      }
      const tag = frameEl.querySelector(".hero-counter-tag");
      if (tag) {
        if (bgFade > 0 && tag.style.animation !== "none") tag.style.animation = "none";
        if (tag.lastOpacity !== bgAStr) {
          tag.style.opacity = bgAStr;
          tag.lastOpacity = bgAStr;
        }
      }
    }
    // 侧边装饰卡片
    if (sideCards) {
      const retractStr = bgFade.toFixed(3);
      for (const sc of sideCards) {
        if (bgFade > 0 && sc.style.transition !== "none") sc.style.transition = "none";
        if (sc.lastRetract !== retractStr) {
          sc.style.setProperty("--retract", retractStr);
          sc.lastRetract = retractStr;
        }
        if (sc.lastOpacity !== bgAStr) {
          sc.style.opacity = bgAStr;
          sc.lastOpacity = bgAStr;
        }
      }
    }
    // 格点部分
    if (gridEl) {
      if (gridEl.lastY !== sceneOff) {
        gridEl.style.setProperty("--grid-y", `${sceneOff}px`);
        gridEl.lastY = sceneOff;
      }
      if (gridEl.lastScale !== psStr) {
        gridEl.style.setProperty("--piece-scale", psStr);
        gridEl.lastScale = psStr;
      }
      if (gridEl.lastOpacity !== bgAStr) {
        gridEl.style.opacity = bgAStr;
        gridEl.lastOpacity = bgAStr;
      }
    }
    // 六边形社交链接
    if (socialEl) {
      if (socialEl.lastY !== sceneOff) {
        socialEl.style.setProperty("--grid-y", `${sceneOff}px`);
        socialEl.lastY = sceneOff;
      }
      if (socialEl.lastScale !== psStr) {
        socialEl.style.setProperty("--piece-scale", psStr);
        socialEl.lastScale = psStr;
      }
      if (socialEl.lastOpacity !== bgAStr) {
        socialEl.style.opacity = bgAStr;
        socialEl.lastOpacity = bgAStr;
      }
      const vis = bgA <= 0 ? "hidden" : "visible";
      if (socialEl.lastVis !== vis) {
        socialEl.style.visibility = vis;
        socialEl.lastVis = vis;
        if (vis === "visible") startSocialEnter();
      }
    }
  }
  const frameEl = stage.querySelector(".piece-frame");
  const gridEl = stage.querySelector(".piece-grid");
  const socialEl = stage.querySelector(".social-hexes");
  const sideCards = Array.from(stage.querySelectorAll(".piece-frame.side"));
  const placeholderEl = document.querySelector(".home-placeholder");

  // 六边形出场
  const socialHexes = socialEl
    ? Array.from(socialEl.querySelectorAll(".social-hex"))
    : [];
  const socialLinePolys = socialEl
    ? Array.from(socialEl.querySelectorAll(".social-hex-lines polygon"))
    : [];
  const HEX_GRID_CENTERS = [
    [-4, 14], [-2, 14], [0, 14], [2, 14], [4, 14],
    [-5, 17], [-3, 17], [-1, 17], [1, 17], [3, 17], [5, 17],
  ];
  const HEX_ORIGIN = [0, 14];
  const hexScreenXY = (m, n) => [
    (m - HEX_ORIGIN[0]) * (Math.sqrt(3) / 2),
    (n - HEX_ORIGIN[1]) / 2,
  ];
  const hexOrder = socialHexes
    .map((_, i) => i)
    .sort((a, b) => {
      const [ax, ay] = hexScreenXY(
        HEX_GRID_CENTERS[a][0], HEX_GRID_CENTERS[a][1]
      );
      const [bx, by] = hexScreenXY(
        HEX_GRID_CENTERS[b][0], HEX_GRID_CENTERS[b][1]
      );
      const da = ax * ax + ay * ay;
      const db = bx * bx + by * by;
      return da - db || a - b;
    });
  const HEX_ENTER_MS = 420;
  const HEX_STEP_MS = 27.5;
  socialHexes.forEach((el) => {
    el.style.opacity = "0";
    el.style.transform = "translate(-50%, -50%) scale(0.82)";
  });
  socialLinePolys.forEach((poly) => {
    poly.style.opacity = "0";
  });
  let hexEnterStarted = false;
  function startSocialEnter() {
    if (hexEnterStarted) return;
    hexEnterStarted = true;
    hexOrder.forEach((idx, rank) => {
      const el = socialHexes[idx];
      const poly = socialLinePolys[idx];
      const delay = rank * HEX_STEP_MS;
      el.style.transition =
        `transform ${HEX_ENTER_MS}ms cubic-bezier(0.22, 1, 0.36, 1) ${delay}ms, ` +
        `opacity ${HEX_ENTER_MS}ms ease ${delay}ms`;
      if (poly) {
        poly.style.transition = `opacity ${HEX_ENTER_MS}ms ease ${delay}ms`;
      }
    });
    requestAnimationFrame(() => {
      hexOrder.forEach((idx) => {
        socialHexes[idx].style.transform = "translate(-50%, -50%) scale(1)";
        socialHexes[idx].style.opacity = "1";
        if (socialLinePolys[idx]) socialLinePolys[idx].style.opacity = "1";
      });
    });
  }

  updatePieces(0);

  // 卡片轮廓
  function bindCardOutline(box, insetRatio) {
    if (!box) return;
    const svg = box.querySelector(".hc-outline");
    const path = box.querySelector(".hc-outline-path");
    const tag = box.querySelector(".hero-counter-tag");
    if (!svg || !path || !tag) return;
    const layout = () => {
      tag.style.left = "";
      tag.style.top = "";
      const W = box.offsetWidth;
      const H = box.offsetHeight;
      const i = Math.round(W * insetRatio);
      const tl = Math.round(tag.offsetLeft);
      const tt = Math.round(tag.offsetTop);
      const tw = tag.offsetWidth;
      if (!W || !H || !tw) return;
      tag.style.left = `${tl}px`;
      tag.style.top = `${tt}px`;
      svg.setAttribute("viewBox", `0 0 ${W} ${H}`);
      path.setAttribute(
        "d",
        `M ${tl} ${i} L ${tl} ${tt} L ${tl + tw} ${tt} L ${tl + tw} ${i} ` +
          `L ${W - i} ${i} L ${W - i} ${H - i} L ${i} ${H - i} L ${i} ${i} Z`
      );
    };
    layout();
    window.addEventListener("resize", layout);
    // 等宽字体加载完成后标签宽度可能变化
    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(layout);
    }
  }
  bindCardOutline(frameEl, 0.1);

  // 空侧边卡片轮廓
  function bindEmptyCardOutline(box, insetRatio) {
    if (!box) return;
    const svg = box.querySelector(".hc-outline");
    const path = box.querySelector(".hc-outline-path");
    if (!svg || !path) return;
    const layout = () => {
      const W = box.offsetWidth;
      const H = box.offsetHeight;
      if (!W || !H) return;
      const i = Math.round(W * insetRatio);
      svg.setAttribute("viewBox", `0 0 ${W} ${H}`);
      path.setAttribute("d", `M ${i} ${i} L ${W - i} ${i} L ${W - i} ${H - i} L ${i} ${H - i} Z`);
    };
    layout();
    window.addEventListener("resize", layout);
  }

  // 侧边卡片布局
  function layoutSideCards() {
    const frameSize = frameEl.offsetWidth;
    if (!frameSize) return;
    const step = frameSize * 0.22;
    const specs = [
      { idx: 1, scale: 0.82 },
      { idx: 2, scale: 0.66 },
      { idx: 3, scale: 0.52 },
      { idx: 4, scale: 0.42 },
      { idx: 5, scale: 0.34 },
    ];
    for (const s of specs) {
      for (const side of ["left", "right"]) {
        const el = stage.querySelector(`.piece-frame.side.${side}[data-idx="${s.idx}"]`);
        if (!el) continue;
        const x = step * s.idx * (side === "left" ? -1 : 1);
        el.style.setProperty("--card-x", `${x}px`);
        el.style.setProperty("--card-scale", s.scale);
      }
    }
  }

  for (const sc of sideCards) {
    bindEmptyCardOutline(sc, 0.1);
  }
  layoutSideCards();
  window.addEventListener("resize", layoutSideCards);

  function run2D(onDone) {
    const overlay = document.createElement("canvas");
    overlay.className = "hero-2d-overlay";
    document.body.appendChild(overlay);
    const octx = overlay.getContext("2d");

    // 禁滚动
    const root = document.documentElement;
    const prevOverflow = root.style.overflow;
    root.style.overflow = "hidden";

    const t0 = performance.now();
    let done = false;

    // 统一收尾
    function finish() {
      if (done) return;
      done = true;
      clearTimeout(watchdog);
      root.style.overflow = prevOverflow;
      overlay.remove();
      stage.classList.add("frame-on");
      updatePieces(1);
      measure();
      computeFlyStarts();
      updatePieces(1);
      onDone();
    }
    const watchdog = setTimeout(finish, 3000);

    function frame() {
      const t = performance.now() - t0;

      // overlay 尺寸
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      const rect = overlay.getBoundingClientRect();
      const ow = rect.width;
      const oh = rect.height;
      if (overlay.width !== Math.round(ow * dpr) || overlay.height !== Math.round(oh * dpr)) {
        overlay.width = Math.round(ow * dpr);
        overlay.height = Math.round(oh * dpr);
      }
      octx.setTransform(dpr, 0, 0, dpr, 0, 0);

      // 第三幕：2D 与 2.5D 做透明度交接
      const q = t < T_SWITCH ? 0 : easeStd(Math.min(1, (t - T_SWITCH) / T_SHRINK));
      const lineAlpha = 1 - q;
      const overlayAlpha = 1 - q;

      // 方框随 2D 淡出而显示
      if (t >= T_SWITCH) stage.classList.add("frame-on");

      // 背景
      octx.clearRect(0, 0, ow, oh);
      octx.globalAlpha = overlayAlpha;
      octx.fillStyle = getComputedStyle(document.body).backgroundColor;
      octx.fillRect(0, 0, ow, oh);

      // 坐标映射：viewBox 300 中心对准 overlay 中心
      const heroSize = computeHeroSize();
      const k = heroSize / 300;
      const ox = ow / 2 - CX * k;
      const oy = oh / 2 - CY * k;

      // 2D 缩放与 2.5D 缩放逐帧同步
      const ps = PIECE_SCALE_FROM + (1 - PIECE_SCALE_FROM) * q;
      const sc = ps / PIECE_SCALE_FROM;

      octx.save();
      octx.translate(ow / 2, oh / 2);
      octx.scale(sc, sc);
      octx.translate(-ow / 2, -oh / 2);

      // 网格线
      if (lineAlpha > 0.01) {
        const p = easeDraw(Math.min(1, t / 700));
        for (const line of gridLines) {
          const x1 = ox + line[0] * k, y1 = oy + line[1] * k;
          const x2 = ox + line[2] * k, y2 = oy + line[3] * k;
          const g = octx.createLinearGradient(x1, y1, x2, y2);
          g.addColorStop(0, "rgba(128,128,128,0)");
          g.addColorStop(0.3, "rgba(128,128,128,1)");
          g.addColorStop(0.7, "rgba(128,128,128,1)");
          g.addColorStop(1, "rgba(128,128,128,0)");
          octx.strokeStyle = g;
          octx.lineWidth = Math.max(0.5, k);
          octx.globalAlpha = lineAlpha * overlayAlpha;
          octx.beginPath();
          octx.moveTo(x1, y1);
          octx.lineTo(x1 + (x2 - x1) * p, y1 + (y2 - y1) * p);
          octx.stroke();
        }
      }

      // 三角预览
      for (const tri of previewTris) {
        const a = Math.max(0, Math.min(1, (t / 1000 - tri.delay) / 0.15));
        if (a <= 0) continue;
        octx.fillStyle = tri.col;
        octx.globalAlpha = a * 0.2 * overlayAlpha;
        octx.beginPath();
        octx.moveTo(ox + tri.pts[0][0] * k, oy + tri.pts[0][1] * k);
        for (let j = 1; j < 3; j++) octx.lineTo(ox + tri.pts[j][0] * k, oy + tri.pts[j][1] * k);
        octx.closePath();
        octx.fill();
        octx.globalAlpha = a * overlayAlpha;
        octx.strokeStyle = tri.col;
        octx.lineWidth = Math.max(0.5, 0.9 * k);
        octx.stroke();
      }

      octx.restore();

      // 第三幕切入
      if (t >= T_SWITCH && !done) updatePieces(q);

      if (!done && t >= T_DONE) {
        finish();
        return;
      }

      // 用 setTimeout 驱动
      setTimeout(frame, 16);
    }

    setTimeout(frame, 16);
  }

  // 滚动阶段的统一驱动
  function enableScrollStage() {
    let dirty = true;
    function scheduleUpdate() { dirty = true; }
    function frame() {
      if (dirty) {
        dirty = false;
        updatePieces(1);
      }
      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
    window.addEventListener("scroll", scheduleUpdate, { passive: true });
    window.addEventListener("resize", () => {
      measure();
      computeFlyStarts();
      dirty = true;
    });
    let lastY = window.scrollY;
    setInterval(() => {
      if (window.scrollY !== lastY) {
        lastY = window.scrollY;
        dirty = true;
      }
    }, 100);
  }

  if (stage.querySelector(".piece-guide")) {
    stage.classList.add("frame-on");
    updatePieces(1);
    computeFlyStarts();
    enableScrollStage();
  } else {
    run2D(enableScrollStage);
  }
})();

