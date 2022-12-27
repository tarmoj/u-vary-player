#!/usr/bin/python3

import random, os, time
# random_items = random.choices(items, k=4, weights=[10, 1, 1, 1]) -  näide kaalutud valikust

#Definitions

# TODO: implement nextVoiceTIme also directory
# Flööt-klarnet 1:05.000
# Flööt-viiul 1:06.780
# Flööt-tšello 1:08.358
# Flööt-klaver 1:08.537
fluteFollows = {"$CL":65, "$VL":66.7, "$VC": 68.4, "$PF": 68.5 }
# etc
# Klarnet-viiul 1:31.141
# Klarnet-flööt 1:32.325
# Klarnet-tšello 1:32.868
# Klarnet-klaver 1:33.546
clarinetFollows = {"$VL":91.1, "$FL":92.3, "$VC": 92.9, "$PF": 93.5 }

#Viiul-klaver 1:16.796
#Viiul-flööt 1:16.424
#Viiul-klarnet 1:16.346
#Viiul-tšello 1:17.214
# siis viiuli fail käivitub originaalist 0:02.241(-245), palun vaata kus seal selline hea lõikamise koht on
violinFollows = {"$PF":76.8, "$FL":76.4, "$CL": 76.3, "$VC": 77.2 }


# Tšello-klaver 1:08.616
# Tšello-klarnet 1:08.091
# Tšello-viiul 1:07.566
# Tšello-flööt 1:08.778
celloFollows = { "$PF":68.6, "$CL":68.0, "$VL": 67.5, "$FL": 68.7 }

#perc: always 1:06

#perhaps: make the order first and then start to generate ?? How do i know what is next?

# constants 
flute = {"macro":"$FL", "nextVoiceTime": 65, "duration": 68, "follows": fluteFollows} # durations are made up now..
clarinet = {"macro":"$CL", "nextVoiceTime": 91, "duration": 93, "follows": clarinetFollows}
violin = {"macro":"$VL", "nextVoiceTime": 78, "duration": 80, "follows": violinFollows}
cello = {"macro":"$VC", "nextVoiceTime": 62, "duration": 64, "follows": celloFollows}

piano = {"macro":"$PF", "nextVoiceTime": 0, "duration": 123}
percussion = {"macro":"$PERC", "nextVoiceTime": 66, "duration": 71, "follows": fluteFollows}

# global data in an object - to make it easier to manipulate from functions
class GlobalData(): pass
data = GlobalData()

data.firstDegree = 0
data.lastInstrument = None
data.freeInstruments = [flute, clarinet, violin, cello]
data.lastStartTime = 0
#data.nextStartTime = 0
data.lastFileCounter = 1
data.percStart = 125 # 2:05, maybe even 2:07


def resetFreeInstruments():
    data.freeInstruments = [flute, clarinet, violin, cello]
    
def getInstrument(): # get one random and remove it from freeInstruments
    if (len(data.freeInstruments)==0): # reinit if empty
        data.freeInstruments = [flute, clarinet, violin, cello]
    index = random.randint(0, len(data.freeInstruments)-1 )
    instrument = data.freeInstruments.pop(index)
    #print("getInstrument", index, instrument, data.freeInstruments)
    return instrument

