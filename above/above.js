// main functionality for Elis  Hallik "Above" for U: Vary-Player

// Audio based on Tone.js


// similar to object's properties
let playbackData = null, pieceInfo = null, reverb=null, gainNode=null;
let hasListenedAll = false; // TODO: get from localStorage or similar
let counter=0, loadedCounter=0, timerID=0, time = 0, progress = 0;
let audioResumed = false;
let isLoaded = false;
let requirePlayback = false; // for starting playback after one version has ended and new will be loaded
let audio = null;
let lightAudio = true; // weather to use audio element ot Tone.js
const pieceIndex = 0; // peceIndex is necessary if there are several pieces. Leftover from layer-player first version
const requiredListens = 6; // UPDATE, if necessary



async function resumeAudio() {
    await Tone.context.resume(); //newer syntax: Tone.getContext().resume();
    console.log("Audio resume");
    audioResumed = true;
}

function initAudio() {

}

function init() {
    hasListenedAll = false;

    // how many times listened?
    counter = getStoredCounter(playbackData[pieceIndex].uid);
    console.log("Found counter for ", counter, playbackData[pieceIndex].uid);
    if (counter >=  requiredListens ) {
        lastTimeReaction();
    }

    const volume = parseFloat(document.querySelector("#volumeSlider").value);
    if ( lightAudio) {
        audio = new Audio();
        audio.oncanplay = () => {
            setLoaded(true);
            if (requirePlayback) {
                requirePlayback = false;
                start(); // maybe start and play have to be different as in pointofview
            }
            loadingProgress.style.display = 'none'; // show playbackprogress
            playbackProgress.style.display = 'block';
            time.innerHTML = '00:00'
        }
        audio.addEventListener("loadedmetadata", () => {
            console.log("Load metadata, new duration: ", audio.duration, pieceInfo.duration);
            playbackProgress.max = audio.duration;
        });

        audio.addEventListener("timeupdate", () => {
            playbackProgress.value = audio.currentTime;
        });

        // audio.ended? probably not, timerFunction takes care of that.
    } else { // TONE
        gainNode = new Tone.Gain({minValue:0, maxValue:1, gain: volume || 0.6}).toMaster(); // ver 14: toDestination(); //
        reverb = new  Tone.Reverb( {decay:2.5, wet:0.05} ).connect(gainNode);
    }

    preparePlayback(0, counter); // load tracks, dispose old etc

    // UI operations
    createMenu();

    const loadingProgress = document.querySelector("#loadingProgress")
    const playbackProgress = document.querySelector("#playbackProgress")
    const time = document.querySelector("#time")

    document.querySelector("#counterSpan").innerHTML = (counter).toString();
   
    pauseButton.style.display = "none";
    stopButton.style.opacity = 0.2;
    playbackProgress.style.display = "none";

    if (!lightAudio) {
        Tone.Buffer.on("progress", (value) => {
            progress = Math.round(value * 100);
            time.innerHTML = "Loading... " + progress + "%";
            loadingProgress.value = progress;
            if (progress === 100) {
                loadingProgress.style.display = 'none';
                playbackProgress.style.display = 'block';
                time.innerHTML = '00:00'
            }
        });
    }

}

function useLightAudio(light) {
    lightAudio = light;
    init(); // this is not right, it should deal only with audio part. figure out about globals/locals like volume && progresses etc
}


function loadTracksJson() {  // for Tone
    // if several pieces, get stored pieceIndex here.
    fetch("tracks.json")
        .then((res) => res.json())
        .then((data) => {
            playbackData = data;
            console.log("Loaded json object: ", data);
            init();
        })
}

function loadAudio(source) { // for audio element
    if (audio) {
        console.log("Loading: ", source);
        audio.src = source;
        audio.load();
        setLoaded(false);
    }

}


function getStoredCounter(uid)  {
    const key = "ULP_"+uid;
    const value = localStorage.hasOwnProperty(key) ?  parseInt(localStorage.getItem(key)) : 0;
    return value;
}

