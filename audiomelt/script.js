var Module = {
  preRun: [],
  postRun: [],
  print: function (o) {
    (o = Array.prototype.slice.call(arguments).join(" ")), console.log(o);
  },
  printErr: function (o) {
    (o = Array.prototype.slice.call(arguments).join(" ")), console.error(o);
  },
  canvas: document.getElementById("canvas"),
  setStatus: function (o) {
    console.log("status: " + o);
  },
  monitorRunDependencies: function (o) {
    console.log("monitor run deps: " + o);
  },
};
window.onerror = function () {
  console.log("onerror: " + event);
};
