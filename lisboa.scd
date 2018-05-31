// Bass Click
Ndef(\bassclik, {arg amp=0.1; LFPulse.ar([1,0.7] /* * Line.kr(1,120, 60*3) */, [0.25,0], 0.5) * (1+ Ndef(\fm)) * amp}).play
Ndef(\bassclik).fadeTime = 0
Ndef(\bassclik).clear(10)


Ndef(\fm, {arg freq=600;  SinOsc.ar(freq * LFSaw.kr(6).range(1, 1.3), pi/2,1.3)})
Ndef(\fm).fadeTime = 20
Ndef(\fm).clear


Ndef(\piii, { Mix.ar( SinOsc.ar([860, 691, 1906, 686, 1817, 1305 /* add freqs */ ])) * SinOsc.kr([0.0125, 0.02],pi/2, 0.1) * 0.1}).play
Ndef(\piii).fadeTime = 3
Ndef(\piii).clear(10)


Ndef(\jiii, { Mix.ar( SinOsc.ar([3999 /* add freqs */ ]) ) * SinOsc.kr([0.0125, 0.031], 0, 0.1) * 0.1}).play
Ndef(\jiii).fadeTime = 60
Ndef(\jiii).clear(1)


// PERC ! - Timbre
(Ndef(\tacF, {
	Mix.fill(36, { SinOsc.ar( rrand(3240, 3800) * SinOsc.ar(1514).range(0.5,1.2), pi/2, 1/36)
		})
	// + WhiteNoise.ar(1)
	// + BrownNoise.ar(1)
}))

// PERC ! - Beat
(Ndef(\tac, { arg amp=0.5, freq = 0.25, rel=0.1;
	Ndef(\tacF) * Decay2.ar( Impulse.ar(freq), 0.01, rel, amp )!2
	// + RHPF.ar( Ndef(\tacF), LFSaw.kr(freq).range(200, 13000), LFSaw.kr(freq*8).range(0.1,0.001), amp/4) * Decay2.ar(Impulse.ar(freq),0.1, 1/freq/2 )
}).play )

Ndef(\tac).set(\freq, 0.125)
Ndef(\tac).set(\rel, 1.95)
Ndef(\tac).clear

// PERC ! - Nappe
(Ndef(\nappe, { arg amp= 0.5;
	var sig = Ndef(\tacF);
	sig = PitchShift.ar( sig , 0.5, 0.8, 0.020, 0.20) * {LFNoise1.ar(0.1)}!2
	// + sig
	+ SinOsc.ar( 88 * {LFNoise1.ar(0.125).range(0.5, 1.2)}!2, 0, 0.5 )
	;sig = sig * amp;
} ).play)

Ndef(\nappe).set(\amp, 0.5)

// Hiiiiiiiii
x = []
x = x.add({SinOsc.ar([3290, 3160] + 20.rand,0, 0.05) * SinOsc.ar( [ 0.2, 0.15]).range(0,1)}.play)
x.do({arg i; i.free})
Ndef.clear; x.free;

// Qui monte qui monte

(Ndef(\monte, {
	LFSaw.ar(2000 * SinOsc.kr([0.0052, 0.0051], 0, 0.125, 1), 0, 0.1)
	+ SinOsc.ar([2222, 2300], 0, 0.1)
}).play)
Ndef(\monte).play
Ndef(\monte).stop


// LOOOOOOOOW
y=[];
y = y.add({ SinOsc.ar([98, 90] + 5.0.rand) * 0.5 }.play )
y.do({arg i;i.free}); y = [];

// Qui bass monte
Ndef(\baasse, { LFPar.ar([86, 88] * SinOsc.kr([1, 1.21]).range(0.8, 1.5), 0, 0.1, SinOsc.ar([80, 77], 0, 0.1))}).play

Ndef(\baasse).clear; y.do({arg i; i.free}); Ndef(\nappe).clear


// Bip Bip stereo phasing
Ndef(\tt, { [LFPulse.ar(2, 0, 0.05) , LFPulse.ar(2.25, pi/3, 0.05)] * SinOsc.ar([1020,1026]) * 0.05 * LFNoise2.kr(1).range(0.001,0.5) } ).play
Ndef(\tt).clear()

