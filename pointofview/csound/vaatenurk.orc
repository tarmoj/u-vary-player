
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

;;channels
chn_k "elevation",3
chn_k "wet",3
chn_k "size",3
chn_k "width",3
chn_k "center",3

#define FL #0#
#define CL #1#
#define VL #2#
#define VC #3#
#define PF #4#
#define PERC #5#
#define TUTTI #6# ; ensemble take but that should be stero

gkAzimuth[] init 14 ; for all 6 players + ens
gkElevation[] init 14
gkCenter[] init 14 ; center of stereo
gkWidth[] init 14; stereo width


gSEnsembleParts[] fillarray "U_Vaatenurk-ENS-FLUTE.wav", "U_Vaatenurk-ENS-CLARINET.wav","U_Vaatenurk-ENS-VIOLIN.wav", "U_Vaatenurk-ENS-CELLO.wav", "U_Vaatenurk-ENS-PIANO.wav", "U_Vaatenurk-ENS-PERC A.wav", "U_Vaatenurk-ENS-PERC B.wav", "U_Vaatenurk-ENS-PERC C.wav", "U_Vaatenurk-ENS-PERC D.wav", "U_Vaatenurk-ENS-PERC E.wav", "U_Vaatenurk-ENS-PERC F.wav"

gSSolos[] fillarray "U_Vaatenurk-FLUTE.wav", "U_Vaatenurk-CLARINET.wav", "U_Vaatenurk-VIOLIN.wav", "U_Vaatenurk-CELLO.wav", "U_Vaatenurk-PIANO.wav", "U_Vaatenurk-PERC ALL.wav" 


giNextVoiceTime[] fillarray 65, 91, 78, 62, 0, 67  ; in seconds - time when the next voice enters. 0 if nothing follows

giFirstEnsembleTable = 100
giFirstSoloTable = 200

gaL init 0
gaR init 0


instr RandomChange ; use metro to generate random changes in random intervals
	iDuration = p3
	index = p4>=100 ? p4-100 : p4 ; perhaps negative when channel must be used
	
	; TODO - change only during silence (folllow2 or rms with port... )
	kRate1 init 1/8
	if (metro(kRate1,0.001)==1) then ;
		kCenterChange random -160, 160 
		kWidthChange random 40, 180
		if kWidthChange<90 then
			kWidthChange = 0
		endif
		kDuration random 0.25,0.6 ; nomrally fast change
		if abs(kCenterChange)<60 then ; if smaller than 60, set to 0
			kCenterChange = 0
			kDuration random 2,4
		endif
		;kCenter wrap chnget:k("center") + kCenterChange, -180, 180
		;kWidth wrap chnget:k("center") + kWidthChange, 0, 180
		kCenter = gkCenter[index] + kCenterChange, -180, 180
		kWidth wrap gkWidth[index] + kWidthChange, 0, 180 
		printf "New center : %f width: %f duration %f\n", timeinstk(), kCenter, kWidth, kDuration
		schedulek "CenterAndWidthTo",0, kDuration, index, kCenter, kWidth
		kRate1 random 1/8, 1/2
		printk2 kRate1
	endif
	
	; elevation changes
	kRate2= 1/10
	if (metro(kRate2, 0.001)==1) then
		kElevationChange random 20, 40
		if (rand:k(1)>=0.5) then 
			kElevationChange = -kElevationChange
		endif
		kElevation wrap gkElevation[index] + kElevationChange, -40, 80
		kDur random 1, 3
		printf "New elevation : %f %f\n", timeinstk(), kElevation, kDur

		schedulek "ElevationTo", 0, kDur, index, kElevation
	
	endif
	
endin

instr RandomMove
	iDuration = p3
	index = p4>=100 ? p4-100 : p4 ;
	iCenterChange random -160, 160 
	iWidthChange random 40, 180
	if iWidthChange<90 then
		iWidthChange = 0
	endif
	if abs(iCenterChange)<60 then ; if smaller than 60, set to 0
		iCenterChange = 0
	endif

	iCenter wrap i(gkCenter,index) + iCenterChange, -180, 180
	iWidth wrap i(gkWidth,index) + iWidthChange, 0, 180 
	printf_i "New center : %f width: %f duration %f\n", 1, iCenter, iWidth, iDuration
	schedule "CenterAndWidthTo",0, iDuration, index, iCenter, iWidth	
endin

instr CenterAndWidthTo
	iDuration = p3
	index = p4>=100 ? p4-100 : p4
	iEndCenter = p5
	iEndWidth = p6
	
	;kCenter line chnget:i("center"), iDuration, iEndCenter
	;kWidth line chnget:i("width"), iDuration, iEndWidth
	
	;chnset kCenter, "center"
	;chnset kWidth, "width"	
	
	kCenter line i(gkCenter, index), iDuration, iEndCenter
	kWidth line i(gkWidth,index), iDuration, iEndWidth

	gkCenter[index] = kCenter 
	gkWidth[index] = kWidth
	
