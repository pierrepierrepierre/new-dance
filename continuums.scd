(
SynthDef("formant", { arg out=0,freq=60,addFreq=700,amp=0.5,
	att=0.01,rel=0.1,sus=0,attC=0,relC=0,
	bwfreq=880,lenmul=2,pan=0,panrand=1;
	var len, env, sound, sfreq = freq, efreq = freq+(addFreq);
	len = (att+sus+rel)*lenmul;
	env = Env([0,1,1,0],[att,sus,rel],[attC,0,relC]).kr(2);
	sfreq = XLine.kr(sfreq,efreq,len); /* XLine pour le formant */
	efreq = XLine.kr(efreq,sfreq,len); /* XLine pour le formant */
	sound = Formant.ar(sfreq,efreq,bwfreq);
	sound = sound * env * amp;
	sound =  Pan2.ar(sound ,Lag.kr(LFNoise1.kr(1.0),2,panrand,pan));
	Out.ar(out, sound);
}).add;

SynthDef("autoglob", {arg argA=10, argB=0.2,argC=400, ampLag=2,out=0,panFreq=10;
	var amp = NamedControl.kr(\amp,0.2,ampLag);
	var sig =
	Formant.ar(
		(LFNoise1.kr(LFNoise1.kr(0.1,1,0.5) * argA,1) * 140).scaleneg(argA),
		(LFNoise1.kr(LFNoise1.kr(0.02,0.5,0.5) * argB ,1,1 )*800).scaleneg(argB),
		(LFNoise1.kr(1,0.5,1) * argC),
		(Gendy1.kr(
			/*ampdist*/ 2
			,/*durdist*/ 0.1
			, /*adparam*/ 0.001
			, /*ddparam*/ 0.99
			,/*minfre*/ 0.0001
			,/*maxfreq*/ 2
			,/*ampscale*/ 0.000001
			,/*durscale*/ 0.01
			,/*initCPs*/ 12
			,/*knum*/ 1
			,/*mul*/ 0.5)
	));
	sig = Pan2.ar(sig, LFNoise1.kr(LFNoise1.kr(panFreq,100,100)),amp);
	Out.ar(out,sig);
}).add;

SynthDef("autoformant", {arg fund=80,form=300,bw=600,ampLag=2,out=0,speed1=0.1, speed2=0.1,pres=0.5;
	var amp = NamedControl.kr(\amp,0.2,ampLag);
	var sig, fundfq, formfq, bwfq, randy;

	randy = [LFNoise0.kr(0.5*speed2,100,100)/100,LFNoise0.kr(0.2*speed2,100,100)/100,LFNoise0.kr(0.75*speed2,100,100)/100,SinOsc.kr(0.5*speed2,pi/2).scaleneg(0),SinOsc.kr(0.33*speed2,pi/4).scaleneg(0),Pulse.kr(0.1*speed2,pi/5).scaleneg(0)];

	fundfq = SelectXFocus.kr(LFDNoise1.kr(LFDNoise1.kr(0.5,1,1)*speed1,0.5,0.5) * randy.size,	randy,randy.size/(pres*10),true) * (fund*2)	;
	formfq = SelectXFocus.kr(LFDNoise1.kr(LFDNoise1.kr(0.5,1,1)*speed1,0.5,0.5) * randy.size,randy,randy.size/(pres*10),true) * (form*2)	;
	bwfq = LFDNoise1.kr(LFDNoise1.kr(0.5,1,1)*speed1,bw,bw);
	sig = Formant.ar(fundfq	,formfq	,bwfq);
	sig = Pan2.ar(sig, LFNoise1.kr(LFNoise1.kr(0.5*speed1).range(0.1,10)),amp);
	Out.ar(out,sig);
}).add;

~pstop = {Pdef.all.do{arg i; i.stop}; ~s.stop; ~k.stop};
~presume = {Pdef.all.do{arg i; i.resume}; ~s.resume; ~k.resume};
~pplay = {arg quant=1; Pdef.all.do{arg i; i.play(quant:quant)}; ~s.play(quant:quant); ~k.play(quant:quant)};
~preset = {Pdef.all.do{arg i; i.reset}; ~s.reset};
~nstop = {Ndef.all.do{arg i; i.stop}};

~gfree = { [g, e, x, y, z, ~sines].do{arg i; if(i.class == Array) { i.do{arg j; j.free}; i.free } {i.free} }};

)

