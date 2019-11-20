/* adapted from https://developer.mozilla.org/en-US/docs/Web/API/Window/open */

var windowObjectReference = null; // global variable

function openKitkat() {
  const left = 260;  // window's distance from left
  const top = 700;  // window's distance from top
  const width = 480;  // window width
  const height = 280;  // window height

  if(windowObjectReference == null || windowObjectReference.closed) {
      windowObjectReference = window.open(
        "kitkat.html",
        "KitkatWindow",
        "resizable,scrollbars,status=no,width=" + width + ",height=" + height + ",left=" + left + ",top=" + top
      );
  }
  else {
    windowObjectReference.focus();
  };
}