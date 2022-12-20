<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
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

gkAzimuth[] init 16 ; for all 6 players + ens
gkElevation[] init 16
gkCenter[] init 16 ; center of stereo
gkWidth[] init 16; stereo width

; vana
;gSEnsembleParts[] fillarray "Vaatenurk_FLUTE-St.wav", "Vaatenurk_CLARINET-St.wav", "Vaatenurk_VIOLIN-St.wav", "Vaatenurk_CELLO-St.wav", "Vaatenurk_PIANO-St.wav", "Vaatenurk_PERC ALL-St.wav", "Vaatenurk_PERC A-St.wav", "Vaatenurk_PERC B-St.wav", "Vaatenurk_PERC C-St.wav", "Vaatenurk_PERC D-St.wav", "Vaatenurk_PERC E-St.wav", "Vaatenurk_PERC F-St.wav"

; perc kihid kopeeritud vanast
gSEnsembleParts[] fillarray "U_Vaatenurk-ENS-Flute.wav", "U_Vaatenurk-ENS-Clarinet.wav","U_Vaatenurk-ENS-Violin.wav", "U_Vaatenurk-ENS-Cello.wav", "U_Vaatenurk-ENS-Piano.wav", "Vaatenurk_PERC A-St.wav", "Vaatenurk_PERC B-St.wav", "Vaatenurk_PERC C-St.wav", "Vaatenurk_PERC D-St.wav", "Vaatenurk_PERC E-St.wav", "Vaatenurk_PERC F-St.wav", 
"U_Vaatenurk-ENS-Perc.wav"


;gSSolos[] fillarray "Vaatenurk_SOOLO_FLUTE-St.wav", "Vaatenurk_SOOLO_CLARINET-St.wav", "Vaatenurk_SOOLO_VIOLIN-St.wav", "Vaatenurk_SOOLO_CELLO-St.wav",  "Vaatenurk_SOOLO_PIANO-St.wav",    "Vaatenurk_SOOLO_PERC A-St.wav" , "Vaatenurk_SOOLO_PERC B-St.wav", "Vaatenurk_SOOLO_PERC C-St.wav",   "Vaatenurk_SOOLO_PERC D-St.wav", 
;"Vaatenurk_SOOLO_PERC E-St.wav", "Vaatenurk_SOOLO_PERC G-St.wav"

; uus
gSSolos[] fillarray "U_Vaatenurk-SOLO-Flute-3.wav", "U_Vaatenurk-SOLO-Clarinet-3.wav", "U_Vaatenurk-SOLO-Violin-3.wav", "U_Vaatenurk-SOLO-Cello-3.wav", "U_Vaatenurk-SOLO-Piano-3.wav",  
"Vaatenurk_SOOLO_PERC A-St.wav" , "Vaatenurk_SOOLO_PERC B-St.wav", "Vaatenurk_SOOLO_PERC C-St.wav",   "Vaatenurk_SOOLO_PERC D-St.wav", "Vaatenurk_SOOLO_PERC E-St.wav", "Vaatenurk_SOOLO_PERC G-St.wav", 
"U_Vaatenurk-SOLO-Perc-3.wav"

giNextVoiceTime[] fillarray 65, 91, 78, 62, 0, 67  ; in seconds - time when the next voice enters. 0 if nothing follows

giFirstEnsembleTable = 100
giFirstSoloTable = 200

gaL init 0
gaR init 0

;schedule "LoadAudio", 0,0 - takes ages to load.. don't use
instr LoadAudio ; into tables
	index = 0
	while index < lenarray(gSEnsembleParts) do
		iTable ftgen giFirstEnsembleTable+index,0, 0, 1, gSEnsembleParts[index], 0,0,0
		index += 1
	od
	index = 0
	while index < 5 do
		iTable ftgen giFirstSoloTable+index,0, 0, 1, gSSolos[index], 0,0,0
		index += 1
	od
endin

instr RandomChange
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
  
  ; later - put it back, for individual spread
  ; for now global reverb
  ;aReverbL, aReverbR freeverb (aL1+aL2)*kWet, (aR1+aR2)*kWet, kSize, 0.6 
  ;outs	(aL1+aL2+aReverbL)*aDeclick, (aR1+aR2+aReverbR)*aDeclick 
  
 
 
  ; reverb test - ei toimi Liikumisel kuigi hästi
 	  
