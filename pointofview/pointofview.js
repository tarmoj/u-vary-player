const audio = document.getElementById("audio");

const playButton = document.getElementById("playButton");
const pauseButton = document.getElementById("pauseButton");
const stopButton = document.getElementById("stopButton");

const progress = document.getElementById("progress");
const timestamp = document.getElementById("timestamp");
const current = document.getElementById("current");

const volumetoggle = document.getElementById("volumetoggle");
const volume = document.getElementById("volume");

let isLoaded = false;
let currentPart = 1;
let showVolume = false;

function init() {
  pauseButton.style.display = "none";
  stopButton.style.opacity = 0.2;
  timestamp.innerHTML = "Loading...";
  currentPart.innerHTML = "";
}

function start() {
  if (isLoaded) {
    // TODO: evey time "Play" is pressed, pick a new version (audio.src="" probably)?
    audio.play();
    //  isPlaying = true;
    playButton.style.display = "none";
    pauseButton.style.display = "block";
    stopButton.style.opacity = 1;
  }
}

function pause() {
  audio.pause();
  //  isPlaying = false;
  playButton.style.display = "block";
  pauseButton.style.display = "none";
}

function stop() {
  pause();
  audio.currentTime = 0;
}

// Assign init event

window.addEventListener("load", init);

// Assing transport buttons events

playButton.addEventListener("click", start);
pauseButton.addEventListener("click", pause);
stopButton.addEventListener("click", stop);

// Assign audio events

audio.addEventListener("canplaythrough", () => {
  isLoaded = true;
  timestamp.innerHTML = "00:00";
  current.innerHTML = `Playing part ${currentPart}`;
});

audio.addEventListener("loadedmetadata", () => {
  progress.max = audio.duration;
});

audio.addEventListener("timeupdate", () => {
  progress.value = audio.currentTime;
  timestamp.innerHTML = secondsToTimestamp(audio.currentTime);
});

audio.addEventListener("ended", () => {
  // TODO: bring back the logic to ask user whenever he/she
  // wants to continue
  // https://github.com/tarmoj/u-vary-player/commit/f17a73754aaf40cf410d9643c159307d286abf43
  const isNext = confirm("Do you want to listen the next piece of music?");
  if (isNext) {
    audio.src = "sounds/vaatenurk-II-demo.mp3"; // getRandomSource later
    audio.play();
    currentPart = 2;
    current.innerHTML = `Playing part ${currentPart}`;
  }
  // TODO: some kind or response
});

volumetoggle.addEventListener("click", () => {
  showVolume = !showVolume;
  volume.style.opacity = showVolume ? 1 : 0;
});

volume.addEventListener("input", (el) => {
  const value = parseFloat(el.target.value);
  audio.volume = value;
});