function setStoredCounter(uid, value)  {
    const key = "ULP_"+uid;
    return localStorage.setItem(key, value.toString());
}

function createChannel(volume, pan) {
    if (reverb) {
        const channel = new Tone.Channel({channelCount: 2, volume: volume, pan: pan}).connect(reverb);
        return channel;
    } else {
        console.log("reverb is null");
        return null;
    }
}


function createPlayer(soundFile) {
    const source = "./tracks/" + soundFile;
    console.log("Source: ", source);
    const newPlayer = new Tone.Player({
        url: source,
        loop: false,
        onload: () => {
            loadedCounter++;
            const  tracksInPlaylist = playbackData[pieceIndex].playList[playbackData.currentPlaylist].tracks.length;
            console.log("Local onload -  loaded", soundFile, loadedCounter, tracksInPlaylist );
            if (loadedCounter===tracksInPlaylist) {
                setLoaded(true);
                if (requirePlayback) {
                    requirePlayback = false;
                    start();
                }
            }
        }
    }).sync().start();
    return newPlayer;
}


function getSoundfile(name, piece=pieceIndex) {
    if (!playbackData) return;
    const trackInfo =     playbackData[piece].tracks.find( (track) => track.name===name );
    if (!trackInfo) {
        console.log("TrackInfo not found for:", name, playbackData[piece].title);
        return "";
    } else {
        return trackInfo.soundFile;
    }
}

const dispose = (pieceIndex=0, playListIndex=0) => {
    console.log("Dispose playlist, trakcs: ", playListIndex, playbackData[pieceIndex].playList[playListIndex].tracks);
    if (playbackData[pieceIndex].playList[playListIndex]) {
        for (let track of playbackData[pieceIndex].playList[playListIndex].tracks) {
            if (track.hasOwnProperty("channel") && track.channel && track.player) {
                console.log("Trying to dispose: ", track.name, track.channel);

                if (track.channel) {
                    track.channel.dispose(); // this is not enough, it seems
                    track.channel = null; // probably wrong thing to do
                }
                if (track.player) {
                    track.player.unsync(); // for any case
                    track.player.dispose();
                    track.player = null;
                }
            }
        }
    }
}

function getRandomElementFromArray(array) {  // perhaps move to util? if needed somewhre else...
    return array[Math.floor(Math.random() * array.length)];
};

function createRandomPlaylist(voices=6) { // creates and adds a random playlist for given number of voices
    let newPlaylist = { "name":"Random", "tracks":[]};
    // given that the tracks' number does not change and they are organised by voices! Otherwise filter by voice number in the name of track
    let tracksByVoices = [
        playbackData[pieceIndex].tracks.slice(0,5),
        playbackData[pieceIndex].tracks.slice(5,8),
        playbackData[pieceIndex].tracks.slice(8,12),
        playbackData[pieceIndex].tracks.slice(12,17),
        playbackData[pieceIndex].tracks.slice(17,23),
        playbackData[pieceIndex].tracks.slice(23)
    ];
    console.log(tracksByVoices);
    if (voices===6) {
        let possiblePans = [-0.4, -0.2, -0.1, 0.1, 0.2, 0.4 ];
        // shuffle array:
        possiblePans.sort(() => Math.random() - 0.5);

        // volume with slight random -12..-3
        for (let i=0; i<6; i++) {
            const volume = -12 + Math.random()*9;
            const pan = possiblePans[i];
            console.log("Vol, pan: ", volume, pan);
            const track = getRandomElementFromArray(tracksByVoices[i]);
            console.log("Picked Track:", track);
            const newTrack = { name:track.name, pan: pan, volume: volume };
            newPlaylist.tracks.push(newTrack)
        }
        // less voices requires other conditions
    }
    console.log("Created playlist: ", newPlaylist);
    return newPlaylist;
}

