// Optional enhancement (REQ-019): small shadows trail the pointer, behind all content.
// Off for touch, without hover, and under reduced motion; without JavaScript nothing changes.
(function () {
  "use strict";
  var query = function (q) { return window.matchMedia && window.matchMedia(q).matches; };
  if (query("(prefers-reduced-motion: reduce)") || !query("(hover: hover) and (pointer: fine)")) {
    return;
  }
  // follow speed per shadow: the smaller, the longer it lags behind
  var FOLLOW = [0.22, 0.12, 0.06];
  var shadows = FOLLOW.map(function (speed, i) {
    var el = document.createElement("div");
    el.className = "pointer-shadow";
    el.setAttribute("aria-hidden", "true");
    el.style.opacity = "0";
    el.style.scale = String(1 - i * 0.25);
    document.body.appendChild(el);
    return { el: el, speed: speed, x: 0, y: 0 };
  });
  var target = null;
  var running = false;

  function frame() {
    var moving = false;
    shadows.forEach(function (s) {
      var dx = target.x - s.x;
      var dy = target.y - s.y;
      s.x += dx * s.speed;
      s.y += dy * s.speed;
      s.el.style.transform = "translate(" + s.x + "px," + s.y + "px)";
      if (Math.abs(dx) > 0.5 || Math.abs(dy) > 0.5) { moving = true; }
    });
    running = moving;
    if (moving) { requestAnimationFrame(frame); }
  }

  document.addEventListener("pointermove", function (event) {
    if (event.pointerType !== "mouse" && event.pointerType !== "pen") { return; }
    if (!target) {
      shadows.forEach(function (s) { s.x = event.clientX; s.y = event.clientY; s.el.style.opacity = "0.8"; });
    }
    target = { x: event.clientX, y: event.clientY };
    if (!running) { running = true; requestAnimationFrame(frame); }
  });
  document.documentElement.addEventListener("pointerleave", function () {
    shadows.forEach(function (s) { s.el.style.opacity = "0"; });
    target = null;
  });
})();
