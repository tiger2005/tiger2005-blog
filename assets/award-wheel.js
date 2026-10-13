(function () {
  const section = document.querySelector(".home-awards");
  if (!section) return;
  const stage = section.querySelector(".award-stage");
  const rotor = section.querySelector(".award-wheel-rotor");
  const track = section.querySelector(".award-dots-track");
  const placeLabel = section.querySelector(".award-wheel-label-place");
  const posLabel = section.querySelector(".award-wheel-label-pos");
  const dateLabel = section.querySelector(".award-wheel-label-date");
  if (!stage || !rotor || !track || !placeLabel || !posLabel || !dateLabel) return;

  const panels = Array.from(stage.querySelectorAll(".award-panel"));
  const segs = Array.from(section.querySelectorAll(".wheel-seg"));
  const dots = Array.from(track.querySelectorAll(".award-dot"));
  const n = panels.length;
  if (!n || n !== segs.length) return;

  function pitch() {
    return dots.length > 1 ? dots[1].offsetLeft - dots[0].offsetLeft : 20;
  }
  function dotHalf() {
    return dots.length ? dots[0].offsetWidth / 2 : 4;
  }
  const step = 360 / n;
  const TURN_MS = 450;
  const AUTO_MS = 5500;
  const MANUAL_GRACE_MS = 8000;
  const reduceMotion =
    window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  let idx = panels.findIndex((p) => p.classList.contains("is-active"));
  if (idx < 0) idx = n - 1;
  let angle = (((-idx * step) % 360) + 360) % 360;
  let dotOffset = n + idx;
  let turning = false;
  let timer = null;
  let hovered = false;
  let focused = false;
  let inView = true;
  let manualHoldUntil = 0;

  function render() {
    for (let i = 0; i < n; i++) {
      panels[i].classList.toggle("is-active", i === idx);
      segs[i].classList.toggle("is-active", i === idx);
    }
    for (let k = 0; k < dots.length; k++) {
      var isActive = (k % n) === idx;
      dots[k].classList.toggle("is-active", isActive);
      dots[k].setAttribute("aria-current", isActive ? "true" : "false");
      dots[k].setAttribute("tabindex", isActive && k >= n && k < 2 * n ? "0" : "-1");
    }
    track.style.transform =
      "translate(-" + (dotOffset * pitch() + dotHalf()) + "px, -50%)";
    placeLabel.textContent = panels[idx].getAttribute("data-place-en") || "";
    posLabel.textContent = "No. " + (idx + 1);
    dateLabel.textContent = panels[idx].getAttribute("data-date-num") || "";
    rotor.style.transform = "rotate(" + angle + "deg)";
  }

  function go(delta, manual) {
    if (turning) return;
    turning = true;
    idx = (idx + delta + n) % n;
    dotOffset += delta;
    angle -= delta * step;
    render();
    if (manual) manualHoldUntil = Date.now() + MANUAL_GRACE_MS;
    window.setTimeout(function () {
      turning = false;
      track.style.transition = "none";
      dotOffset = n + idx;
      track.style.transform =
        "translate(-" + (dotOffset * pitch() + dotHalf()) + "px, -50%)";
      track.getBoundingClientRect();
      track.style.transition = "";
    }, TURN_MS);
    schedule();
  }

  function autoAllowed() {
    if (reduceMotion || document.hidden || !inView) return false;
    if (hovered || focused) return false;
    if (Date.now() < manualHoldUntil) return false;
    return true;
  }

  function schedule(delay) {
    if (timer !== null) {
      window.clearTimeout(timer);
      timer = null;
    }
    if (reduceMotion) return;
    const wait =
      delay !== undefined
        ? delay
        : Math.max(AUTO_MS, manualHoldUntil - Date.now());
    timer = window.setTimeout(function tick() {
      timer = null;
      if (autoAllowed()) {
        go(1, false);
      } else {
        schedule(Math.max(1000, manualHoldUntil - Date.now()));
      }
    }, wait);
  }

  track.addEventListener("click", function (e) {
    var dot = e.target.closest(".award-dot");
    if (!dot) return;
    var k = dots.indexOf(dot);
    if (k < 0) return;
    var delta = k - dotOffset;
    if (delta === 0) return;
    go(delta, true);
  });

  section.addEventListener("mouseenter", function () {
    hovered = true;
  });
  section.addEventListener("mouseleave", function () {
    hovered = false;
    schedule();
  });
  section.addEventListener("focusin", function () {
    focused = true;
  });
  section.addEventListener("focusout", function (e) {
    if (e.relatedTarget && section.contains(e.relatedTarget)) return;
    focused = false;
    schedule();
  });

  document.addEventListener("visibilitychange", function () {
    if (document.hidden) {
      if (timer !== null) {
        window.clearTimeout(timer);
        timer = null;
      }
    } else {
      schedule();
    }
  });

  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(
      function (entries) {
        var wasInView = inView;
        inView = entries[0].isIntersecting;
        if (!wasInView && inView) schedule();
      },
      { threshold: 0.2 }
    );
    io.observe(section);
  }

  document.addEventListener("keydown", function (e) {
    var el = e.target;
    if (el && el.closest && el.closest("input, textarea, select, [contenteditable='true']")) return;
    var r = section.getBoundingClientRect();
    if (r.bottom < 0 || r.top > window.innerHeight) return;
    if (e.key === "ArrowLeft") go(-1, true);
    else if (e.key === "ArrowRight") go(1, true);
  });

  let resizeRaf = 0;
  window.addEventListener("resize", function () {
    if (resizeRaf) return;
    resizeRaf = window.requestAnimationFrame(function () {
      resizeRaf = 0;
      track.style.transition = "none";
      track.style.transform =
        "translate(-" + (dotOffset * pitch() + dotHalf()) + "px, -50%)";
      track.getBoundingClientRect();
      track.style.transition = "";
    });
  });

  track.style.transition = "none";
  render();
  track.getBoundingClientRect();
  track.style.transition = "";
  schedule();
})();
