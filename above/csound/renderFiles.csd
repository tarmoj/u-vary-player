<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

gaR init 0
gaL init 0

giPan = 0
giVolume = -6

instr Player
	SFile strget p4
	iVolume = p5 ; in db
	iPan = p6
	p3 = 7*60+56;filelen SFile
	
	
	
	aL, aR mp3in SFile
	
	; gain Calculation
	
	if (iPan <= 0) then
    ix = iPan + 1;
	else
    ix = iPan;
	endif
	
	iGainL = cos(ix * $M_PI / 2);
  iGainR = sin(ix * $M_PI / 2);
	
	iAmp = 0.6* ampdbfs(iVolume)
	if (iPan <= 0)  then
    aoutputL = aL + aR * iGainL;
    aoutputR = aR * iGainR;
  else 
    aoutputL = aL * iGainL;
    aoutputR = aR + aL * iGainR;
	endif
	
	gaL += aoutputL*iAmp
	gaR += aoutputR*iAmp
	
endin

;alwayson "Reverb"
instr Out
	SOutFile sprintf "../versions/above%d.wav", p4
	prints SOutFile

kWet init 0.1
kSize init 0.7

	  
 aReverbL, aReverbR freeverb gaL*kWet, gaR*kWet, kSize, 0.6
 outs (gaL+aReverbL), (gaR+aReverbR)
 fout SOutFile, 4, (gaL+aReverbL), (gaR+aReverbR)
 clear gaL, gaR
 
 if (metro(1)==1) then
 	printk 0, int(timeinsts())
 endif

endin


</CsInstruments>
<CsScore>

; score lines generated with csoundScore() in above.js

x
; Vibraphone + Clarinet
i "Player" 0 1 "../tracks/Above_VIBR 1 VC 1-St.mp3" 0 -0.4
i "Player" 0 1 "../tracks/Above_Clar 1 VC 2-St.mp3" -10 0
i "Player" 0 1 "../tracks/Above_VIBR 2 VC 3-St.mp3" 0 -0.4
i "Player" 0 1 "../tracks/Above_VIBR 3 VC 4-St.mp3" 0 0.4
i "Player" 0 1 "../tracks/Above_VIBR 4 VC 5-St.mp3" 0 0.4
i "Player" 0 1 "../tracks/Above_Clar 4 VC 6-St.mp3" -10 0
i "Out" 0 [7*60+56] 1
s
 
x
; Full Ensemble 1
i "Player" 0 1 "../tracks/Above_VLN 1 VC 1-St.mp3" -10 -0.44
i "Player" 0 1 "../tracks/Above_Clar 1 VC 2-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_VIBR 2 VC 3-St.mp3" 0 0.44
i "Player" 0 1 "../tracks/Above_Cello 2 VC 4-St.mp3" -15 0.1
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -15 -0.34
i "Player" 0 1 "../tracks/Above_Synth 3 VC 6-St.mp3" -5 0.34
i "Out" 0 [7*60+56] 2
s 


; Wind
i "Player" 0 1 "../tracks/Above_FL 1 VC 1-St.mp3" -5 0
i "Player" 0 1 "../tracks/Above_Clar 1 VC 2-St.mp3" -5 -0.2
i "Player" 0 1 "../tracks/Above_Cello 1 VC 3-St.mp3" -10 0.44
i "Player" 0 1 "../tracks/Above_FL 4 VC 4-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_Cello 3 VC 5-St.mp3" -10 -0.44
i "Player" 0 1 "../tracks/Above_Clar 4 VC 6-St.mp3" 0 0.2
i "Out" 0 [7*60+56] 3
s 

; Full Ensemble 2
i "Player" 0 1 "../tracks/Above_VIBR 1 VC 1-St.mp3" -14 0
i "Player" 0 1 "../tracks/Above_Clar 1 VC 2-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_FL 3 VC 3-St.mp3" -10 -0.3
i "Player" 0 1 "../tracks/Above_VLN 3 VC 4-St.mp3" -20 0.3
i "Player" 0 1 "../tracks/Above_Synth 2 VC 5-St.mp3" -20 0.3
i "Player" 0 1 "../tracks/Above_Cello 4 VC 6-St.mp3" -20 -0.3
i "Out" 0 [7*60+56] 4
s 

; Synth
i "Player" 0 1 "../tracks/Above_Synth 1 VC 1-St.mp3" -10 0.16
i "Player" 0 1 "../tracks/Above_Synth 4 VC 2-St.mp3" -10 0
i "Player" 0 1 "../tracks/Above_VIBR 2 VC 3-St.mp3" 0 0.44
i "Player" 0 1 "../tracks/Above_VIBR 3 VC 4-St.mp3" 0 0.44
i "Player" 0 1 "../tracks/Above_Synth 3 VC 6-St.mp3" -10 0
i "Out" 0 [7*60+56] 5
s 

; Full Ensemble 3
i "Player" 0 1 "../tracks/Above_VIBR 1 VC 1-St.mp3" -6 0
i "Player" 0 1 "../tracks/Above_Synth 4 VC 2-St.mp3" -8 -0.45
i "Player" 0 1 "../tracks/Above_Cello 1 VC 3-St.mp3" -10 0.45
i "Player" 0 1 "../tracks/Above_FL 4 VC 4-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -20 -0.34
i "Player" 0 1 "../tracks/Above_Clar 4 VC 6-St.mp3" 0 0.34
i "Out" 0 [7*60+56] 6
s 

