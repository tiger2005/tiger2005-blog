/*
 * 主页「文」字傅里叶分针
 */
(function () {
  const canvas = document.querySelector(".glyph-canvas");
  const dataEl = document.getElementById("glyph-fourier-data");
  if (!canvas || !dataEl) return;

  let data;
  try {
    data = JSON.parse(dataEl.textContent);
  } catch (err) {
    return;
  }
  const raw = (data.vectors || []).map((v) => ({ f: v[0], re: v[1], im: v[2] }));
  if (raw.length === 0) return;

  const dc = raw.find((v) => v.f === 0) || { f: 0, re: 0, im: 0 };
  const terms = [dc].concat(
    raw.filter((v) => v.f !== 0).sort((a, b) =>
      (b.re * b.re + b.im * b.im) - (a.re * a.re + a.im * a.im)
    )
  );

  const PERIOD_MS = 60000;
  const PATH_STEPS = 2048;
  const BASE_ALPHA = 0.16;
  const FADE_P = 1;
  const BUCKETS = 30;
  const CIRCLE_TERMS = 140;
  const SCALE = 0.44;

  const ctx = canvas.getContext("2d");
  let cssSize = 0;
  let dpr = 1;
  let glyphPath = []; // 预计算完整字形

  // t 处逐级求和
  function chainAt(t) {
    const ang0 = 2 * Math.PI * t;
    let x = 0, y = 0;
    const pts = [];
    for (const v of terms) {
      pts.push([x, y]);
      const a = ang0 * v.f;
      x += v.re * Math.cos(a) - v.im * Math.sin(a);
      y += v.re * Math.sin(a) + v.im * Math.cos(a);
    }
    pts.push([x, y]);
    return pts;
  }

  function toPx(p) {
    return [
      canvas.width / 2 + p[0] * SCALE * cssSize * dpr,
      canvas.height / 2 + p[1] * SCALE * cssSize * dpr,
    ];
  }

  function cssVar(name) {
    return getComputedStyle(canvas).getPropertyValue(name).trim();
  }

  function resize() {
    const rect = canvas.getBoundingClientRect();
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    cssSize = Math.max(1, Math.min(rect.width, rect.height));
    canvas.width = Math.round(cssSize * dpr);
    canvas.height = Math.round(cssSize * dpr);
    // 预先完整重建字形
    glyphPath = [];
    for (let i = 0; i < PATH_STEPS; i++) {
      glyphPath.push(toPx(chainAt(i / PATH_STEPS).at(-1)));
    }
    glyphPath.push(glyphPath[0]);
  }
  resize();
  if ("ResizeObserver" in window) {
    new ResizeObserver(resize).observe(canvas);
  } else {
    window.addEventListener("resize", resize);
  }

  function beginInk(widthScale) {
    ctx.lineJoin = "round";
    ctx.lineCap = "butt";
    ctx.lineWidth = Math.max(1, 1.6 * dpr * (widthScale || 1));
  }

  function strokeGlyph(pts, alpha, start, end, ink) {
    if (end - start < 1) return;
    ctx.globalAlpha = alpha;
    ctx.strokeStyle = ink;
    ctx.beginPath();
    ctx.moveTo(pts[start][0], pts[start][1]);
    for (let i = start + 1; i <= end; i++) ctx.lineTo(pts[i][0], pts[i][1]);
    ctx.stroke();
  }

  function bucketAlpha(bi) {
    const ageFrac = (bi + 0.5) / BUCKETS;
    return BASE_ALPHA + (1 - BASE_ALPHA) * Math.pow(1 - ageFrac, 1.8);
  }

  function strokePoints(points, alpha, ink) {
    if (points.length < 2) return;
    ctx.globalAlpha = alpha;
    ctx.strokeStyle = ink;
    ctx.beginPath();
    ctx.moveTo(points[0][0], points[0][1]);
    for (let i = 1; i < points.length; i++) ctx.lineTo(points[i][0], points[i][1]);
    ctx.stroke();
  }

  function drawGlyph(phase, ink) {
    beginInk(1);
    // 底字
    strokeGlyph(glyphPath, BASE_ALPHA, 0, glyphPath.length - 1, ink);

    // 提亮部分
    const S = PATH_STEPS;
    const tip = Math.min(S - 1, Math.floor(phase * S));
    const ageOf = (i) => {
      let a = phase - i / S;
      if (a < 0) a += 1;
      return a;
    };

    let runBi = -1;
    let run = [];
    function flush() {
      strokePoints(run, bucketAlpha(runBi), ink);
      run = [];
    }
    for (let p = 0; p < S; p++) {
      const i = (tip + 1 + p) % S;
      const age = ageOf(i);
      if (age >= FADE_P) {
        if (runBi !== -1) flush();
        runBi = -1;
        continue;
      }
      const bi = Math.min(BUCKETS - 1, Math.floor((age / FADE_P) * BUCKETS));
      if (bi !== runBi) {
        if (runBi !== -1) flush();
        runBi = bi;
        if (p > 0 && ageOf((tip + p) % S) < FADE_P) {
          run.push(glyphPath[(tip + p) % S]);
        }
      }
      run.push(glyphPath[i]);
    }
    if (runBi !== -1) flush();
    ctx.globalAlpha = 1;
  }

  function drawChain(pxPts, blues) {
    const tip = pxPts[pxPts.length - 1];
    ctx.save();

    // 圆
    ctx.strokeStyle = blues.dim;
    ctx.lineWidth = Math.max(0.5, 0.6 * dpr);
    const n = Math.min(CIRCLE_TERMS + 1, pxPts.length - 1);
    for (let i = 0; i < n; i++) {
      const r = Math.hypot(pxPts[i + 1][0] - pxPts[i][0], pxPts[i + 1][1] - pxPts[i][1]);
      if (r < 0.5) continue;
      ctx.beginPath();
      ctx.arc(pxPts[i][0], pxPts[i][1], r, 0, 2 * Math.PI);
      ctx.stroke();
    }

    // 半径连杆
    ctx.strokeStyle = blues.mid;
    ctx.lineWidth = Math.max(0.75, 0.9 * dpr);
    ctx.beginPath();
    ctx.moveTo(pxPts[0][0], pxPts[0][1]);
    for (let i = 1; i < pxPts.length; i++) ctx.lineTo(pxPts[i][0], pxPts[i][1]);
    ctx.stroke();

    // 笔尖
    ctx.fillStyle = blues.strong;
    ctx.beginPath();
    ctx.arc(tip[0], tip[1], 3.2 * dpr, 0, 2 * Math.PI);
    ctx.fill();
    ctx.restore();
  }

  function frame() {
    const now = Date.now();
    const phase = (now % PERIOD_MS) / PERIOD_MS;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawGlyph(phase, cssVar("--text-primary"));
    drawChain(chainAt(phase).map(toPx), {
      dim: cssVar("--glyph-blue-dim"),
      mid: cssVar("--glyph-blue-mid"),
      strong: cssVar("--glyph-blue-strong"),
    });
  }

  const reduced = window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  if (reduced) {
    beginInk(1);
    strokeGlyph(glyphPath, 1, 0, glyphPath.length - 1, cssVar("--text-primary"));
    ctx.globalAlpha = 1;
  } else {
    let running = false;
    let rafId = 0;
    function loop() {
      frame();
      rafId = requestAnimationFrame(loop);
    }
    function start() {
      if (running) return;
      running = true;
      rafId = requestAnimationFrame(loop);
    }
    function stop() {
      running = false;
      cancelAnimationFrame(rafId);
    }

    if ("IntersectionObserver" in window) {
      const io = new IntersectionObserver((entries) => {
        if (entries.some((en) => en.isIntersecting)) start();
        else stop();
      }, { threshold: 0.05 });
      io.observe(canvas);
    } else {
      start();
    }
  }
})();
