let audio = null,
  currentPart = 1;

function getRandomSource(part) {
  // pick a random soundfile from folder for the part1 or part 2
  // ...
}

function showDialog(open) {
  document.querySelector("#dialogDiv").style.visibility = open
    ? "visible"
    : "hidden";
}

// same in above.js -  move to utils?
function setLoaded(loaded) {
  console.log("Loaded: ", loaded);
  if (!loaded) {
    document.querySelector("#playButton").disabled = true;
    document.querySelector("#loadingSpan").innerHTML = "Loading ...";
  } else {
    document.querySelector("#playButton").disabled = false;
    document.querySelector("#loadingSpan").innerHTML = "";
  }
}

function reaction(yes) {
  // if yes, start second audio
  console.log("Yes? ", yes);
  if (yes) {
    setLoaded(false);
    audio.src = "sounds/vaatenurk-II-demo.mp3"; // getRandomSource later
    currentPart = 2;
    start();
  } else {
    // TODO: some kind or response
  }
  showDialog(false);
}

function start() {
  if (audio) audio.play();
}

function pause() {
  if (audio) audio.pause();
}

function stop() {
  if (audio) {
    audio.pause();
    audio.currentTime = 0;
  }
  // TODO: if stopped in part II goes back to part 1 ?
}

// TODO: evey time "Play" is pressed, pick a new version (audio.src="" probably)

window.onload = () => {
  audio = document.querySelector("#audio1");
  audio.onended = () => {
    if (currentPart == 1) {
      showDialog(true);
    } else {
      console.log("2. part ended");
      // do something. load new audio for part 1 ? currentPart = 1
    }
  };
  showDialog(false);
  setLoaded(false);
  currentPart = 1;
};