def getRandomChange(instrument, startTime):
    lines = "#define START3 #%.1f# \n" % (startTime)

    if instrument=="$FL":
        lines = '''
i "RandomMove" [$START3+12] 2 $FL
i "RandomMove" [$START3+16] 1.5 $FL
i "RandomMove" [$START3+24] 1.5 $FL
i "RandomMove" [$START3+27] 1.5 $FL
i "RandomMove" [$START3+32] 0.5 $FL
i "RandomMove" [$START3+34] 0.5 $FL
i "RandomMove" [$START3+37] 0.5 $FL
i "RandomMove" [$START3+41] 4 $FL
i "RandomMove" [$START3+48] 2 $FL
i "RandomMove" [$START3+57] 3 $FL
i "RandomMove" [$START3+60] 3 $FL
i "RandomMove" [$START3+60] 3 $FL
'''
    elif instrument=="$CL":
        lines += '''
i "RandomMove" [$START3+11] 2 $CL
i "RandomMove" [$START3+14] 2 $CL
i "RandomMove" [$START3+27] 2 $CL
i "RandomMove" [$START3+33] 1.5 $CL
i "RandomMove" [$START3+38] 1 $CL
i "RandomMove" [$START3+44] 2.5 $CL
i "RandomMove" [$START3+53] 3 $CL
i "RandomMove" [$START3+62] 0.5 $CL
i "RandomMove" [$START3+65] 0.5 $CL
i "RandomMove" [$START3+68] 1 $CL
i "RandomMove" [$START3+72] 4.5 $CL
i "RandomMove" [$START3+80] 1 $CL
i "RandomMove" [$START3+84] 2 $CL
i "RandomMove" [$START3+89] 1 $CL
i "RandomMove" [$START3+91] 1 $CL
        '''
    elif instrument=="$VL":
            lines += '''
i "RandomMove" [$START3+17] 2 $VL
i "RandomMove" [$START3+20] 2.5 $VL
i "RandomMove" [$START3+25] 1.5 $VL
i "RandomMove" [$START3+29] 1 $VL
i "RandomMove" [$START3+34] 2.5 $VL
i "RandomMove" [$START3+40] 1 $VL
i "RandomMove" [$START3+47] 2 $VL
i "RandomMove" [$START3+49] 0.5 $VL
i "RandomMove" [$START3+52] 2 $VL
i "RandomMove" [$START3+56] 1.5 $VL
i "RandomMove" [$START3+60] 2 $VL
i "RandomMove" [$START3+65] 1 $VL
i "RandomMove" [$START3+67] 0.5 $VL
i "RandomMove" [$START3+74] 2.5 $VL
            '''
    elif instrument=="$VC":
            lines += '''
i "RandomMove" [$START3+10] 2 $VC
i "RandomMove" [$START3+13] 1.5 $VC
i "RandomMove" [$START3+19] 2.5 $VC
i "RandomMove" [$START3+27] 0.5 $VC
i "RandomMove" [$START3+28] 2 $VC
i "RandomMove" [$START3+31] 1.5 $VC
i "RandomMove" [$START3+35] 2 $VC
i "RandomMove" [$START3+44] 1.5 $VC
i "RandomMove" [$START3+46] 1 $VC
i "RandomMove" [$START3+50] 1.5 $VC
i "RandomMove" [$START3+54] 1 $VC
i "RandomMove" [$START3+57] 2 $VC
i "RandomMove" [$START3+60] 1.5 $VC
            '''
    return lines

