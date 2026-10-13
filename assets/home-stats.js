(function () {
  var spans = document.querySelectorAll(".home-vercount-line span");
  if (!spans.length) return;

  var DURATION = 700;
  var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var hasIO = "IntersectionObserver" in window;

  function animate(span, target) {
    if (reduced || target <= 0) {
      span.textContent = String(target);
      return;
    }
    var start = null;
    function frame(ts) {
      if (start === null) start = ts;
      var t = Math.min(1, (ts - start) / DURATION);
      var e = 1 - Math.pow(1 - t, 3);
      span.textContent = String(Math.round(target * e));
      if (t < 1) window.requestAnimationFrame(frame);
    }
    span.textContent = "0";
    window.requestAnimationFrame(frame);
  }

  spans.forEach(function (span) {
    var value = null;
    var seen = false;
    var done = false;

    function maybeStart() {
      if (done || value === null || !seen) return;
      done = true;
      animate(span, value);
    }

    var initial = span.textContent.trim();
    if (/^\d+$/.test(initial)) {
      value = parseInt(initial, 10);
    } else {
      var mo = new MutationObserver(function () {
        var text = span.textContent.trim();
        if (/^\d+$/.test(text)) {
          value = parseInt(text, 10);
          mo.disconnect();
          maybeStart();
        }
      });
      mo.observe(span, { childList: true, characterData: true, subtree: true });
    }

    if (hasIO) {
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            seen = true;
            io.disconnect();
            maybeStart();
          }
        });
      }, { threshold: 0.4 });
      io.observe(span);
    } else {
      seen = true;
      maybeStart();
    }
  });
})();
