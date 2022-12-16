const audio = document.getElementById("audio");
const play = document.getElementById("play");
const playing = document.getElementById("playing");
const paused = document.getElementById("paused");
const stopping = document.getElementById("stopping");
const progress = document.getElementById("progress");
const hms = document.getElementById("hms");
const current = document.getElementById("current");

let isLoaded = false;
let isPlaying = false;

let currentPart = 1;

// Audio events

audio.addEventListener("canplaythrough", () => {
  isLoaded = true;
  hms.innerHTML = "00:00";
  current.innerHTML = `Playing part ${currentPart}`;
});

audio.addEventListener("loadedmetadata", () => {
  progress.max = audio.duration;
});

audio.addEventListener("timeupdate", () => {
  progress.value = audio.currentTime;
  hms.innerHTML = secondsToHms(audio.currentTime);
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

// Transport controls events

play.addEventListener("click", () => {
  if (isPlaying) {
    audio.pause();
    isPlaying = false;
    // Styling
    playing.style.display = "none";
    paused.style.display = "block";
    stopping.style.opacity = 0.3;
  } else if (!isPlaying && isLoaded) {
    // TODO: evey time "Play" is pressed, pick a new version (audio.src="" probably)?
    audio.play();
    isPlaying = true;
    // Styling
    playing.style.display = "block";
    paused.style.display = "none";
    stopping.style.opacity = 1;
  } else {
  }
});

stopping.addEventListener("click", () => {
  if (isPlaying) {
    audio.pause();
    audio.currentTime = 0;
    isPlaying = false;
    // Styling
    playing.style.display = "none";
    paused.style.display = "block";
    stopping.style.opacity = 0.3;
  }
});