; Fl + Cl + Vibr + Vlc
i "Player" 0 1 "../tracks/Above_FL 1 VC 1-St.mp3" 0 -0.08
i "Player" 0 1 "../tracks/Above_Clar 1 VC 2-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_FL 3 VC 3-St.mp3" -8 0
i "Player" 0 1 "../tracks/Above_Clar 2 VC 4-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_VIBR 4 VC 5-St.mp3" 0 0
i "Player" 0 1 "../tracks/Above_Cello 4 VC 6-St.mp3" 0 0
i "Out" 0 [7*60+56] 7
s 

; Cello ensemble
i "Player" 0 1 "../tracks/Above_FL 1 VC 1-St.mp3" -10 -20
i "Player" 0 1 "../tracks/Above_Clar 1 VC 2-St.mp3" -10 0.4
i "Player" 0 1 "../tracks/Above_Cello 1 VC 3-St.mp3" -10.92 -0.1
i "Player" 0 1 "../tracks/Above_Cello 2 VC 4-St.mp3" -6.64 -0.1
i "Player" 0 1 "../tracks/Above_Cello 3 VC 5-St.mp3" -5.75 -0.2
i "Player" 0 1 "../tracks/Above_Cello 4 VC 6-St.mp3" -11.57 -0.4
i "Out" 0 [7*60+56] 8
s 

; Violin ensemble
i "Player" 0 1 "../tracks/Above_VLN 1 VC 1-St.mp3" -3.32 -0.2
i "Player" 0 1 "../tracks/Above_FL 2 VC 2-St.mp3" -6.5 -0.1
i "Player" 0 1 "../tracks/Above_VLN 2 VC 3-St.mp3" -7 -0.4
i "Player" 0 1 "../tracks/Above_VLN 3 VC 4-St.mp3" -10.3 0.1
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -10.2 0.4
i "Player" 0 1 "../tracks/Above_Synth 3 VC 6-St.mp3" -4.9 0.2
i "Out" 0 [7*60+56] 9
s 

; Flutes & Co
i "Player" 0 1 "../tracks/Above_FL 1 VC 1-St.mp3" -9.5 0.1
i "Player" 0 1 "../tracks/Above_FL 2 VC 2-St.mp3" -7 0.4
i "Player" 0 1 "../tracks/Above_FL 3 VC 3-St.mp3" -6 -0.1
i "Player" 0 1 "../tracks/Above_FL 4 VC 4-St.mp3" 6.3 -0.4
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -21 0.2
i "Player" 0 1 "../tracks/Above_Cello 4 VC 6-St.mp3" -19 0.2
i "Out" 0 [7*60+56] 10
s 

; Quartet
i "Player" 0 1 "../tracks/Above_VIBR 1 VC 1-St.mp3" -5 0.1
i "Player" 0 1 "../tracks/Above_FL 4 VC 4-St.mp3" -9 0.54
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -12 -0.36
i "Player" 0 1 "../tracks/Above_Cello 4 VC 6-St.mp3" 0 0.02
i "Out" 0 [7*60+56] 11
s 

; Synthy
i "Player" 0 1 "../tracks/Above_Synth 1 VC 1-St.mp3" -15 -0.54
i "Player" 0 1 "../tracks/Above_Synth 4 VC 2-St.mp3" -2 0.42
i "Player" 0 1 "../tracks/Above_VIBR 2 VC 3-St.mp3" -2 0.56
i "Player" 0 1 "../tracks/Above_VIBR 3 VC 4-St.mp3" -19 -0.3
i "Player" 0 1 "../tracks/Above_Synth 2 VC 5-St.mp3" -7 -0.22
i "Player" 0 1 "../tracks/Above_Synth 3 VC 6-St.mp3" -6 -0.52
i "Out" 0 [7*60+56] 12
s 

; Synthy 2
i "Player" 0 1 "../tracks/Above_Synth 1 VC 1-St.mp3" -6 0
i "Player" 0 1 "../tracks/Above_Synth 4 VC 2-St.mp3" -19 0
i "Player" 0 1 "../tracks/Above_Synth 3 VC 6-St.mp3" -13 0.32
i "Out" 0 [7*60+56] 13
s 

; E-bow
i "Player" 0 1 "../tracks/Above_KL VC 1.01-St.mp3" -3 0.2
i "Player" 0 1 "../tracks/Above_KL 1 VC 5.01-St.mp3" -3 -0.2
i "Out" 0 [7*60+56] 14
s 

; 2xVl + Vlc + other
i "Player" 0 1 "../tracks/Above_KL VC 1.01-St.mp3" -6 -0.08
i "Player" 0 1 "../tracks/Above_Synth 4 VC 2-St.mp3" 0 0.8
i "Player" 0 1 "../tracks/Above_Cello 1 VC 3-St.mp3" -3 0.38
i "Player" 0 1 "../tracks/Above_VLN 3 VC 4-St.mp3" -6 0.2
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -9 -0.2
i "Player" 0 1 "../tracks/Above_Clar 4 VC 6-St.mp3" 0 0
i "Out" 0 [7*60+56] 15
s 

</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