~pstop.()
~pplay.(0.5)

TempoClock.tempo = 1/8.rand+1

~k.stop

// Organismes cheuloux

g=[]; e=[]; // < METS ça / ! ! ! \
g = g.add(Synth(\autoglob,[\argA,10.0.rand,\argB,30.rand,\argC,rrand(500,1400),\amp,0.5,\panFreq,0.05, \ampLag, 0.2]))
g.do({arg i; i.set(\amp, 0.5, \ampLag, 20)})
g.do({arg i; i.free}); g=[];

e = e.add(Synth(\autoformant,[\fund,100.rand,\form,600.rand,\bw,1800.rand, \amp, 0.05, \ampLag, 0.2]))
e.do({arg i; i.set(\amp, 0, \ampLag, 10)})
e.do({arg i; i.free}); e = [];


Ndef.all
Ndef.clear()

s.freeAll

// PLOCS
(Ndef(\plocs, {
	Decay2.ar(
		Impulse.ar([0.5, 0.51625] * 2 * TRand.kr(1, 4, Dust2.kr( LFNoise0.kr(0.25).range(0.125, 2)))),
		0.01, 0.05, SinOsc.ar( LFNoise0.kr(0.125).range(600,700)*2, 0)
	) * /*amp*/ 0.25
}))
Ndef(\plocs).play

// Rand sines
(Ndef(\ff, { Mix.fill(6, {arg i;
	SinOsc.ar( LFNoise1.kr( [0.0125,0.0025,0.00375].choose * 1).range(50,106) + (i*4) * 5 * 4, 0)
}).dup
// * Line.kr(0, 1, 60) // Attaque douce
	* 0.05 }).play)
Ndef(\ff).fadeTime = 0.25
Ndef(\ff).clear(10)


(Ndef(\tiik, {
	var fr = {LFNoise1.kr(0.0125).range(3000,4000)}!2;
	SinOsc.ar(fr, 0, 0.25)
	+ SinOsc.ar(fr * LFNoise1.kr(0.0125).range(0.98, 1.1), 0, LFSaw.kr( LFNoise1.kr(0.125).range(0.125, 4) ) * 0.125 )
	* 0.5
})
)
Ndef(\tiik).play
Ndef(\tiik).fadeTime = 20
Ndef(\tiik).clear

(Ndef(\basss, { SinOsc.ar([60,55] - FSinOsc.kr(0.125,0, 4) ) * /*AMP*/ 0.25
	* LFPulse.kr(0.25, 0, LFNoise1.kr(1).range(0.1,0.75)) // "Enveloppe"
}))
Ndef(\basss).play;
Ndef(\basss).clear()

Ndef(\basss).stop; Ndef(\ff).play

~gfree.(); ~pstop.(); ~nstop.(); Ndef(\basss).play
~pstop.(); ~nstop.(); Pbindef(\k).play


Ndef(\sub, { FreqShift.ar( Ndef(\basss), LFNoise2.kr(0.5).range(-20, 100), 0, 0.3)}).play
Ndef(\sub).fadeTime = 50
Ndef(\sub).clear

Ndef.gui

Pdef.all.do{arg i; i.reset}

~pplay.()
~presume.()
~pstop.()

~gfree.()

Synth.new("snare", [\rel, 0.2])

// Claque qui coupe tout
~gfree.(); ~pstop.(); ~nstop.(); Synth.new("snare", [\amp, 1, \rel, 0.2,\att, 0.001, \pan,0, \relC, 3, \fq, 405, \cutoff, 1]);
Ndef(\basss).play

g = g.add(Synth(\autoglob,[\argA,10.0.rand,\argB,30.rand,\argC,rrand(500,1400),\amp,0.25,\panFreq,0.05, \ampLag, 0.2]))


