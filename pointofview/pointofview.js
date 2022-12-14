const audio = document.getElementById("audio");

const playButton = document.getElementById("playButton");
const pauseButton = document.getElementById("pauseButton");
const stopButton = document.getElementById("stopButton");

const progress = document.getElementById("progress");
const timestamp = document.getElementById("timestamp");
const current = document.getElementById("current");

const numberOfVersions = 90 ; // how many generated audio file pairs (partI-partII) NB! update


const volumetoggle = document.getElementById("volumetoggle");
const volume = document.getElementById("volume");

let isLoaded = false;
let currentPart = 1;
let showVolume = false;
let audioState = "stopped" ; // playing| paused | stopped - audio elent has only paused...
let currentVersion = 1;

function init() {
  pauseButton.style.display = "none";
  stopButton.style.opacity = 0.2;
  timestamp.innerHTML = "Loading...";
  currentPart.innerHTML = "";
  setVersion();
  load(1);
}

function start() {
  audioState = "playing"; // to signal onLoaded handler
  if (isLoaded) {
    play();
  }  else {
    console.log("Audio not ready. Wait for onLoad to start it");
  }
}

function play() {
  audio.play();
  audioState = "playing";
  playButton.style.display = "none";
  pauseButton.style.display = "block";
  stopButton.style.opacity = 1;

}

function pause() {
  audio.pause();
  audioState = "paused";
  playButton.style.display = "block";
  pauseButton.style.display = "none";
}

function stop() {
  pause();
  audioState="stopped";
  audio.currentTime = 0; // this should update the progress but it does not
  progress.value = 0;
  // alwas go back to part 1 when stopped
  currentPart = 1;
  setVersion(); // after stop load a new version
  load(currentPart);
}

function setVersion() {
  currentVersion = 1 + Math.floor(Math.random()*numberOfVersions);
  console.log("Set version to: ", currentVersion)
}

function load(part=1) { // part - 1 | 2
  // local:
  //let source = (part==1) ? `sounds/${currentVersion}-I.mp3` : `sounds/${currentVersion}-II.mp3`;
  let source = "https://uuu.ee/player/pointofview/sounds/" +  ( (part==1) ? `${currentVersion}-I.mp3` : `${currentVersion}-II.mp3`);
  console.log("New source", source);
  isLoaded = false;
  audio.src = source;
  audio.load();

}

// just for testing - jumps to the end of the part
function jump() {
  audio.currentTime = audio.duration - 5;
}

// Assign init event

window.addEventListener("load", init);

// Assing transport buttons events

playButton.addEventListener("click", start);
pauseButton.addEventListener("click", pause);
stopButton.addEventListener("click", stop);

// Assign audio events

audio.addEventListener("canplay", () => {
  console.log("Loaded");
  if (audioState==="playing") { // can bes set "playing" from start
    play();
  }
  isLoaded = true;
  timestamp.innerHTML = "00:00";
  current.innerHTML = `Part ${currentPart}  <span hidden><small><i>Fort testing: version ${currentVersion} </i></small></span>`;
});

audio.addEventListener("loadedmetadata", () => {
  console.log("Load metadata, new duration: ", audio.duration, currentPart);
  progress.max = audio.duration;
});

audio.addEventListener("timeupdate", () => {
  progress.value = audio.currentTime;
  timestamp.innerHTML = secondsToTimestamp(audio.currentTime);
});



audio.addEventListener("ended", () => {
  audioState = "stopped";
  playButton.style.display = "block"; // mar the play button to initial state
  pauseButton.style.display = "none";

  if (currentPart===1) {
    load(2); // try to load for any case to e ready on time
    const isNext = confirm("Do you want to continue listening to the piece?");
    if (isNext) {
      //load(2);
      //audio.play();
      audioState = "playing";
      start();
      currentPart = 2;
      current.innerHTML = `Part ${currentPart}. <small><i>Fort testing: version ${currentVersion} </i></small>`;
    } else {
      // TODO: some kind or response
    }
  } else {
    // if part 2 ends, go load new version for 1
    setVersion();
    currentPart = 1;
    load(1);
  }

});

volumetoggle.addEventListener("click", () => {
  showVolume = !showVolume;
  volume.style.opacity = showVolume ? 1 : 0;
});

volume.addEventListener("input", (el) => {
  const value = parseFloat(el.target.value);
  audio.volume = value;
});