;  	kx = 5 + lfo(4,1/10)
; 	
; 	 ;early reflections, room default 1
;  aearlyl,aearlyr, irt60low, irt60high, imfp hrtfearly aL, kx, 5, 1, 5, 1, 1, "hrtf-44100-left.dat", "hrtf-44100-right.dat", 3 ; -  see tekitab topeltküla
;
;  ;later reverb, uses outputs from above
;  arevl, arevr, idel hrtfreverb aL, irt60low, irt60high, "hrtf-44100-left.dat", "hrtf-44100-right.dat", 44100, imfp
;  idel = 0.001
;  print idel
;  
;  
;  	;delayed and scaled
;  alatel delay arevl * .1, idel
;  alater delay arevr * .1, idel  
;
;  ;outs	aearlyl + alatel, aearlyr + alater ; annab natuke topelt soundi
;  ;outs	aearlyl+arevl*0.1, aearlyr+arevr*0.1 
endin


instr MonoSound
	index = p4 ; index of the instrument
  iAzimuth = p5
  iElevation = p6
  iAmpCorrection = p7==0 ? 1 : p7

  
  SFile strcat  "tracks/",gSEnsembleParts[index] 
  prints SFile
  
  p3 filelen SFile
  
  gkAzimuth[index] init iAzimuth
  gkElevation[index] init iElevation
  
  //port?
  
  ;aL, aR loscil 1,1,1, giFirstEnsembleTable+index, 1
   
	aL, aR diskin2 SFile, 1, 0, 1 ; loading OGG makes a click... and --realtime does not work here...
	aSignal = aL+aR
  ;aSignal oscili 0.1, random:i(100, 600)
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
	
 kWet chnget "wet"
 kSize chnget "size"
	  
 aReverbL, aReverbR freeverb gaL*kWet, gaR*kWet, kSize, 0.6
 outs aReverbL, aReverbR
 clear gaL, gaR

endin


</CsInstruments>
<CsScore>
; score macros must be redefined
#define FL #0#
#define CL #1#
#define VL #2#
#define VC #3#
#define PF #4#
#define PERC #5#

; for testing



; perc test

#define PERC_START #0#
; stereo
i "StereoSound" $PERC_START 1 [$PERC+6] 0 180
i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+6] 0 30
;  
;i "StereoSound" $PERC_START 1 [$PERC+4] 0 120  
;i "StereoSound" $PERC_START 1 [$PERC+0] 0 90  
;i "StereoSound" $PERC_START 1 [$PERC+2] 0 260  
;i "StereoSound" $PERC_START 1 [$PERC+1] 0 60  
;i "StereoSound" $PERC_START 1 [$PERC+3] 0 50  
;i "StereoSound" $PERC_START 1 [$PERC+5] 0 40 0.6 0.15 90  
;i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+4] 0 30 
;i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+0] 0 30 
;i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+2] 0 30 
;i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+1] 0 30 
;i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+3] 0 30 
;i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC+5] 0 30 
;i "StereoSound" 189 1 $VL 12 20 0.60 0.10 27


s



; part I ---------------------------------------------------
;a 0 0 [65+91]
;x
; 1 flute 
i "StereoSound" 0 1 $FL -10 20 0.6 0.1

; 2 clarinet
i "StereoSound" 65 1 $CL 30 60 0.8 0.1 ; clarinet duration ca 95 sec VÕIKS OLLA KÕRGEMAL - 60 vms
i "CenterAndWidthTo" ^+10 80 $CL -30 180

i "StereoSound" [65+91] 1 $VL 0 90 0.7 0.5 ; try shorter reverb but more wet
i "RandomChange" [65+91] 60 $VL  
;
i "ElevationTo" ^+10 $VL 1 -20
i "ElevationTo" ^+10 $VL 5 70
i "ElevationTo" ^+10 $VL 1 -30
i "ElevationTo" ^+10 $VL 5 30

i "StereoSound" [65+91+78] 1 $PF 0 40 0.7 0.1
i "CenterAndWidthTo" ^+20 100  $PF 0 180
;i "StereoSound" 0 999 $PF 0 45 0 0 60 ; proovsin topelt aga pole vist hea

s
; second part -------------------------------------

; ensemble



i "MonoSound" 0 1 $VL -30 30
i "MonoSound" 0 1 $FL 30 30
i "MonoSound" 0 1 $VC -150 0
i "MonoSound" 0 1 $CL 150 0

i "StereoSound" 0 1 [100+$PF] 0 90;120
i "StereoSound" 0 1 [100+$PERC+1] 180 60 ; perc A +1, B +2 etc 
i "StereoSound" 0 1 [100+$PERC+2] 180 50
i "StereoSound" 0 1 [100+$PERC+3] 180 40
i "StereoSound" 0 1 [100+$PERC+4] 0 40 
i "StereoSound" 0 1 [100+$PERC+5] 0 50 0.6 0.2 90 ; top
i "StereoSound" 0 1 [100+$PERC+6] 0 60 0.6 0.2 60 ; high