Synth.new("snare", [\amp, 0.5, \rel, 0.4, \pan, rrand(-1 ,1.0), \relC, -6, \fq, 405, \hifreq, rrand(625,1200), \cutoff, 0.01.rand]);

// Gratte et Cherche
(Ndef(\rrr, { var sig;
	sig = { BrownNoise.ar(LFNoise2.kr(0.5)) * 0.5}!2
	* ( LFNoise2.kr( LFNoise0.kr(2).range(/*AmpMod*/ 0.15,5) )
		+ LFSaw.kr(LFNoise0.kr(0.25).range(0.25,1.2), 0, LFSaw.kr( LFNoise0.kr(1.5).range(0.5,1)))
	).range(0, /*Amp*/ 0.5)

	; sig = RLPF.ar(sig,
		LFNoise1.kr( LFNoise1.kr(0.1).range(0.1, 0.3) ).range(400, 2300), // freq
		LFNoise1.ar( LFNoise1.kr(1).range(0.1, 3) ).range(0.3, 2) //req
	)// Filter

	// min:0.9 max:-0.9 // limiter?
	// + Dust2.ar(5, LFNoise0.kr(1).range(0.25,/*Dust Amp*/ 0.5)) ;
}))

Ndef(\rrr).play
Ndef(\rrr).fadeTime = 0
Ndef(\rrr).clear()


(Ndef(\piii, {SinOsc.ar([2999, 2900, 1090, 4092, 4999]*rrand(0.9,1.1)) * SinOsc.kr(0.0125*1000,pi/2, 0.1) * 0.7});
Ndef(\jiii, {SinOsc.ar([3999, 4010, 4090, 4402, 4299]*rrand(0.9,1.1) )* SinOsc.kr([0.0125, 0.031]*1000, 0, 0.1) * 0.7}))
~nstop.(); Ndef(\piii).play; Ndef(\jiii).play;
Ndef(\piii).stop; Ndef(\jiii).stop;

Ndef(\piii).fadeTime = 0.4
Ndef(\piii).clear()

Ndef(\jiii).fadeTime = 0.45
Ndef(\jiii).clear(); Ndef(\monte).play;


(Ndef(\piji, {
	FreqShift.ar(Ndef(\piii), LFNoise1.kr(10.125).range(-500, 200) )
	+
	FreqShift.ar(Ndef(\jiii), LFNoise1.kr(10.125).range(-500, 200) )
	* LFNoise1.kr(1).range(0.5, 1)
}).play)

Ndef(\piji).stop


Ndef(\monte, { LFSaw.ar(2000 * SinOsc.kr([0.0052, 0.0051], 0, 0.125, 1), 0, 0.1) + SinOsc.ar([2222, 2300], 0, 0.1) })
Ndef(\monte).play;
Pbindef(\hot).play
Ndef(\monte).stop; Pbindef(\hot).stop; Pbindef.stop
Pbindef(\s, \dur, 1/2).play

TempoClock.tempo = 2

(Ndef(\psy, {
	SinOsc.ar([3000, 3070]
		* LFTri.kr(0.1, 0, 0, 1
			* LFSaw.kr(1)
			// + LFPulse.kr(LFNoise0.kr(0.5).range(0.5, 4), 1)
			// + LFPulse.kr(LFNoise0.kr(5).range(0.2, 4), 0 , 0.5, 1)
			* 10
		)
		, [0, pi/2], 0.5) * 0.2
}).play)

Ndef(\psy).clear;

(Ndef(\noise, {
	WhiteNoise.ar(LFNoise0.kr(0.8)) + ClipNoise.ar(LFNoise0.kr(0.6)) + BrownNoise.ar(LFNoise0.kr(0.7)) * 0.4!2
}).play)

Ndef(\noise).fadeTime = 0

Ndef(\noise).fadeTime = 10
Ndef(\noise).clear

Ndef(\noise).stop; Ndef(\fnoise, { RLPF.ar(Ndef(\noise), 2222, 0.01, 0.125)}).play

