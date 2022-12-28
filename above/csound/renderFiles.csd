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
	p3 filelen SFile
	print p3
	
	
	aL, aR mp3in SFile
	
	; gain Calculation
	
	if (iPan <= 0) then
    ix = iPan + 1;
	else
    ix = iPan;
	endif
	
	iGainL = cos(ix * $M_PI / 2);
  iGainR = sin(ix * $M_PI / 2);
	
	iAmp = ampdbfs(iVolume)
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

alwayson "Reverb"
instr Reverb

kWet init 0.1
kSize init 0.7

	  
 aReverbL, aReverbR freeverb gaL*kWet, gaR*kWet, kSize, 0.6
 outs (gaL+aReverbL), (gaR+aReverbR)
 clear gaL, gaR

endin


</CsInstruments>
<CsScore>
f 0 [7*60+58]
i "Player" 0 1 "../tracks/Above_VLN 4 VC 5-St.mp3" -6 -0.5
i "Player" 0 1 "../tracks/Above_FL 2 VC 2-St.mp3" -3 -0.3
i "Player" 0 1 "../tracks/Above_VIBR 2 VC 3-St.mp3" -12 -0.1
i "Player" 0 1 "../tracks/Above_VIBR 3 VC 4-St.mp3" -3 0.1
i "Player" 0 1 "../tracks/Above_Synth 2 VC 5-St.mp3" -9 0.3
i "Player" 0 1 "../tracks/Above_Clar 4 VC 6-St.mp3" -3 0.5

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