const preparePlayback = (pieceIndex=0, playListIndex=0) => { // index to piece  later: take it from pieceIndex

    if (!playbackData) return;
    console.log("preparePlayback", pieceIndex, playListIndex);

    if ((lightAudio && audio.paused) || ( !lightAudio && Tone.Transport.state !==  "stopped")) {
        stop();
    }

    setLoaded(false);



    pieceInfo = {
        title:playbackData[pieceIndex].title,
        duration:playbackData[pieceIndex].duration,
        versionName:playbackData[pieceIndex].playList[playListIndex].name,
        versions: playbackData[pieceIndex].playList.length
    };

    setVersionAndCount();

    loadedCounter = 0;

    if (!lightAudio) {
        console.log("playlist: current, index", playbackData.currentPlaylist, playListIndex);
        if (playbackData.currentPlaylist) {
            dispose(pieceIndex, playbackData.currentPlaylist); // clear old buffers
        }

        const activeTracks = playbackData[pieceIndex].playList[playListIndex].tracks;
        console.log("Should start playing: ", activeTracks);
        for (let track of activeTracks) {
            const soundFile = getSoundfile(track.name, pieceIndex);
            if (soundFile) {
                track.channel = createChannel(track.volume, track.pan);
                track.player = createPlayer(soundFile);
                track.player.connect(track.channel);
            }
        }
    } else {
        const source = `versions/above${playListIndex+1}.mp3`;
        loadAudio(source);
    }

    playbackData.currentPlaylist = playListIndex;
}

const lastTimeReaction = () => {
    console.log("This was the last available version. Now you can choose whichever you want");
    hasListenedAll = true;
    document.querySelector("#menuDiv").style.display= 'block';
}

const isPlaying = () => lightAudio ? !audio.paused : Tone.Transport.state==="started";


const timerFunction = () => {
    const time = lightAudio ? audio.currentTime : Tone.Transport.seconds;
    setTime( Math.floor(time));
    //console.log("Duration: ", pieceInfo.duration);
    if (time>pieceInfo.duration && isPlaying()) {
        stop();

        if (counter < playbackData[pieceIndex].playList.length) {
            const newCounter = counter + 1;
            if (newCounter < requiredListens) {
                hasListenedAll = false; // this variable probably not necessary any more.
            } else {
                hasListenedAll = true;
                lastTimeReaction();
            }

            setStoredCounter(playbackData[pieceIndex].uid, newCounter);
            counter = newCounter;
            setTimeout(() => {
                preparePlayback(pieceIndex, newCounter); // load data for next version automatically
                requirePlayback = true; // singal to play when loaded
            }, 200); // give some time to stop

        } else {
            console.log("Counter out of range: ", counter, playbackData[pieceIndex].playList.length);
        }
    }
}

const start = () => {
    if (!audioResumed) {
        resumeAudio().then( ()=> audioResumed=true  ); // to resume audio on Chrome and similar
    }
    console.log("Start");
    if (lightAudio) {
        if (isLoaded) {
            audio.play();
        } else {
            requirePlayback = true;
            return;
        }
        timerID = setInterval(timerFunction, 1000);
        // need several conditions and a timer here too
    } else {
        Tone.Transport.start();
        const id =  Tone.Transport.scheduleRepeat(timerFunction, 1);
        console.log("Created timer: ", id);
        timerID = id;
    }


    const playbackProgress = document.querySelector("#playbackProgress")
    playbackProgress.max = playbackData[pieceIndex].duration

    // UI operations
    playButton.style.display = "none";
    pauseButton.style.display = "block";
    stopButton.style.opacity = 1;
}

const pause = () => {
    if (lightAudio) {
        audio.pause();
    } else {
        Tone.Transport.pause();
    }
    // UI operations
    playButton.style.display = "block";
    pauseButton.style.display = "none";
}

const stop = () => {
    console.log("Stop");
    if (lightAudio) {
        pause();
        audio.currentTime = 0;
    } else {
        Tone.Transport.stop();
        Tone.Transport.clear(timerID);
    }

    setTime(0);
    // UI operations
    playButton.style.display = "block";
    pauseButton.style.display = "none";
}

function setVolume(value) {
    if (gainNode) {
        gainNode.gain.rampTo(value, 0.05);
    }
    if (audio) {
        audio.volume = value; // is it the same scale?
    }
}