def section(no):
    score = "; PART 1 ----------"
    score += "\n; FLUTE\n"
    if no==1:
        resetFreeInstruments()
        instrument = getInstrument()
        print("Section 1:", instrument["macro"])
        degree = random.randint(5,15)
        if random.random()>0.5:
            degree = -degree
        data.firstDegree = degree # later for last instrumenthind
        if abs(degree)==15:
            degree += 180 # on some rare cases move to back
        width = 20
        size = 0.6 # reverb
        wet = 0.1 # võibolla kitsa puhl suurem
        elevation = random.randint(20, 60)
        scoreLines = '''i "StereoSound" 0 1 %s %d %d %.2f %.2f %d\n''' % (instrument["macro"], degree, width, size, wet, elevation)
        data.lastInstrument = instrument
        data.lastStartTime = 0
    if no==2: #rand instr 1
        instrument = getInstrument()
        print("Section 2: ", instrument["macro"])
        #print(firstDegree)
        degree = random.randint(30,60)
        if data.firstDegree>=0: # if flute was right, move clarinet to left
            degree = -degree
        width = 60
        size = 0.8 # reverb
        wet = 0.1
        elevation = random.randint(20, 60)
        print(data.lastInstrument["macro"], data.lastInstrument["follows"][instrument["macro"]])
        startTime = data.lastStartTime + data.lastInstrument["follows"][instrument["macro"]]
        scoreLines = '''i "StereoSound" %.1f 1 %s %d %d %.2f %.2f %d\n''' % (startTime, instrument["macro"], degree, width, size, wet, elevation)
        changeDuration = instrument["duration"] -10
        endWidth = random.randint(70, 120)
        scoreLines += '''i "CenterAndWidthTo" ^+10 %d %s %d %d\n''' % (changeDuration, instrument["macro"], -degree, endWidth) # move to the other side and make stereo wider
        data.lastInstrument = instrument
        data.lastStartTime = startTime

    if no==3: #random instr 2
        instrument = getInstrument()
        print("Section 3: ", instrument["macro"])
        #i "StereoSound" [65+91] 1 $VL 0 90 0.7 0.5 ; try shorter reverb but more wet
        # i "RandomChange" [65+91] 60 $VL
        degree = 0
        width = 90
        size = 0.7 # reverb
        wet = 0.5
        elevation = random.randint(20, 60)
        startTime = data.lastStartTime + data.lastInstrument["follows"][instrument["macro"]]
        scoreLines = '''i "StereoSound" %.1f 1 %s %d %d %.2f %.2f %d\n''' % (startTime, instrument["macro"], degree, width, size, wet, elevation)
        scoreLines += getRandomChange(instrument["macro"], startTime)
        data.lastInstrument = instrument
        data.lastStartTime = startTime

    if no==4: # piano
        print("Section 3: ", piano["macro"])
        #  i "StereoSound" [65+91+78] 1 $PF 0 40 0.7 0.1
        # i "CenterAndWidthTo" ^+20 100  $PF 0 180
        degree = 0
        width = 40
        size = 0.7 # reverb
        wet = 0.1
        elevation = 30
        changeDuration = piano["duration"] - 25 # -start -5 second stable time from the end
        startTime = data.lastStartTime + data.lastInstrument["follows"]["$PF"]
        scoreLines = '''i "StereoSound" %.1f 1 $PF %d %d %.2f %.2f %d\n''' % (startTime, degree, width, size, wet, elevation)
        scoreLines += '''i "CenterAndWidthTo" ^+20 %d $PF 0 180\n''' % (changeDuration) # slowly wider
        data.lastInstrument = piano
        data.lastStartTime = startTime

    if no==5: # ensemble -  part 2 starts here, score starts again from 0
        # 4 instruments in four corners
        melodyInstruments = [flute, clarinet, violin, cello]
        random.shuffle(melodyInstruments)
        degrees = [-20, 20, -150, 150]
        elevations = [60, 60, -20, -20]
        scoreLines = ""
        for i in range(4):
            scoreLines +=  '''i "MonoSound" 0 1 %s %d %d  \n''' % (melodyInstruments[i]["macro"], degrees[i], elevations[i])
        scoreLines += '''i "StereoSound" 0 1 [100+$PF] 0 90 \n''' # piano always on one sport

        # perc -  various layers (instrument) on different positions and heights
        percIndexes = [1, 2, 3, 4, 5]
        random.shuffle(percIndexes)
        scoreLines += '''i "StereoSound" 0 1 [100+$PERC] 180 60  \n''' # 1 is set, no random position
        scoreLines += '''i "StereoSound" 0 1 [100+$PERC+%d] 180 50  \n''' % (percIndexes[0])
        scoreLines += '''i "StereoSound" 0 1 [100+$PERC+%d] 180 40  \n''' % (percIndexes[1])
        scoreLines += '''i "StereoSound" 0 1 [100+$PERC+%d] 0 40  \n''' % (percIndexes[2])
        scoreLines += '''i "StereoSound" 0 1 [100+$PERC+%d] 0 50 0.6 0.2 90 \n''' % (percIndexes[3])
        scoreLines += '''i "StereoSound" 0 1 [100+$PERC+%d] 0 60  0.6 0.2 60\n''' % (percIndexes[4])
        scoreLines += '''i "CenterAndWidthTo" 10 110 [100+$PERC] -180 60 \n''' # slow full circle for layer 1


    if no==6: # old perc   TODO: perc should stay perhaps in the same position...
        #i "StereoSound" $PERC_START 1 [$PERC+6] 0 180
        #i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+6] 0 30
        #  different positions for layers every time. start wide, everything front slowly
        scoreLines = '''#define PERC_START #%d#\n''' % (data.percStart)
        scoreLines += '''i "StereoSound" $PERC_START 1 $PERC 0 180 0.6 0.15 30  0.6 \n''' # last parameter -  amplitude correction. Somewhat softer this one.
        scoreLines += '''i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+6] 0 30 \n'''

        data.lastInstrument = percussion
        data.lastStartTime = data.percStart

    if no==7: # last leftover
        if (len(data.freeInstruments)!=1):
            print("Warning: Should have only 1 instrument left!")
        instrument = getInstrument()
        print("Section 7: ", instrument["macro"])
        degree = -data.firstDegree
        width = 20
        size = 0.6 # reverb
        wet = 0.1
        elevation = random.randint(20, 40)
        startTime = data.lastStartTime + percussion["nextVoiceTime"]
        scoreLines = '''i "StereoSound" %.1f 1 %s %d %d %.2f %.2f %d\n''' % (startTime, instrument["macro"], degree, width, size, wet, elevation)


    #print(scoreLines)
    return scoreLines