// petits clicks/vers stereo
(Ndef(\tr, { arg amp=0.25, vit= 2; var speed = {TIRand.kr(1, 4, Impulse.kr(0.125)) * vit }!2;
	Decay2.kr(Impulse.kr(speed), 0.001, 0.05, VarSaw.kr(speed/4, 0, 1)) + LFSaw.kr(speed.swap(0,1), 0, 0.01)  * SinOsc.ar([7188,7075, 7300, 7100]) * amp}).play)
Ndef(\tr).set(\amp, 0.5, \vit, 0.25)

Ndef(\tr).stop;
Ndef(\tt).stop


// Pressing
Ndef(\i, { LFPulse.ar(4, 0, 0.5, SinOsc.ar([2000, 3000, 12000]))!2 * 0.1}).play;
Ndef(\ii, { LFPulse.ar(6, 0, 0.5, SinOsc.ar([4000, 6200, 9000]))!2 * 0.1}).play

Ndef(\i).stop; Ndef(\ii).stop

// Bass on/off
Ndef(\basss, { SinOsc.ar([60,55] + FSinOsc.kr(0.125,0, 4) + 10) * 0.8 * LFPulse.kr(0.25)}).play
Ndef(\basss).clear





// SPACE FIGHT
(Ndef(\s, { arg /*AMP*/ amp=0.1;
	var sig;
	sig = {WhiteNoise.ar(0.05) / LFNoise1.ar(/*DENSITY*/ 0.2 ) }!2;
	sig = Decay2.ar(sig, 0.1001, LFNoise1.kr(4).range(0.01,1), SinOsc.ar( PitchShift.ar(sig,0.2, LFNoise1.kr(0.5).range(/*SPEED*/ 0.001,0.5)) * /*PITCH*/ 100 + 88, 0, 0.01));

	// sig = FreeVerb2.ar( sig[0], sig[1], /*MIX*/ LFNoise1.kr(0.5).range(0,0.95), /*ROOM*/ LFNoise1.kr(0.2).range(0,0.85), /*DAMP*/ LFNoise1.kr(1).range(0,0.3));

	sig = sig + DelayC.ar( [ sig[1] , sig[0]], 0.1, 0.05, LFSaw.kr(0.5).range(0.01,0.1));

	sig = sig / 2 * amp min:0.25 max:-0.25;

	// /*TO COMPRESSEUR*/ Out.ar([0, ~compCtrl.index], sig);
}).play)
Ndef(\s).stop(4)
Ndef(\s).fadeTime(2)



// Claque qui coupe tout
z.free; ~sines.do({arg i; i.free}); Pdef.clear; Ndef.clear; ~pstop.(); ~gstop.(); Synth.new("snare", [\amp, 0.5, \noiseRel, 0.1, \pan,0, \noiseRelC, 3, \fq, 405, \hifreq, rrand(3025,1200), \noiseDecay, 0.005]);Ndef(\s).stop


// VAGUE manuelle
Ndef.stop; Synth.new("snare", [\amp, 0.5, \noiseRel, 5, \pan,0, \noiseRelC, 3, \fq, 405, \hifreq, rrand(3025,1200), \noiseDecay, 0.005])



// Des vers dans l'oreille
Pdef.clear; Ndef.clear;


(Ndef(\vers, {
	BrownNoise.ar( {LFNoise1.kr(4)}!2 * Line.kr(1,0,4.0.rand)) +
	SinOsc.ar([2800, 3000], 0, 0.1) +
	Saw.ar([2900, 3000] * SinOsc.kr( { LFNoise2.kr(1).range(0.1, 1) } ! 2).range(0.95,1), 0.1 ) } ).play)

(Ndef(\ver, {arg freq=4000;
	// Saw.ar(4000 * LFNoise1.kr({LFNoise1.kr(1).range(10,8)}!2).range(0.99, 1.02))
	RLPF.ar( Saw.ar(freq * LFNoise1.kr(15).range(0.98, 1.2)), freq*1.25, 0.1) *
	LFPulse.kr( 0.2, 0, LFNoise0.kr(2).range(0.1,0.5)) * 0.1} ).play)

Ndef(\ver).set(\freq, 4000).clear

Ndef(\stable, { SinOsc.ar([4000, 3500]) * 0.1 }).play


Ndef(\bb, { SinOsc.ar([66, 77, 222] * LFNoise1.kr(0.1).range(0.95, 1.05)) + BrownNoise.ar({LFNoise1.kr( LFNoise2.kr(1).range(0.1,6)).range(0,0.8)}!2) * 0.4}).play