endin

instr ElevationTo
	iDuration = p3
	index = p4>=100 ? p4-100 : p4
	iEndElevation = p5
	
;	kElevation line chnget:i("elevation"), iDuration, iEndElevation
;	
;	chnset kElevation, "elevation"	
	kElevation line i(gkElevation, index), iDuration, iEndElevation	
	gkElevation[index] = kElevation

endin




instr StereoSound ; tryout for solos
		index = p4>=100 ? p4-100 : p4; index of the instrument if greater than 100, use ensemblepart, otherwise solo
	iCenter = p5
	iWidth = p6
	iReverbSize = p7>0 ? p7 : 0.6
  iReverbWet = p8>0 ? p8 : 0.1
  iElevation = p9>0 ? p9 :30
  iAmpCorrection = p10==0 ? 1 : p10
  print iAmpCorrection
  
  iUseChannel = 0 ; set 1 for testing with sliders 0 otherwise
  
  ; now outside of condition, one globar reverb
  chnset iReverbSize, "size"
	chnset iReverbWet, "wet"
  
  
  ;try version with no channel change (For Piano) - set p3 to 999 for that
  ;iNoChannelChange = p3==999 ? 1: 0 ; did not give any result
  
  
  if iUseChannel==1 then
	  	chnset iCenter, "center"
	  	chnset iWidth, "width"
	  chnset iReverbSize, "size"
	  chnset iReverbWet, "wet"
	  chnset iElevation, "elevation"
	else 
		gkCenter[index] init iCenter
		gkWidth[index] init iWidth
		gkElevation[index] init iElevation	  
	endif

	
	SFile strcat  "tracks/", p4>100 ? gSEnsembleParts[index] : gSSolos[index]
	prints SFile
  
  p3 filelen SFile
  
   
  aL, aR diskin2 SFile, 1, 0, 1
  
  if iUseChannel==1 then
	  kCenter chnget "center"
	  kWidth chnget "width"
	  
	  kAzimuth1 = kCenter + kWidth/2
	 	kAzimuth2 = kCenter - kWidth/2
	 	kElevation1 chnget "elevation"
	 	kElevation2 = kElevation1 ; - perhasp use tilt or rotation for the channels
	 	;kWet chnget "wet"
	  ;kSize chnget "size"
  else 
  		kCenter = gkCenter[index]
	  kWidth = gkWidth[index]
	  
	  kAzimuth1 = kCenter + kWidth/2
	 	kAzimuth2 = kCenter - kWidth/2
	 	kElevation1 = gkElevation[index]
	 	kElevation2 = kElevation1 ; - perhasp use tilt or rotation for the channels
	 	;kWet init iReverbWet ; still: move reverb to master
	  ;kSize init iReverbSize
  	
  endif
 	 	
  aL1,aR1 hrtfmove2 aL, kAzimuth1 , kElevation1, "hrtf-44100-left.dat","hrtf-44100-right.dat"
  aL2,aR2 hrtfmove2 aR, kAzimuth2 , kElevation2, "hrtf-44100-left.dat","hrtf-44100-right.dat"
  aDeclick linen 1,0.1, p3, 0.1
  
  aOutL = (aL1+aL2)*aDeclick*iAmpCorrection
  aOutR = (aR1+aR2)*aDeclick*iAmpCorrection
  outs aOutL, aOutR
  gaL += aOutL
  gaR += aOutR
   
endin


instr MonoSound
	index = p4 ; index of the instrument
  iAzimuth = p5
  iElevation = p6
  
  SFile strcat  "tracks/",gSEnsembleParts[index] 
  prints SFile
  
  p3 filelen SFile
  
  gkAzimuth[index] init iAzimuth
  gkElevation[index] init iElevation
  
   
	aL, aR diskin2 SFile, 1, 0, 1 ; loading OGG makes a click... and --realtime does not work here...
	aSignal = aL+aR

  aSignal *= linen:a(1, 0.1, p3, 0.1) 
  
  aleft,aright hrtfmove2 aSignal, gkAzimuth[index] , gkElevation[index] , "hrtf-44100-left.dat","hrtf-44100-right.dat"
	
	outs	aleft, aright 
	gaL += aleft
	gaR += aright
	
endin

instr MoveTo
	iDuration = p3
	index = p4
	iEndAzimuth = p5
	iEndElevation = p6
	
	gkAzimuth[index] line i(gkAzimuth, index), iDuration, iEndAzimuth
endin

schedule "Reverb",0, -1

instr Reverb
 ; NB! --------------- FIXED FOR TESTING ------------------- 	PUT BACK!
 kWet chnget "wet"
 kSize chnget "size"
 ;kWet init 0.1
 ;kSize init 0.7
	  
 aReverbL, aReverbR freeverb gaL*kWet, gaR*kWet, kSize, 0.6
 outs aReverbL, aReverbR
 clear gaL, gaR

endin
 