~pstop.();~nstop.(); Ndef(\s).play

// SPACE FIGHT
(Ndef(\s, { arg /*AMP*/ amp=0.3;
	var sig;
	sig = {WhiteNoise.ar(0.05) / LFNoise1.ar(/*DENSITY*/ 0.15 ) }!2;
	sig = Decay2.ar(sig, 0.1001, LFNoise1.kr(4).range(0.01,1), SinOsc.ar( PitchShift.ar(sig,0.2, LFNoise1.kr(0.5).range(/*SPEED*/ 0.001,0.5)) * /*PITCH*/ 100 + 88, 0, 0.01));

	sig = FreeVerb2.ar( sig[0], sig[1], /*MIX*/ LFNoise1.kr(0.5).range(0,0.95), /*ROOM*/ LFNoise1.kr(0.2).range(0,0.85), /*DAMP*/ LFNoise1.kr(1).range(0,0.3));

	sig = sig + DelayC.ar( [ sig[1] , sig[0]], 0.1, 0.05, LFSaw.kr(0.5).range(0.01,0.1));

	// sig = sig /2 * amp min:0.25 max:-0.25;

	// /*TO COMPRESSEUR*/ Out.ar([0, ~compCtrl.index], sig);
}))
Ndef(\s).stop(4)
Ndef(\s).fadeTime(2)



Pdef.clear; Ndef.clear;
// Chorale grenouilles
(  Ndef(\f, { var in, sig, fm, amps;
	in = WhiteNoise.ar(0.5);
	fm = {LFNoise0.kr( rrand(0.1, 0.01)).range(1, 5)};
	amps = {LFNoise1.kr( rrand(0.2, 0.4), 1, 1)};
	sig = {Mix.fill( 12, {BBandPass.ar( in, LFNoise1.kr(fm).range(1000, 3000), LFNoise1.kr(0.1).range(0.0001, /*>*/ 0.005), amps)})}!2;
	sig
}).play)
Ndef(\f).fadeTime = 10
Ndef(\f).clear(1)

Ndef.clear(60)

// Ecoulements de Formants
(Ndef(\e, {{ var sig;
	sig = Formant.ar(
		LFNoise1.kr(0.04).range(110,190),
		LFNoise1.kr( LFNoise1.kr(0.25).range(0.1,/*>*/ 60) ).range (-790, 1310),
		132, 0.1)
	* LFPulse.ar(/*>*/1, 0, /*width*/ 0.25, 4, SinOsc.kr( LFNoise1.kr(20).range(0.5,20) ) )

	; sig = PitchShift.ar( sig, 0.2, sig * sig, 0.15)
	// ; sig = sig + Decay2.ar(sig/2, 0.01, 0.02, ClipNoise.ar(0.05)) // NOISE
	// ; sig = RLPF.ar(sig, [270, 281], 0.5)
}!2}).play)

Ndef(\e).fadeTime=4
Ndef(\e).stop

// Nid de bébés formants
Ndef(\ee, { FreqShift.ar( Ndef(\e), -200 ) * LFSaw.ar(110,0, 0.5) * LFPulse.ar(90) }).play
Ndef(\ee).fadeTime = 10
Ndef(\ee).stop

Ndef(\ee).fadeTime = 10


Pdef.clear;Ndef.clear;



// Droit dans le mur : Tres distordu
(Ndef(\droit, {arg freq=600, amp=0.2; var sig;
	sig = Mix.fill(5, {var f;
		f = freq * ( 1 / (7.rand + 1) + 1) * XLine.kr(0.000001, 1, 0.5);
		SinOsc.ar(f , 0,  LFNoise1.kr(Rand(0.001, 0.25)).range(0.1, 0.5))
		+ LFTri.ar(f / 2, 0, LFNoise1.kr(Rand(0.001, 0.25)).range(0.1, 0.5))
		+ LFSaw.ar(f / 3, 0, LFNoise1.kr(Rand(0.001, 0.25)).range(0.1, 0.25))
	})!2 ;
	sig = sig * ( 1 + BrownNoise.ar());
	sig = FreqShift.ar(sig, 1000, 0, sig);
	sig = sig * amp;
}).play)
Ndef(\droit).set(\amp, 0.2, \freq, 150)
Ndef(\droit).clear(0)
Ndef(\droit).fadeTime = 20