def getAndIncreaseLastVersion():
    file = open("fileCounter", "r+")
    count = 0
    for line in file:
        print(line)
        if line.startswith("nextVersion"):
            count = int(line.split("=")[1]) # no type control but it is fixed  this way
            print(count)
    if count>0:
        file.flush()
        file.seek(0)
        file.write( "nextVersion="+str(count+1) )
    file.close()        
    return count


def generate():
    #get fileCounter from file fileCounter and later write it
    
    counter = getAndIncreaseLastVersion();
    print("Counter: ",counter)
    
    scoreStart = '''
#define FL #0#
#define CL #1#
#define VL #2#
#define VC #3#
#define PF #4#
#define PERC #5#  

    '''
    
    part1 = scoreStart + section(1) + section(2) + section(3) + section(4)
    part2 = scoreStart + section(5) + section(6) + section(7)
    
    print(part1, part2)
    
    scoName1 = "sco/vaatenurk-I-%s.sco" % (counter)
    scoName2 = "sco/vaatenurk-II-%s.sco" % (counter)
    
    print(scoName1, scoName2)
    file = open(scoName1, "w")
    file.write(part1)
    file.close()
    file2 = open(scoName2, "w")
    file2.write(part2)
    file2.close()
    
    time.sleep(1) # waid-a-minit!
    
    
    #Csound commands
    csoundCommand1 = '''csound -o output/%d-I.wav vaatenurk.orc %s''' % (counter, scoName1)
    lameCommand1 = '''lame -b 192 output/%d-I.wav output/%d-I.mp3''' % (counter, counter)
    removeCommand1 = '''rm output/%d-I.wav''' % (counter)
    # and then remove wav
    print (csoundCommand1, lameCommand1, removeCommand1)
    os.system(csoundCommand1 + " && " + lameCommand1 + " && " + removeCommand1) # + remove
    
    csoundCommand2 = '''csound -o output/%d-II.wav vaatenurk.orc %s''' % (counter, scoName2)
    lameCommand2 = '''lame -b 192 output/%d-II.wav output/%d-II.mp3''' % (counter, counter)
    removeCommand2 = '''rm output/%d-II.wav''' % (counter)
    # and then remove wav
    print (csoundCommand2, lameCommand2, removeCommand2)
    os.system(csoundCommand2 + " && " + lameCommand2 + " && " + removeCommand2) # + remove
    

# main --------
generate()
#print(section(1))
#print(section(2))
#print(section(3))
