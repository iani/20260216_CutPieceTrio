
// ===== ADDITIONAL SYNTHDEFS =====
// \granularCut, \vinylCrackle, \bell, \whisper
// \shatter, \strings, 

//:
~s = Synth(\granularCut);
~s.release;
//:
~s = Synth(\vinylCrackle);
~s.release;
//:
~s = Synth(\bell);
~s.release; // release not applicable 
//:
~s = Synth(\whisper);
~s.release;
//:
~s = Synth(\shatter);
~s.release; // release not applicable
//:
~s = Synth(\strings);
~s.release;
//:

//: Granular texture for cutting moments
SynthDef(\granularCut, {
	arg out=0, bufnum, rate=10, pos=0, amp=0.3, pan=0;
	var sig, trig;
	trig = Impulse.ar(rate);
	sig = TGrains.ar(
		numChannels: 2,
		trigger: trig,
		bufnum: bufnum,
		rate: LFNoise1.kr(0.5).range(0.8, 1.2),
		centerPos: pos,
		dur: 0.1,
		pan: LFNoise1.kr(1).range(-0.5, 0.5),
		amp: amp
	);
	Out.ar(out, sig * Env.asr.kr(2, \gate.kr(1)));
}).add;

// Vinyl crackle (for nostalgic J-Pop feel)
SynthDef(\vinylCrackle, {
	arg out=0, amp=0.25, density=50;
	var sig;
	sig = Dust.ar(density ! 2) * 0.3;
	sig = BPF.ar(sig, LFNoise1.kr(2).range(2000, 8000), 0.1);
	sig = sig * amp * Env.asr.kr(2, \gate.kr(1));
	Out.ar(out, sig);
}).add;

// Ritualistic bell
SynthDef(\bell, {
	arg out=0, freq=440, amp=0.4, decay=3, strike=1;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
	sig = Klank.ar(
		`[[1, 2.1, 3.2, 4.7, 5.1],
		  [1, 0.5, 0.25, 0.1, 0.05],
		  [decay, decay*0.8, decay*0.6, decay*0.4, decay*0.2]],
		Impulse.ar(0) * strike,
		freq
	);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Whisper texture
SynthDef(\whisper, {
	arg out=0, amp=0.2, rate=0.1;
	var sig, mod;
	mod = LFNoise1.kr(rate).range(0, 1);
	sig = WhiteNoise.ar(0.5);
	sig = BPF.ar(sig, mod.linexp(0, 1, 800, 3000), 0.3);
	sig = sig * mod * amp * Env.asr.kr(2, \gate.kr(1));
	Out.ar(out, sig ! 2);
}).add;

// Shattered glass (for cutting climax)
SynthDef(\shatter, {
	arg out=0, amp=0.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.3), doneAction: 2);
	sig = WhiteNoise.ar();
	sig = Resonz.ar(sig, Array.fill(12, { exprand(2000, 12000) }), 0.001).sum;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Sostenuto strings (for emotional moments)
SynthDef(\strings, {
	arg out=0, freq=440, amp=0.25, gate=1, vibrato=5;
	var sig, env, vib;
	env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);
	vib = SinOsc.kr(vibrato).range(0.98, 1.02);
	sig = Mix([
		Saw.ar(freq * vib),
		Saw.ar(freq * 1.01 * vib),
		Saw.ar(freq * 0.99 * vib)
	]);
	sig = LPF.ar(sig, 3000);
	sig = sig * env * amp * 0.33;
	Out.ar(out, sig ! 2);
}).add;

