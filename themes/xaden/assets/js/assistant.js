// Optional enhancement (REQ-022): lets a reader pick their assistant; the docs then show its commands.
// Without JavaScript the page shows the Claude Code commands and no picker.
(function () {
  "use strict";
  var KEY = "xaden-assistant";
  var picker = document.querySelector("[data-assistant-picker]");
  var select = picker && picker.querySelector("select");
  if (!select || !document.querySelector(".assistant-variant")) return;

  var known = Array.prototype.map.call(select.options, function (o) { return o.value; });
  var ok = function (id) { return known.indexOf(id) !== -1; };

  function stored() {
    try { return localStorage.getItem(KEY); } catch (e) { return null; }
  }
  function store(id) {
    try { localStorage.setItem(KEY, id); } catch (e) { /* private mode: the choice lasts for this page only */ }
  }
  function fromHash() {
    var m = /^#assistant=([a-z-]+)$/.exec(location.hash);
    return m && ok(m[1]) ? m[1] : null;
  }

  function show(id) {
    document.documentElement.setAttribute("data-assistant", id);
    select.value = id;
  }

  var linked = fromHash();
  var start = linked || (ok(stored()) ? stored() : "claude-code");
  if (linked) store(linked);
  show(start);
  picker.hidden = false;

  select.addEventListener("change", function () {
    store(select.value);
    show(select.value);
    // keep a shareable link, but never replace a link to a section
    if (location.hash === "" || fromHash()) history.replaceState(null, "", "#assistant=" + select.value);
  });
  window.addEventListener("hashchange", function () {
    var id = fromHash();
    if (id) { store(id); show(id); }
  });
})();
