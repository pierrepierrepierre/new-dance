(/* VU METRE & FREQSCOPE */ w.free; w = Window.new("Levels",Rect(0,Window.screenBounds.height-350,200,300));w.visible = true; r.free; r = ServerMeterView.new(s,w,0@0,2,2);
f.free; f = FreqScope.new(300,300,0,server:s); f.window.front;
)

NdefMixer(s);

Ndef.clear

CmdPeriod.add(k)
CmdPeriod.removeAll

Pdef.clear
Ndef.clear

~t = TempoClock.default
~t.playNextBar(Ndef(\kick).play)




// Bass Click
Ndef(\bassclik, {arg amp=0.1; LFPulse.ar([1,0.75], [0.25,0], 0.5) * (1 + Ndef(\fm)) * amp}).play
Ndef(\bassclik).fadeTime = 0
Ndef(\bassclik).clear

Ndef(\fm, {arg freq=40;  SinOsc.ar(freq * LFSaw.kr(6).range(1, 1.3) * XLine.kr(1, 10, 60*100), pi/2,1.3)})
Ndef(\fm).fadeTime = 20
Ndef(\fm).clear

Ndef(\fm, {arg freq=240; Saw.ar(freq , Saw.kr(freq + 5), SinOsc.ar(freq/2, 0, 0.2))!2})


(Ndef(\digimice, {arg amp=0.1; var sig;
	sig = Saw.kr(4, LFNoise0.kr(1).range(0.1, 0.8))!2
	; sig = Pulse.ar( TIRand.kr(2, 8, sig), LFNoise0.kr(0.125).range(0.1, 0.8), 1, sig)
	; sig = Decay.ar( Trig.ar(sig,0.1),0.1,0.1) * SinOsc.ar(LFNoise1.kr(0.04).range(6200, 10200), pi/2)
	* Ndef(\bassclik)
	// * (Ndef(\pulse).neg.exp + 1) / 10
	min:1 max:-1
	* amp;
}).play)
Ndef(\cut).clear
Ndef.clear

// Distortion sur le digimice
Ndef(\cutcut, { Ndef(\digimice).neg.sign * Saw.ar(120, SinOsc.ar(90 * LFNoise1.kr(1).range(1,10))) * 0.1}).play


// Sonnnerie de reveil
Ndef(\con, {  Ringz.ar( LFPulse.kr(6) * SinOsc.ar([1500,1550], 0, 0.1), 2040 * LFSaw.kr(0.0001).range(0, 1)) * Line.kr(0,0.03, 6)}).play
Ndef(\con).fadeTime = 40
Ndef(\con).clear


// Clap
(Ndef.clear; Ndef(\clap, { arg rel=0.2, amp=0.12;
	Decay2.kr(Dust.kr(160, LFPulse.kr(/*SPEED*/ 0.5, 0, 0.05)), 0.001, rel, ClipNoise.ar( amp ))!2;
}).play)



// Bip Bip stereo phasing
Ndef(\tt, { [LFPulse.ar(2, 0, 0.05) , LFPulse.ar(2.25, pi/3, 0.05)] * SinOsc.ar([1020,1026]) * 0.15 } ).play
Ndef(\tt).clear()

// vers stereo
(Ndef(\tr, { arg amp=0.25, vit= 2; var speed = {TIRand.kr(1, 4, Impulse.kr(0.125)) * vit }!2;
	Decay2.kr(Impulse.kr(speed), 0.001, 0.05, VarSaw.kr(speed/4, 0, 1)) + LFSaw.kr(speed.swap(0,1), 0, 0.01)  * SinOsc.ar([7188,7075, 7300, 7100]) * amp}).play)
Ndef(\tr).set(\amp, 0.5, \vit, 0.25)
Ndef(\tr).stop



// Barre laser
(Ndef(\noz, { {var n = 4; Mix.fill( n, {SinOsc.ar(exprand(3000, 66), 0, 1/n)} ) }!2
	+ LFPulse.ar(333,0, SinOsc.kr(0.5).range(0.1, 0.9), 0.1)
	* SinOsc.ar(LFSaw.kr(0.1)./*SPEED*/range(0.29,8), 0, LFPulse.kr(0.5, 0, LFNoise1.kr(0.33).range(0.33,0.66),LFPulse.kr(0.2),0.2) * VarSaw.kr(/*SPEED*/ 14, 0, LFNoise1.kr(25).range(0.1,0.9)) )
	* /*Amp*/ 0.3
}))
Ndef(\noz).play
Ndef(\noz).stop

// Barre Lazzzer
(Ndef(\lazer, { LFPulse.ar([230, 250],0, SinOsc.kr(0.125).range(0.1, 0.9), 0.1, -0.05)
	+ VarSaw.ar(150, 0, SinOsc.kr(0.25).range(0.05, 0.95), SinOsc.ar([276,82]))
	* 0.2}))
Ndef(\lazer).play

// Parfois, nique tout avec super aigus
Ndef(\coup, { Decay2.ar(Impulse.ar(0.5), 0.001, 1, Blip.ar(90, 20) + FreqShift.ar( Ndef(\lazer), [-100, -89]*2) ) * LFPulse.kr(0.25 * LFPulse.kr(0.5, 0.5, LFNoise0.kr(0.25).range(0.01,0.5), TIRand.kr(1,4,Impulse.kr(0.25))), 0, 0.1, )}).play
Ndef(\coup).fadeTime=0
Ndef(\coup).clear


