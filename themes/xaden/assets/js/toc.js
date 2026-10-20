// Optional enhancement (REQ-014): marks the "On this page" entry of the section in view.
// Without JavaScript the entries are plain links.
(function () {
  "use strict";
  var links = Array.prototype.slice.call(document.querySelectorAll(".toc a[href^='#']"));
  if (!links.length) return;

  var items = [];
  links.forEach(function (a) {
    var el = document.getElementById(decodeURIComponent(a.getAttribute("href").slice(1)));
    if (el) items.push({ el: el, id: a.getAttribute("href") });
  });
  if (!items.length) return;

  var ticking = false;
  function update() {
    ticking = false;
    // The current section is the last heading above a line a quarter down the window; at the page end, the last one.
    var line = window.innerHeight / 4;
    var atEnd = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2;
    var current = null;
    items.forEach(function (it) {
      if (it.el.getBoundingClientRect().top <= line) current = it.id;
    });
    if (atEnd) current = items[items.length - 1].id;
    links.forEach(function (a) {
      if (a.getAttribute("href") === current) a.setAttribute("aria-current", "location");
      else a.removeAttribute("aria-current");
    });
  }
  function onScroll() {
    if (!ticking) { ticking = true; window.requestAnimationFrame(update); }
  }

  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll);
  update();
})();
