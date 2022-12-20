// main functionality for Elis  Hallik "Above" for U: Vary-Player

// Audio based on Tone.js


// similar to object's properties
let playbackData = null, pieceInfo = null, reverb=null, gainNode=null;
let hasListenedAll = false; // TODO: get from localStorage or similar
let counter=0, loadedCounter=0, timerID=0, time = 0, progress = 0;
let audioResumed = false;
const pieceIndex = 0; // peceIndex is necessary if there are several pieces. Leftover from layer-player first version



async function resumeAudio() {
    await Tone.context.resume(); //newer syntax: Tone.getContext().resume();
    console.log("Audio resume");
    audioResumed = true;
}

function init() {
    hasListenedAll = false;

    // how many times listened?
    counter = getStoredCounter(playbackData[pieceIndex].uid);
    console.log("Found counter for ", counter, playbackData[pieceIndex].uid);
    if (counter === playbackData[pieceIndex].playList.length-1) {
        lastTimeReaction();
    }

    const volume = parseFloat(document.querySelector("#volumeSlider").value);
    gainNode = new Tone.Gain({minValue:0, maxValue:1, gain: volume || 0.6}).toMaster(); // ver 14: toDestination(); //
    reverb = new  Tone.Reverb( {decay:2.5, wet:0.05} ).connect(gainNode);
    preparePlayback(0, counter); // load tracks, dispose old etc

    // UI operations
    createMenu();

    const loadingProgress = document.querySelector("#loadingProgress")
    const playbackProgress = document.querySelector("#playbackProgress")
    const time = document.querySelector("#time")

    document.querySelector("#counterSpan").innerHTML = (counter+1).toString();
   
    pauseButton.style.display = "none";
    stopButton.style.opacity = 0.2;
    playbackProgress.style.display = "none";

    // TODO: 
    // here one example of load progress works with Tone.js r13 but not r14
    Tone.Buffer.on("progress",  (value) => {
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


function loadTracksJson() {
    // if several pieces, get stored pieceIndex here.
    fetch("tracks.json")
        .then((res) => res.json())
        .then((data) => {
            playbackData = data;
            console.log("Loaded json object: ", data);
            init();
        })
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
            if (loadedCounter==tracksInPlaylist) {
                setLoaded(true);
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
    // release old tracks
    for (let set of playbackData[pieceIndex].playList) {
        if (set) {
            for (let track of set.tracks) {
                if (track.hasOwnProperty("channel")) {
                    console.log("Trying to dispose: ", track.name);
                    if (track.channel) track.channel.dispose();
                    if (track.player) track.player.dispose();
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

    if (Tone.Transport.state !==  "stopped") {
        stop();
    }

    setLoaded(false);

    // release memory of old tracks
    // TODO: bug on disposing Random tracks!
    if (playbackData.currentPlaylist ) {
        dispose(pieceIndex, playbackData.currentPlaylist); // clear old buffers
    }

    pieceInfo = {
        title:playbackData[pieceIndex].title,
        duration:playbackData[pieceIndex].duration,
        versionName:playbackData[pieceIndex].playList[playListIndex].name,
        versions: playbackData[pieceIndex].playList.length
    };

    loadedCounter = 0;

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

    playbackData.currentPlaylist = playListIndex;
}

const lastTimeReaction = () => {
    console.log("This was the last available version. Now you can choose whichever you want");
    hasListenedAll = true; // TODO: reflect on UI (show message, unhide menu)
}

const start = () => {
    if (!audioResumed) {
        resumeAudio().then( ()=> audioResumed=true  ); // to resume audio on Chrome and similar
    }
    console.log("Start");
    Tone.Transport.start(); // is this necessary? propbaly no, () should do.
    const id =  Tone.Transport.scheduleRepeat(() => {
        setTime( Math.floor(Tone.Transport.seconds));
        //console.log("Duration: ", pieceInfo.duration);
        if (Tone.Transport.seconds>pieceInfo.duration && Tone.Transport.state==="started") {
            stop();
            if (!hasListenedAll) {
                const newCounter = counter + 1;
                console.log("Counter now: ", newCounter, counter);
                if (newCounter < playbackData[pieceIndex].playList.length) {
                    setStoredCounter(playbackData[pieceIndex].uid, newCounter);
                    counter = newCounter;
                    setTimeout(() => {
                        preparePlayback(pieceIndex, newCounter); // load data for next version automatically
                        }, 200); // give some time to stop
                } else {
                    lastTimeReaction();
                    console.log("Counter would be out of range: ", counter, playbackData[pieceIndex].playList.length);
                }
            }
        }
    }, 1);
    console.log("Created timer: ", id);
    timerID = id;

    const playbackProgress = document.querySelector("#playbackProgress")
    playbackProgress.max = playbackData[pieceIndex].duration

    // UI operations
    playButton.style.display = "none";
    pauseButton.style.display = "block";
    stopButton.style.opacity = 1;
}

const pause = () => {
    Tone.Transport.pause();
    // UI operations
    playButton.style.display = "block";
    pauseButton.style.display = "none";
}

const stop = () => {
    console.log("Stop");
    Tone.Transport.stop();
    Tone.Transport.clear(timerID);
    setTime(0);
    // UI operations
    playButton.style.display = "block";
    pauseButton.style.display = "none";
}

function setVolume(value) {
    if (gainNode) {
        gainNode.gain.rampTo(value, 0.05);
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
}


window.onload = () => {
    console.log("Start here");
    loadTracksJson();

    const volumeSlider = document.querySelector("#volumeSlider");
    volumeSlider.addEventListener("input", (event)=> setVolume( parseFloat(event.target.value)));

    // createMenu(); // call it after fetch

}