function timestring(time) {
    const minutes = Math.floor(time / 60).toString();
    const seconds = (time % 60).toString();
    const timeString = minutes.padStart(2, "0") + ":" + seconds.padStart(2, "0");
    return timeString;
}



// UI


function setTime(seconds) {
    time = seconds;
    document.querySelector("#time").innerHTML = timestring(seconds);
    document.querySelector("#playbackProgress").value = seconds;
}

function setLoaded(loaded) {
    console.log("Loaded: ", loaded);
    isLoaded = loaded;
    if (!loaded) {
        document.querySelector("#playButton").disabled = true;
        document.querySelector("#time").innerHTML = "Loading ..."
    } else {
        document.querySelector("#playButton").disabled = false;
        document.querySelector("#time").innerHTML = "00:00";
    }
}

function createMenu() {
    if (!playbackData) return;

    const selectElement = document.querySelector("#versionSelect");
    const playLists = playbackData[pieceIndex].playList;
    for (let i=0; i<playLists.length;i++ ) {
        selectElement.options.add( new Option(playLists[i].name, i.toString()) ); // cut off .mp3 from the text part
    }
    // add entry for random mix:
    selectElement.options.add( new Option("Random", "999") ); // leave the last place for randomly generated playlist
    selectElement.addEventListener("change", (event) => {
        const index = parseInt(event.target.value);
        console.log("Selected version with index: ", index);
        if (event.target.value==="999") {
            console.log("Random selected");
            playbackData[pieceIndex].playList[index] = createRandomPlaylist();
        }
        preparePlayback(pieceIndex, index);
    }, false);

    // Add playlist buttons to a grid

    const versionGrid = document.querySelector("#versionGrid");
    playLists.forEach((playList, i) => {
        const btn = document.createElement("button");
        btn.textContent = playList.name
        btn.addEventListener("click", () => {
            console.log("Selected version with index: ", i);
            preparePlayback(pieceIndex, i);
            // TODO: For debuggong, remove when select element is removed
            selectElement.value = i
        });
        versionGrid.appendChild(btn);
      });

    // Add random button to a grid

    const randomBtn = document.createElement("button");
    randomBtn.textContent = "Random"
    randomBtn.addEventListener("click", () => {
        console.log("Random selected");
        const index = 999
        playbackData[pieceIndex].playList[index] = createRandomPlaylist();
        preparePlayback(pieceIndex, index);
        // TODO: For debuggong, remove when select element is removed
        selectElement.value = index
    });
    versionGrid.appendChild(randomBtn);

}

function setVersionAndCount() {
    document.querySelector("#counterSpan").innerHTML = (counter).toString();
    document.querySelector("#versionSpan").innerHTML = pieceInfo.versionName;
}

// just for testing (to jump to the end):
const  jump= () => lightAudio ? audio.currentTime = 465 :  Tone.Transport.seconds=465;


// helper function to produce Csound score for csound/renderFiles.csd
function csoundScore() {
    if (!playbackData) return;
    let scoreLines = ""
    let listCounter = 1;
    for (let playList of playbackData[pieceIndex].playList) {
        scoreLines += "\n; " + playList.name + "\n";
        for (let track of playList.tracks) {
            scoreLines += `i "Player" 0 1 "../tracks/${getSoundfile(track.name)}" ${track.volume} ${track.pan}\n`;
        }
        scoreLines += `i "Out" 0 [7*60+56] ${listCounter++}\ns \n`;


    }
    console.log(scoreLines);
}

let showVolume = false;

window.onload = () => {
    console.log("Start here");
    loadTracksJson();

    const volumeSlider = document.querySelector("#volumeSlider");
    const volumeToggle = document.querySelector("#volumeToggle");

    volumeSlider.addEventListener("input", (event)=> setVolume( parseFloat(event.target.value)));

    volumeSlider.style.opacity = 0;

    volumeToggle.addEventListener("click", () => {
        showVolume = !showVolume;
        volumeSlider.style.opacity = showVolume ? 1 : 0;
      });
    // createMenu(); // call it after fetch

}