; movements? tryout: full circle of some perc layers?
i "CenterAndWidthTo" ^+10 110 [100+$PERC+1] -180 60 ; full circle - seems to work well


; 6 Perc solo
; try similar setting but opposite, perhaps even less reverb
#define PERC_START #120# ; 120 seconds is the ensemble part

; start wide, everything front slowly come closer - track 67 sec.
i "StereoSound" $PERC_START 1 [$PERC] 0 120 ; perc A +1, B +2 etc 
i "StereoSound" . 1 [$PERC+1] 0 90
i "StereoSound" . 1 [$PERC+2] 0 260 ; so wide that it is back
i "StereoSound" . 1 [$PERC+3] 0 60 
i "StereoSound" . 1 [$PERC+4] 0 50 
i "StereoSound" . 1 [$PERC+5] 0 40 0.6 0.15 90

i "CenterAndWidthTo" [$PERC_START+10] 50 [$PERC] 0 30
i "CenterAndWidthTo" . . [$PERC+1] 0 30
i "CenterAndWidthTo" . . [$PERC+2] 0 30
i "CenterAndWidthTo" . . [$PERC+3] 0 30
i "CenterAndWidthTo" . . [$PERC+4] 0 30
i "CenterAndWidthTo" . . [$PERC+5] 0 30


; 7 cello solo
i "StereoSound" [$PERC_START+67] 1 $VC 10 20 0.6 0.1




e

;

; syntax to call and instrument:
;i "Sound" start dur INSTR azimuth elevation ; duration will be set by the length of the file, can be left 1
;i "MoveTo" start dur INSTR toAzimuth toElevation
; azimuth in degrees 0 -  front, -90 left, 90 - rigthm -180/180 back
; elevation in -40..90



</CsScore>
</CsoundSynthesizer>












<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>318</width>
 <height>358</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
 <bsbObject version="2" type="BSBKnob">
  <objectName>center</objectName>
  <x>55</x>
  <y>97</y>
  <width>80</width>
  <height>80</height>
  <uuid>{de672f87-51f6-427e-b12f-701ae2181008}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-180.00000000</minimum>
  <maximum>180.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>width</objectName>
  <x>149</x>
  <y>98</y>
  <width>80</width>
  <height>80</height>
  <uuid>{ac228dd4-a0de-4d54-9bde-12a30debfcef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>180.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>57</x>
  <y>183</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4b166ce3-2221-48d0-8853-2145eabbeb6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Center</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>148</x>
  <y>183</y>
  <width>80</width>
  <height>25</height>
  <uuid>{f5ce1322-407c-45ad-a7dc-bf6f262d525f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Width</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>wet</objectName>
  <x>159</x>
  <y>248</y>
  <width>80</width>
  <height>80</height>
  <uuid>{b86ef4c4-bc24-423b-b988-c5ab96f9c039}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.50000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>162</x>
  <y>333</y>
  <width>80</width>
  <height>25</height>
  <uuid>{d8ac1648-10b3-4daf-859d-2c6fdae90871}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Wet</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>size</objectName>
  <x>60</x>
  <y>246</y>
  <width>80</width>
  <height>80</height>
  <uuid>{f1d3c03b-48e8-45b8-830a-6c38ad3d8bd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.70000000</value>
  <mode>lin</mode>
  <mouseControl act="">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
  <color>
   <r>245</r>
   <g>124</g>
   <b>0</b>
  </color>
  <textcolor>#512900</textcolor>
  <border>0</border>
  <borderColor>#512900</borderColor>
  <showvalue>true</showvalue>
  <flatstyle>true</flatstyle>
  <integerMode>false</integerMode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>63</x>
  <y>331</y>
  <width>80</width>
  <height>25</height>
  <uuid>{174c1beb-7fbb-4951-a784-99e58f3d59d9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Size</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>53</x>
  <y>55</y>
  <width>175</width>
  <height>24</height>
  <uuid>{e7730774-34ce-4fca-a220-dfe046ff62ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Solo position and stereo width</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>56</x>
  <y>219</y>
  <width>80</width>
  <height>25</height>
  <uuid>{4cada019-15ec-4241-837f-d79cf4b6ca61}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Reverb</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>elevation</objectName>
  <x>254</x>
  <y>96</y>
  <width>19</width>
  <height>84</height>
  <uuid>{83701d56-9ef1-4e19-981e-a4c51d30a978}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>-40.00000000</minimum>
  <maximum>90.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>238</x>
  <y>185</y>
  <width>80</width>
  <height>25</height>
  <uuid>{e16cc3bf-1511-46ab-82ba-732a29191155}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <label>Elevation</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>false</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
