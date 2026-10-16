// Optional enhancement (REQ-002): adds a copy button to every code block.
// Without JavaScript the code stays visible and selectable.
(function () {
  "use strict";
  var RESET_AFTER_MS = 2000;

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      var area = document.createElement("textarea");
      area.value = text;
      area.setAttribute("readonly", "");
      area.className = "sr-only";
      document.body.appendChild(area);
      area.select();
      var copied = document.execCommand("copy");
      document.body.removeChild(area);
      copied ? resolve() : reject(new Error("copy failed"));
    });
  }

  function addButton(block) {
    var wrapper = document.createElement("div");
    wrapper.className = "code-block";
    block.parentNode.insertBefore(wrapper, block);
    wrapper.appendChild(block);

    var button = document.createElement("button");
    button.type = "button";
    button.className = "copy-button";
    button.textContent = "Copy";
    button.setAttribute("aria-label", "Copy code to clipboard");
    wrapper.appendChild(button);

    var status = document.createElement("span");
    status.className = "sr-only";
    status.setAttribute("role", "status");
    wrapper.appendChild(status);

    button.addEventListener("click", function () {
      var code = block.querySelector("code");
      copyText((code || block).innerText.replace(/\n$/, "")).then(
        function () {
          button.textContent = "Copied";
          status.textContent = "Copied to clipboard";
        },
        function () {
          button.textContent = "Press Ctrl+C";
          status.textContent = "Copy failed, select the text and copy it by hand";
        }
      );
      window.setTimeout(function () {
        button.textContent = "Copy";
        status.textContent = "";
      }, RESET_AFTER_MS);
    });
  }

  Array.prototype.forEach.call(document.querySelectorAll("pre"), addButton);
})();
