(
SynthDef("snaredel", {
	arg out=0, amp=0.5, att=0.002,sus=0.01, rel=0.001,
	attC=0,relC=(-24),
	pan=0, ff=1200, deldur=0.5, delvit=0.3,delfq=0.5,
	crash=2;
	var env, sig, envsin, sin,envdel;
	var rs = 0.0005, fqs = ff * [0.366, 1, 1.683, 1.333];

	env = Env([0,1,1,0],[att,sus,rel],[attC,0,relC]).ar();
	envsin = Env([0,1,0],[att,rel*0.01],[attC,relC - 30]).ar();
	envdel = Env([0,1,1,0],[att,sus,rel],[24,0,24]).ar(2);
	sig = Mix.fill(fqs.size, {arg i;
		BHiPass.ar(
			ClipNoise.ar(0.5),
			fqs[i],
			rs*(fqs),
			fqs.size/((i+1*6))
		);
	});
	sin = Mix.fill(fqs.size, {arg i; SinOsc.ar(fqs[i],0,fqs.size/((i+1*6))) });
	sig = (sig * env * 0.5) + (sin * envsin * 1);
	sig = sig * env;
	sig = sig + CombN.ar(sig,delvit+0.1,LFNoise1.kr(delfq,delvit,delvit+0.01),deldur); // COMB DELAY
	// sig = sig * envdel;
	sig = Pan2.ar(sig,pan);
	sig = sig * amp;
	DetectSilence.ar(sig, time:crash, doneAction:2);
	Out.ar(out,sig);

}).add;


SynthDef("kick", {arg out=0,amp=0.5,pan=0,att=0.02,rel=0.2, sus=0,attC=0, relC=6,
	freqA=2840,freqB=61,freqC=33,freqAC=(-4.85),freqBC=(-12);
	var env, sweep, sig, fm;
	env = Env([0,1,1,0],[att,sus,rel],[attC,0,relC]).ar(2);
	sweep = Env([freqA,freqB,freqB,freqC],[att,sus,rel],[freqAC,0,freqBC]).ar;
	// sweep = sweep * LFSaw.kr(90,1);
	sig = Mix.fill(4, {arg i; LFPar.ar(sweep * ( 1 + (i*0.12)), pi*(i*0.66),(1/(i+1.25)))});

	fm = LFSaw.ar(604 * LFNoise0.kr(),0, LFClipNoise.kr(100,0.5));
	fm = RLPF.ar(fm, 682 , 0.01,0.1); // <-- change le filtre
	// sig = sig * (fm + 1);
	sig = sig * env * amp;
	Out.ar(out,Pan2.ar(sig,pan));
}).add;


SynthDef("kick-adsr", {arg out=0,amp=0.5,pan=0,att=0.02,dec=0, rel=0.2, sus=0,attC=0, relC=6,
	freqA=2840,freqB=61,freqC=33,freqAC=(-4.85),freqBC=(-12);
	var env, sweep, sig, fm;
	env = Env([0,1,0.25,0.25,0],[att,dec, sus,rel],[attC,0,relC]).ar(2);
	sweep = Env([freqA,freqB,freqC,freqC],[att,sus,rel],[freqAC,0,freqBC]).ar;
	// sweep = sweep * LFSaw.kr(90,1);
	// sig = Mix.fill(2, {arg i; LFPar.ar(sweep * ( 1 + (i*0.12)), pi*(i*0.66),(1/(i+1.25)))});
	sig = SinOsc.ar(sweep);

	fm = LFSaw.ar(604 * LFNoise0.kr(),0, LFClipNoise.kr(100,0.5));
	fm = RLPF.ar(fm, 682 , 0.01,0.1); // <-- change le filtre
	// sig = sig * (fm + 1);
	sig = sig * env * amp;
	Out.ar(out,Pan2.ar(sig,pan));
}).add;

SynthDef("bip", {
	arg out=0, att=0.001, rel=0.05, freq=80, pan=0, sus=0, amp=0.1;
	var sig, env;
	env = Env([0,1,1,0], [att, sus, rel]).kr(2);
	sig = SinOsc.ar(freq, pi/2);
	sig = Pan2.ar(sig, pan, amp * env);
	Out.ar(out,sig);
}).add;

// Noise
SynthDef("noise", {arg out=0,bw=1.5, amp=1, pan=0, freq=1800,
	att=0.001, rel=0.5, sus=0.02, attC=20,relC=(-6),
	freqA=30000, freqB=80, freqC=3500,  attSweep=0.1, relSweep=0.15, attSweepC=0, relSweepC=0;
	var sig, env, sweep;
	env = Env([0,1,1,0],[att,sus,rel],[attC,0,relC]).kr(2);
	// sweep = Env([freqA, freqB, freqC], [attSweep, relSweep], [attSweepC,relSweepC]).kr(2);
	// sig = BBandPass.ar(PinkNoise.ar(),sweep,bw * env,1/bw);
	sig = BBandPass.ar(PinkNoise.ar(),freq,bw * env,1/bw);
	Out.ar(out,Pan2.ar(sig * env,pan, amp));
}).add;

SynthDef("clic", {
	arg att=0.001, rel=0.2, freq=800, pan=0, sus=0, amp=0.1, rq=0.25;
	var sig, env;
	env = Env([0,1,1,0], [att, sus, rel]).kr(2);
	sig = BPF.ar( ClipNoise.ar(1), freq, rq, 1/rq.sqrt);
	sig = Pan2.ar(sig, pan, amp * env);
	Out.ar(0,sig);
}).add;

// Snare
SynthDef("snare", {arg out=0,amp=0.5,fq=420, hifreq=1020, cutoff=0.05,pan=0,
	att=0.001, rel=0.3,attC=(0),relC=(-3), crash = 0;
	var sig, env, harms;
	harms = [2.58435,1.4187,1.2834,2.054049,2.1310,1.5194,1.7372,1.5960,1.0100,1.01165, 3.03741, 4.1238, 2.092, 3.989];
	env = Env([0,1,0],[att,rel],[attC,relC]).kr(1 - crash * 2);
	sig = Mix.ar([BrownNoise.ar(0.25), ClipNoise.ar(0.25)]);
	sig = Mix.fill(harms.size, {arg i; Ringz.ar(sig, fq * harms[i].postln, cutoff, 1/(harms.size + cutoff)) });
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef("clap",{
	arg out=0, att=0.001, rel=0.5, relC = -12, pan=0, amp=0.2, freq=900, del=0.015, rq=0.2;
	var sig, env, enva, envb, envc;
	env = Env.perc(att, rel, amp, relC).kr(2);
	enva = DelayN.ar(env,0.2,del*2);
	envb = DelayN.ar(env,0.2,del);
	envc = DelayN.ar(env,0.2,del*3);
	sig = Mix.fill(6,{arg i; var delay;
		delay = DelayN.ar(env, 0.2, rrand(0,del));
		BPF.ar(ClipNoise.ar(), freq * Rand((i*0.25) + 1, (i*0.25) + 1.1), rq, 1 + (1/rq) * (1/6)) * delay;
	});
	sig = LinSelectX.ar(Rand(0,2), sig)!2;

	Out.ar(out, sig);
}).add;

~noKick = {arg t; (((~lastKick[\amp] < 0.1) && (~lastKick[\dur] >= (t/2))) || (~lastKick[\dur] >= t))};

~onBeat = {arg d;  TempoClock.default.nextBar - TempoClock.default.beats == d};

// t = PdefAllGui();
)



Pdef.clear


Pdef.removeAll

t = PdefAllGui(8);

~varia = {LFPar.kr( LFNoise1.kr(0.0125,0.25)) * 0.2 }.play

~changeTempo = { TempoClock.tempo = 4.rand + 1}

TempoClock.schedAbs(TempoClock.nextBar, ~changeTempo.())

t = Task({ { "tempo".postln; ~changeTempo.(); TempoClock.timeToNextBeat.wait;}.loop} )
t.start

TempoClock.playNextBar( ~changeTempo.() )

TempoClock.timeToNextBeat
TempoClock.beatDur

TempoClock.tempo = 1


// PHASING KICKS /////////////////////////////////////

(Synth("kick-adsr", [
	\att, 0.01,
	\dec,0.05,
	\rel, 10,
	\relC, 0,
	\sus, 1,
	\freqA, rrand(360,250)*10,
	\freqB, rrand(80.0,90)+10,
	\freqC, rrand(45.0,56),
	\freqBC, -40.rand,
	\amp, 0.4])
)



// KICK //////////////////////////////////////////////

Pbindef(\k, \instrument, \kick, \amp, 0.6, \rel, 0.5, \dur, 2, \freqBC, -20)
Pbindef(\k,\dur, Pseq([3/4, 6/4],inf)).play(quant:4)

Pbindef(\k, \freqB, 66 + Pseq((0..300)).trace, \rel, 0.5)


Pbindef(\k, \dur, Pseq([ Pseq([1], 1), Pseq([3/4, 3/4, 2/4] /*edit*/ ,1)],inf) ).play(quant:4);

Pbindef(\k, \rel, 0.05, \dur, Prand([1/2, 1/4, Pseq([1/8],4), Pseq([1/3],2), 2/3, 1, 3/4],inf) )

Pbindef(\k, \dur, 1/4, \freqB, 86, \freqC, 44, \rel, 0.1).play
Pbindef(\k, \dur, 1/8).play(quant:4)


// PLOCS ////////////////////////////////////////////

Pbindef(\p, \instrument, \bip, \freq, 1111 * ({rrand(0.5,3)}!10), \rel, 0.025, \amp, 0.05, \pan, [-1, 1])
Pbindef(\p, \dur, 1/2 ).play(quant:1)

Pbindef(\p, \dur, Prand([ Pseq([1/8],8), Pseq([1/3],3), Pseq([1/7],7), Pseq([1/4],8), Pseq([1/2], 4)], inf)).play(quant:4)


Pbindef(\hot, \instrument, \bip, \freq, [600, 573, 577, 601, 603] * Pseq([ Pseq([1], 15 ), Pseq([[0.7, 0.8678, 0.979, 1, 1.13, 1.672, 4, 3.74]]) ],inf), \amp, 0.05, \dur, 1/4).play(quant:[4, 0.5])

~gfree.()

// Milford Graves

Pbindef(\k, \dur, (Pwalk( (0..200)/1000, Pseq([Pwhite(-10,10,1), 0],inf), 1, 100) * Pseq([1,-1],inf)) + Pseq([0.5, 0.5, 3/4] /* speed up */  * 1,inf) , \rel, 0.2 ).play(quant:4)


/* Snarifize */
Pbindef(\k, \instrument, Pseq([ \kick,\kick, \kick, Prand([\kick, \snare])],inf)).play
Pbindef(\k, \instrument, Pseq([ \kick, Prand([\kick, \snare])],inf)).play // ++
Pbindef(\k, \instrument, \kick) // Sans snare


/* Montée en freq */
Pbindef(\k, \freqC, 33 + Pseq((0..200),inf) )
Pbindef(\k, \freqB, 61, \freqC, 33) // raz


/* Algorythmize */
~k = Pbindef(\k).stop.collect({|e| ~lastKick = e;}).play(quant:[4, 0, 0.1])


// CLAPPY SNARE ///////////////////////////////////////////
Pbindef(\s, \instrument, \snare, \dur, Prand([1, 1, 1.5],inf), \amp,0.3, \relC, -6, \rel, 0.3)
Pbindef(\s).play(quant:[4, 1])

Pbindef(\s,\dur, 2, \amp, 0.8, \cutoff, 0.1)

/* crazy drummer */
Pbindef(\s, \amp, Pwhite(0.0, 0.0125) + Pseq([ Pseq((0..5000)/5000), Pseq([1],inf) ]), \dur, Pwrand([1/8, 1/12,1/16], [0.8,0.1, 0.1],inf), \rel, Pwhite(0.5,0.1) ).play(quant:[4, 1])

Pbindef(\s, \dur, Pwrand([1/8, 1/16, 1/4, 1/2], [0.925,0.05, 0.0125, 0.0125],inf), \rel, Pwhite(0.05,0.5), \amp, Pwhite(0,0.2))


Pbindef(\s, \amp, Pkey(\dur)/2 * Pwhite(0.8, 1.2))
Pbindef(\s, \rel, Pkey(\dur)*3 * Pwhite(0.8,1.2))
Pbindef(\s, \cutoff, ( Pkey(\dur)/2 ))

/* Variable amplitude */
Pbindef(\s, \amp, Prand([0.5, 0.1,0.2, 0.7],inf)  / 4 )


/* Speed up */
Pbindef(\s, \amp, 0.5, \rel, 0.5, \cutoff, 0.05, \dur, Pseq([1, 1, Prand([Pseq([1, 1]), Pseq([1/4, 3/4]), /*Pseq([1/3, 4/6,2/3, 2/6])*/ ])],inf)).play

Pbindef(\s, \cutoff, 0.075, \rel, 0.25)

Pbindef(\s, \amp, 0.5, \hifreq, 5000, \cutoff, Pwhite(0.01, 0.15), \rel, Pwhite(0.05, 3))


/* + */
Pbindef(\s, \dur, 1/4)

Pbindef(\s, \dur, Prand([1/2, 1/3, 2/3, 2/6],inf))
Pbindef(\s, \dur, (1 / (Pexprand(1,8)*2)).trace )

Pbindef(\s, \cutoff, 0.025, \fq, 420)

Pbindef(\s, \dur, 1, \amp, 0.4)
Pbindef(\s, \dur, Pseq([1/2, 1/2, 1, 1/4, 3/4, 1/2, 1/2],inf))

/* Vague w/ variable freq */
Pbindef(\s, \hifreq, Pwhite(1330, 660), \rel, Pwhite(0.5, 1), \noiseDecay, 0.01, \noiseRel, 0.5, \dur, 4)

/* Algorythmize */
~s = Pbindef(\s).stop.collect({|e| ~lastSnare = e;}).play(quant:[4, 0, 0.05])


// HAT /////////////////////////////////////////////////////////
Pbindef(\h, \instrument, \bip, \freq, [440, 820, 2800, 3200], \att, 0.001, \amp, 0.05, \rel, 0.01)

Pbindef(\h, \dur, 1/8, \amp, 0.1).play(quant:[4,0.5])
Pbindef(\h, \dur, Pseq([ Pseq([1/8],4), Pseq([1/4], 2), Pseq([1/6],3) ],inf))
Pbindef(\h, \dur, 1/16, \amp, 0.1).play(quant:4)
Pbindef(\h, \dur, Prand([ Pseq([ 1/8],8), Pseq([1/16],16)],inf) )

Pbindef(\hot, \instrument, \bip, \freq, [600, 573, 577, 601, 603] * Pseq([ Pseq([1], 15 ), Pseq([[0.7, 0.8678, 0.979, 1, 1.13, 1.672, 4, 3.74]]) ],inf), \amp, 0.05, \dur, 1/8).play(quant:[4, 0])



// FEELLLLLL ///////////////////////////////////////////////////
~pstop.();
Pbindef(\h, \dur,Pstutter(Pwhite(1,4)*2, Prand([1/6, 1/4, 1/8, Pseq([1/8],4)],inf)) , \amp, Pwhite(0.05,0.07), \rel, Pwhite(0.01,0.1)).play

~pplay.()

Pbindef(\feel, \instrument, \bip, \freq, {rrand(690, 1200)}!4, \dur,Pstutter(Pwhite(1,4)*2, Prand([1/6, 1/4, 1/8],inf)) , \amp, 0.1, \rel, Pwhite(0.01,0.1)).play(quant:[4,1/3])

Pbindef(\feel, \dur, Pstutter(Pwhite(1,4)*2, Prand([1/8,1/3, 1/2, 1/4, 1/8, 1/12, 1/16],inf)))

Pbindef(\feel, \rel, Pwhite(0.01, 2) * Pkey(\dur), \freq, {rrand(700, 900)}!4 * Pwhite([1, 1], [1, 0.9]), \amp, Pkey(\dur) / Pwhite(1.5, 3))

/* Algoryrhmize */
Pbindef(\feel, \dur, Pfunc({ ~lastKick[\dur]   }))

Pbindef(\h, \rel, Pfunc({if (~lastKick[\dur] >= (1) ) { rrand(0.5,2)} {rrand(0.01,0.1)} } ) )

Pbindef(\h, \detune, Pfunc({if (~lastKick[\dur] >= 1 ) { rrand(-30.0, 100.0)} {0} } )  )

Pbindef(\s, \stretch, Pfunc( { if (~lastKick[\dur] >= 1) {4} {1} } ))
Pbindef(\s, \rel, Pfunc( { if (~lastKick[\dur] >= 1) {rrand(0.5,1)} {rrand(0.01,0.3)} } ))
Pbindef(\s, \amp, Pkey(\dur).ceil)

Pbindef(\k, \dur, Prand([1/4, 1],inf), \amp, 0.5)

~k.play


// Batukada
Pdef.clear

// Très vénère
Pbindef(\k,  \instrument, \kick, \rel, Pkey(\dur)*0.2, \amp, 0.5, \freqB, 66, \freqC, 33);

Pbindef(\temp, \instrument, \bip, \dur, 1/4, \freq, [1500, 650, 325], \amp, 0.075).play(quant:1);
Pbindef(\temp, \dur, Pwrand([Pseq([1/2],2), Pseq([1/8],8)], [0.9, 0.1], inf))

Pbindef(\k, \dur, Pseq([Pshuf([0.35, 1/2.5]), 1/4, 1/2, 1/4, 1/4], inf)).play


// Batukadize
Pbindef(\k ,\dur, Pseq([1/5, 0.175, 1/8, 1/2]*2,inf))

Pbindef(\k, \dur, Pseq([1/5, 0.175, 1/8, 1/4,1/8, 1/8, 1/5, 0.175, 1/8, 1/2] * 2,inf))

Pbindef(\k, \dur, 4, \amp, 1, \freqB, 70, \rel, 1)
.play(quant:4)

// HARD SNARE

Pbindef(\hs, \instrument, \snare, \dur, 8, \fq, 600, \hifreq,2020 , \cutoff, 0.005, \rel, 2, \relC, 36, \amp, 0.5).play

/// Togo Toggle grooves
Pdef.clear

Pbindef(\uio, \instrument, \bip, \att, 0.01, \rel, 0.05, \dur, Pwrand([2/3, 1/3, Pseq([1/8],4)], [0.6, 0.2, 0.2],inf), \freq, Pseq([630,\,Prand([630, Prand([\, 580, 630], Prand([1, 2, 3]))])],inf), \amp, 0.25).play(quant:4)

Pbindef(\uy, \instrument, \bip, \att, 0.001, \rel, 0.1, \dur, 1/8, \freq, Pseq([420, 380, 380,\, 420],inf), \amp, 0.25, \pan, Pwhite(-0.5, 0.5)).play(quant:4)

Pbindef(\yp, \instrument, \bip, \att, 0.001, \rel, 0.1, \dur, 1/8, \freq, Pseq([390, \, 390],inf), \amp, 0.25, \pan, Pwhite(-0.5,0.5)).play(quant:4)


Pbindef(\passa, \instrument, \bip, \dur, Pseq([ Pseq([1/6], Prand([6, 12, 8])), Pwhite(1/4, 1/8, 6)], inf) * 10, \freq,  Pwhite([2800, 2800],[2800.0, 2802.0]), \rel, Pwhite([0.25,0.125], [2,1]), \att, Pwhite([0.002,0.1], [0.001, 0.5]), \amp, 0.125 ).play


/* Batukadize */
Pbindef(\k,\dur, Pseq([1/5, 0.175, 1/8, 1/4,1/8, 1/8, 1/5, 0.175, 1/8, 1/2]*2,inf)).play


Pbindef(\k,\dur, Prand([1, Pseq([1/5, 0.175, 1/8, 1/4,1/8, 1/8, 1/5, 0.175, 1/8, 1/2]*2)], inf))

Pbindef(\k, \dur, 1/12, \freqB, 90, \freqC, 50, \rel, 0.2).play

Pbindef(\s, \instrument, \snare, \dur, 4).play

// Pour compresseur
Pbindef(\s, \instrument, \snare, \amp, 0.7, \dur, Pseq([2, 2, 2, Prand([1, Pseq([1/2, 1/2])])],inf), \noiseRel, Pwrand([0.05, 1], [0.9, 0.1],inf), /*\out, ~compIn.index */).play

/*Tout ds compresseur*/ Pdef.all.do({arg i; i.set(\out, ~compIn.index)})
/*Tout hors du compresseur*/ Pdef.all.do({arg i; i.set(\out, 0)})


Pbindef(\tot, \instrument, \bip, \freq, {rrand(390, 800)}!4, \dur, Pstutter(Pwhite(1,4)*2, Prand([1/8,1/3, 1/2, 1/4, 1/8, 1/12, 1/16],inf)), \amp, 0.1, \rel, Pwhite(0.005,0.1)).play(quant:[4,1/3])


(Pbindef(\snark, \instrument, \snaredel, \pan,Pwhite(-1.0,1),\dur,Prand([1,2],inf),\rel,Pwhite(0.1,1),\relC,-12,
	\deldur,Pwhite(0.05,0.3),\delvit,Pwhite(0.01,0.5),\delfq,Pwhite(1,30),
	\amp,Pwhite(0.5,0.8),\ff,Pwrand([Pwhite(10,100,1), Pwhite(2000,5000,1)],[0.7,0.3],inf)
).play(quant:[4,2]))
Pbindef(\snark, \dur, Pseq([1/4,3/4],inf)).play
Pbindef(\snark, \amp, 1)
Pbindef(\snark).stop.clear;

/// KILLL
Pbindef(\s).stop; Pbindef(\hat).stop; Pbindef(\k).clear;
Pbindef(\uio).stop; Pbindef(\uy).stop; Pbindef(\yp).stop;
Pbindef(\passa).stop; Pbindef(\temp).stop;
Pbindef(\tot).stop;