Ndef.clear
Pdef.clear


// DOUCHE NOISE
Ndef.clear; Pbindef(\wht, \instrument, \clic, \dur, 12, \freq, Pwhite(200,4000), \sus, 1, \amp, 0.5).play
Pbindef(\wht).stop

// VAGUE manuelle
Synth.new("snare", [\amp, 0.5, \noiseRel, 5, \pan,0, \noiseRelC, 3, \fq, 405, \hifreq, rrand(3025,1200), \noiseDecay, 0.005])

// Des vers dans l'oreille
Pdef.clear; Ndef.clear;
Ndef(\u, { SinOsc.ar(1840) + SinOsc.ar(1939) + SinOsc.ar(888) + SinOsc.ar([1796, 1808]) * LFTri.kr(0.25, 0.5, LFPulse.kr(22) * 0 + 0.5) * 0.1}).play.stop;
Ndef(\u).clear

Ndef(\o, { SinOsc.ar(1640) + SinOsc.ar(1739) + SinOsc.ar(1444) + SinOsc.ar([1466, 1468]) * LFTri.kr(0.25, 0, LFPulse.kr(25) * 0 + 0.5 )* 0.1}).play.stop
Ndef(\o).clear

(Ndef(\vers, {
	Pan2.ar(
		Ndef(\u) * LFPulse.kr( LFNoise0.kr(0.5).range(0.25, 4), 0, LFNoise1.kr(3).range(0.01,0.8),0.75,0.25),
		LFNoise1.kr(7))
	+ Pan2.ar(
		Ndef(\o) * LFPulse.kr( LFNoise0.kr(0.5).range(0.125, 2), 0, LFNoise1.kr(3).range(0.01,0.8),0.75,0.25),
		LFNoise1.kr(7))
}).play)
Ndef(\vers).fadeTime=20
Ndef(\vers).clear


// Hiiiiiiiii
x = []
x = x.add({SinOsc.ar([3290, 3160] + 20.rand,0, 0.05) * SinOsc.ar( [ 0.2, 0.15]).range(0,1)}.play)
x.do({arg i; i.free})
Ndef.clear; x.free;

// Qui monte qui monte
x.do({arg i; i.free});
z = {LFSaw.ar(2000 * SinOsc.kr([0.012, 0.0121], 0, 0.125, 1), 0, 0.1) + SinOsc.ar([2222, 2300], 0, 0.1)}.play
x.free; y.free

// LOOOOOOOOW
y=[];
y = y.add({ SinOsc.ar([64,75]+5.0.rand, 0, 0.25)}.play )

// Qui whobble
y.do({arg i; i.free}); y = {LFPar.ar([60, 58] * SinOsc.kr([0.012, 0.0121]).range(0.8, 1.5), 0, 0.1) + SinOsc.ar([80, 77], 0, 0.1)}.play
y.free;

Pdef.

// Pressing
Ndef(\i, { LFPulse.ar(4, 0, 0.5, SinOsc.ar([2000, 3000, 12000]))!2 * 0.1}).play
Ndef(\ii, { LFPulse.ar(6, 0, 0.5, SinOsc.ar([4000, 6200, 9000]))!2 * 0.1}).play

/// PART DANCE

Ndef.clear; ~pstop.()
/*Kick and synth*/

(Ndef(\you, { arg amp=0.3; {
	SinOsc.ar(250*[1,2,1.5].choose * LFNoise0.kr(10.25).range(0.25, 1), pi/2)
	max: LFSaw.kr(LFNoise0.kr(0.5).range(-1,-0.8))
	min: LFSaw.ar(LFNoise0.kr(0.25).range(1,0.8), pi/2)
	* Saw.ar(LFNoise0.kr(0.2).range(0.10,4.25), SinOsc.ar(LFNoise1.kr(3).range(70, 260), 0, Saw.ar(LFNoise1.kr(1).range(600, 1020), 1,BrownNoise.ar()))) * 0.5
	* Decay2.ar(Impulse.ar(1.75), 0.001, 2, 1, Decay2.kr(Impulse.kr(3), 0.01, 0.3))
	* amp
}!2}).play)
Ndef(\you).fadeTime = 30
Ndef(\you).set(\amp,0.5)

/*Hithat*/
Ndef(\suck, {arg amp= 0.1; LFPulse.ar(8, 0, 0.2, SinOsc.ar([330, 440]*2, pi/2)) * amp * LFPulse.kr(0.5)}).play
Ndef(\suck).fadeTime = 0
Ndef(\suck).clear


// Gros Kick
Ndef(\ya, {arg amp=0.5, pulse= 1, cpulse=2; {Decay2.ar(Impulse.ar(cpulse), 0.001, 0.3, SinOsc.ar(66 * LFNoise2.kr(40).range(0.8,1.2), pi/2, 2)) * LFPulse.kr(pulse, 0, 0.4) * amp}!2}).play
Ndef(\ya).set(\pulse, 1, \cpulse, 1)

// HH saturé
Ndef(\mya, { SinOsc.ar(1020) * (Ndef(\suck) / ( 0.0001 + Ndef(\ya) / Pulse.kr(12)) * (0.01 + Ndef(\wowo).exp )) min:0.5 max:-0.5 * 0.1 }).play
Ndef(\mya).clear


