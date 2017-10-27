// new dance

Pdef.removeAll

Pbindef(\kick, \instrument, \kick, \freqA, 1300, \freqb, 400, \freqBDur, 0.1, \freqC, 40,\amp, 0.5, \dur, Pseq([1/2,1/2,1/4,1/3,1/3,1/3,1/4,1/2],inf)).play(quant:4)
Pbindef(\kick, )
Pbindef(\kick, \freqBC, Pseq([Pgeom(-3, 1.02, 100)],inf))
Pbindef(\kick, \dur, Pseq([1/2, 1/4, 1/2, 1/2, 1/4],inf)).play
Pbindef(\kick, \dur, Pshuf([1/2, 1/2, 1/4, 1/2, 1/4, Prand([Pseq([1/4],4), Pseq([1/8],8), Pseq([1/3],3)])],inf))
Pbindef(\kick, \dur, 1/4, \amp, Pwrand([0.5, Pwhite(0.01,0.25,1), 0],[0.8,0.1,0.1],inf))
Pbindef(\kick).play

Pbindef(\claire, \instrument, \snare,\dur,Pshuf([2, 2, 2, 2, 1],inf), \hifreq, 4000, \fq, 320, \noiseDecay, 0.003, \amp, 0.5, \noiseRelC, -6).play(quant:[9,3])
Pbindef(\claire, \dur, Pseq([0.5, 1.5, 1, 2],inf))

Pbindef(\clap, \instrument, \clap, \dur, Prand([0.5,0.25],inf), \amp, Pseq([0.2],inf), \rq, Pwhite(0.2,0.6), \rel,Pwhite(0.2,0.4), \freq,900, \stretch, 0.5).play(quant:[4,0.5])
Pbindef(\clap).stop


/// UNE BASSE
(SynthDef("saw", { arg freq=420, amp=0.3, pan=0, att=0.001, phase=0, rel=0.005, sus=0, out=0;
	var env, sig;
	env = Env([0,1,1,0],[att, sus, rel]).ar(2);
	sig = Mix.fill(3, {arg i;
		LFSaw.ar(freq * (1 + ((i+1)/20)).postln, pi/((i*2)+1),1/2);
	});
	sig = BLowPass.ar(sig, freq, 0.1);
	Out.ar(out, Pan2.ar(sig * env, pan, amp));
}).add;)

Pbindef(\glouglou, \instrument, Pseq([\saw, \sine],inf),\freq, [75, 122] * Pseq([1, 1.2,1.4],inf), \rel, 0.2, \dur, Pseq([Pseq([1/4],8), 1/2,1/2],inf)).play(quant:[4, 1.5])

/// UN GENDY NOISY
(SynthDef("gendymax",{ arg amp=0.1, att=0.01, sus=0, rel= 0.1, attC=3, relC = (-3);
	var sig, env;
	env = Env([0,1,1,0],[att, sus, rel], [attC, 0, relC]).kr(2);
	sig = Mix.fill(10,{Gendy2.ar(Rand(0.1,2.1),Rand(0,2.0),Rand(0,0.5),Rand(0.01,0.8),Rand(40, 120),Rand(120, 3020),Rand(10,0.07),Rand(0,0.03)) * (1/5)});
	sig = Mix.ar([sig, ClipNoise.ar(Line.kr(1,0.00001,0.1)), LFSaw.ar(180)* Line.kr(1,0.00001,0.15)]);
	sig = sig * env * amp;
	Out.ar(0, Pan2.ar(sig, LFNoise1.kr(8,0.5)));
}).add)

z.free; z = {((Gendy2.ar(1,1,1,1,63,500,0.005,5))*0.2)!2}.play

Pbindef(\bizz, \instrument, \gendymax, \dur, 2, \rel, 0.01, \sus,0.5, \amp, 0.2).play(quant:[4,0])
Pbindef(\bizz).stop


x.free; x = {arg amp=0.1; ( Mix.fill(10,{Gendy2.ar(2.5.rand,1.05.rand,0.5.rand,0.33.rand,100.rand,720.rand,0.07.rand,0.03.rand) * (1/5)}) * amp)!2}.play

x.set(\amp,0)

y.free; y = {arg amp=0.1; (Decay2.ar(Impulse.ar(2),0.01,0.5, Formant.ar([20,44],LFNoise0.kr(1,500,500),880)) * amp)!2}.play;
y.set(\amp, 0)

/// UN TRUC POUR FAIRE LE DUB

(SynthDef("dubitar", {
	arg out=0, amp=0.25, sus= 1, pan=0, freq=90, speed=4;
	var sig;
	sig = Decay2.ar(
			Impulse.ar(XLine.kr(speed,speed,sus,1)), 0.01, 0.5,
		LFSaw.ar([freq, freq * 0.98],0, Gendy2.ar(0.1,0.15,1,1,1200, 1300,0.01,0.01)));
	sig = sig * XLine.kr(amp, 0.05, sus,1,0,2);
	Out.ar(out, sig);
}).add
)

Pbindef(\tar, \instrument, \dubitar, \dur, Prand([2],inf), \sus,Pwhite(0.75, 2), \freq,[60,176], \amp, 0.15, \speed, Pseq([4, 6, 8],inf)).play(quant:[4,2])
Pbindef(\tar).stop

Pbindef(\fofor, \instrument, \formant, \dur, 1).play(quant:[4,1.5])
Pbindef(\fofor, \freq, Pwhite(10,60), \addFreq, [3000, 1030], \rel, 1, \lenmul, Pwhite(1,3), \att, 0.01, \rel, Pwhite(0.1, 0.3), \amp, 0.3)
Pbindef(\fofor, \dur, Pseq([1, 1/2, 1/2, 2],inf), \lenmul, Prand([Pwhite(1,3, 4), 0.5],inf))
Pbindef(\fofor, \dur, Pseq([1/4, 1/4, 1/8, 1/8, 1/4, 1/2, 1/2],inf))

Pbindef(\fofor, \rel, Pwhite(0.2,0.5), \lenmul, 2, \freq, 120, \addFreq,Pwalk(Array.geom(50,500,1.01),Prand([-2,-1,1,2],inf), 1).trace, \bwFreq, 1400, \dur, 1/3).stop

Pbindef(\globy,\instrument, \glob,\rel, 0.5, \sus, 1, \dur, 4).play(quant:[4,3])
Pbindef(\globy, \argA, 0.710, \argB, 120, \argC, 3, \amp, 0.5)
Pbindef(\globy).stop

Pbindef(\groovybee, \instrument, \blip, \dur,1/4, \freq, Pstutter(Prand([1,4,2],inf),130 + Pseq([12, 20, -30],inf)), \nharm, 2, \rel, 0.2).play(quant:[4,0])