// FOND DU PANIER ///////////////////////////////
////////////////////////////////////////////////
///////////////////////////////////////////////
//////////////////////////////////////////////
/////////////////////////////////////////////

// DRONE TUNNEL
Ndef(\wowo).stop; Ndef(\grat).stop;
(Ndef(\tunnel, { arg amp=0.2; var sig;
	sig = VarSaw.ar([370,369] * FSinOsc.kr(330 * LFNoise1.kr(0.25).range(0.2, 1)).range(0.5,1.5), 2, LFNoise1.kr(0.1025).range(0.2,0.9), LFPulse.kr(90,0,LFNoise1.kr(0.25).range(0.2,0.8), 0.5))
	+ LFPulse.ar(420, 0, 0.5, VarSaw.ar(300, 0, LFNoise1.kr(0.025).range(0, 1),0.5))
	; sig = RLPF.ar(sig, 1500 * LFNoise1.kr(0.0123).range(0.2, 1.2), 0.5) // LowPass Filter
	// ; sig = FreqShift.ar(sig, LFNoise2.kr(0.125).range(-200, 1200)) // Transposer
	* amp
	// * Line.kr(0, 1, 60) // Entrée douce
	* LFPulse.kr(8,0, 0.33).lag(0.125) // Hachage
	// * (Ndef(\bassclik) * 10)
}).play)
Ndef(\tunnel).set(\amp, 0.2)
Ndef(\tunnel).fadeTime = 30
Ndef(\tunnel).clear()



(Ndef(\grat, { arg amp=0.1; var sig, fm, am;
	fm = LFNoise1.kr([4, 4]) + VarSaw.kr(0.75, 0, 0.5, /*Accidents*/ 0.5, -0.5);
	sig = BrownNoise.ar(1)
	* LFSaw.kr(LFNoise1.kr(0.5).range(0.5, 6)!2)
	* (SinOsc.kr(1.2) + VarSaw.kr(1.8, 0, LFNoise1.kr(0.125).range(0.2, 0.7)) + LFPulse.kr(0.9, 0, 0.5, 2, -1))
	* LFPulse.kr(LFNoise1.kr(0.5).range(0.25, 4), 0, LFNoise1.kr(2).range(/*Densité*/ 0.09, 0.25))
	;
	sig = BPF.ar(sig, fm.range(120, 780), LFNoise1.kr([1,1]).range(0.1, 2));
	// sig = sig * (1 + ClipNoise.ar(2));
	(sig max:-0.8 min:0.8) * amp
}).play)
Ndef(\grat).fadeTime = 30
Ndef(\grat).set(\amp, 0.4)
Ndef(\grat).clear



// Grasse larves
Ndef(\wowo, { SinOsc.ar(SinOsc.ar([4,8]).range(380,60), 0, SinOsc.ar( LFNoise1.ar(0.25).range(0.5,3), [0, pi/3]) * LFSaw.ar(66)) min:0.8 max:-0.8 * 0.1}).play
Ndef(\wowo).fadeTime = 0
Ndef(\wowo).clear


// Space ship
(Ndef(\rezone, { arg freq = 180, amp=0.2; var sig;
	sig = LFPulse.ar([freq, freq*1.05], 0) + LFSaw.ar(freq*1.01,0, 2, -1) * SinOsc.ar(freq*0.99, 0, LFSaw.kr(0.01), 1);
	// sig = PitchShift.ar(sig, 0.2, [0.25, 1.75], 0.05, 0.015, 1.5) + sig; // Complexifier
	sig = sig min:1 max:-1;
	sig = sig * amp;
}).play)
Ndef(\rezone).clear(0)
Ndef(\rezone).fadeTime = 60
Ndef(\rezone).set(\freq,250, \amp, 0.1)

Pdef.clear; Ndef.clear;
