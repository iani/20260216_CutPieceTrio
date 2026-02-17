
// SynthDefs:
// \toyPiano, \musicBox, \glitchNoise, \heartPulse, \breathing,
// \fmSynth, \cuttingSound, \darkDrone, \choirVoice, \fragmentNoise
// ------- fx --------- ;
// \reverb, masterOut
//: 
	SynthDef(\toyPiano, {
		arg out=0, freq=440, amp=0.3, gate=1, cutoff=2000, rq=0.5;
		var sig, env;
		env = EnvGen.kr(Env.adsr(0.01, 0.2, 0.3, 0.8), gate, doneAction: 2);
		sig = SinOsc.ar(freq) * 0.7;
		sig = sig + SinOsc.ar(freq * 2.01) * 0.2;  // Slight detuning
		sig = sig + SinOsc.ar(freq * 4.02) * 0.1;
		sig = RLPF.ar(sig, cutoff, rq);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\musicBox, {
		arg out=0, freq=440, amp=0.25, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.perc(0.005, 0.4), gate, doneAction: 2);
		sig = Pulse.ar(freq, 0.3) + SinOsc.ar(freq * 2);
		sig = BPF.ar(sig, freq * 4, 0.1);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\glitchNoise, {
		arg out=0, amp=0.1, rate=1, cutoff=1000;
		var sig;
		// sig = Dust.ar(rate * [30, 35]);
		sig = Decay.kr(Dust.kr(rate * [30, 35]));
		sig = sig * WhiteNoise.ar(0.3);
		sig = BPF.ar(sig, cutoff, 0.3);
		sig = sig * amp;
		Out.ar(out, sig * Env.asr.kr(2, \gate.kr(1)));
	}).add;
	
	// SECTION 2: Pulse / Breathing / Cutting
	SynthDef(\heartPulse, {
		arg out=0, freq=60, amp=0.4, gate=1;
		var sig, env, trig;
		trig = Impulse.kr(freq/60);
		env = EnvGen.kr(Env.perc(0.001, 0.3), trig);
		sig = SinOsc.ar(80 + (env * 200));
		sig = sig + LFTri.ar(40);
		sig = sig * env * amp;
		sig = Pan2.ar(sig, LFNoise1.kr(0.3));
		Out.ar(out, sig * Env.adsr.kr(2, gate));
	}).add;
	
	SynthDef(\breathing, {
		arg out=0, amp=0.3, rate=0.15;
		var sig, breathEnv;
		breathEnv = LFTri.kr(rate).range(0, 1);
		sig = PinkNoise.ar(0.3);
		sig = BPF.ar(sig, breathEnv.linexp(0, 1, 300, 1200), 0.5);
		sig = sig * breathEnv * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\fmSynth, {
		arg out=0, freq=440, amp=0.3, modRatio=3, modIndex=5, gate=1;
		var sig, env, mod;
		env = EnvGen.kr(Env.adsr(0.1, 0.3, 0.5, 1.2), gate, doneAction: 2);
		mod = SinOsc.ar(freq * modRatio) * modIndex * freq;
		sig = SinOsc.ar(freq + mod);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\cuttingSound, {
		arg out=0, amp=0.5;
		var sig, env;
		env = EnvGen.kr(Env.perc(0.001, 0.1), doneAction: 2);
		sig = WhiteNoise.ar();
		sig = HPF.ar(sig, 3000);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	// SECTION 3: Drone / Choir / Ritual
	SynthDef(\darkDrone, {
		arg out=0, freq=65, amp=0.4, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(2, 1, 4), gate, doneAction: 2);
		sig = Mix([
			Saw.ar(freq),
			Saw.ar(freq * 1.01),
			Saw.ar(freq * 0.99),
			Pulse.ar(freq * 0.5, 0.3)
		]);
		sig = LPF.ar(sig, 400);
		sig = sig * env * amp * 0.25;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\choirVoice, {
		arg out=0, freq=440, amp=0.3, gate=1, spread=0.01;
		var sig, env;
		env = EnvGen.kr(Env.asr(1.5, 0.8, 3), gate, doneAction: 2);
		sig = Mix([
			SinOsc.ar(freq),
			SinOsc.ar(freq * (1 + spread)),
			SinOsc.ar(freq * (1 - spread)),
			SinOsc.ar(freq * 2) * 0.1
		]);
		sig = sig * env * amp * 0.33;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\fragmentNoise, {
		arg out=0, amp=0.2, density=5;
		var sig, trig;
		trig = Dust.ar(density);
		sig = BrownNoise.ar(0.5) * Decay.ar(trig, 0.3);
		sig = CombC.ar(sig, 0.2, LFNoise1.kr(0.3).range(0.02, 0.15), 2);
		sig = sig * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	// EFFECTS
	SynthDef(\reverb, {
		arg in=0, out=0, mix=0.6, room=3;
		var sig;
		sig = In.ar(in, 2);
		sig = FreeVerb.ar(sig, mix, room.clip(0, 1), 0.5);
		Out.ar(out, sig);
	}).add;
	
	SynthDef(\masterOut, {
		arg in=0, out=0, amp=0.7;
		var sig;
		sig = In.ar(in, 2);
		sig = Limiter.ar(sig, 0.95);
		Out.ar(out, sig * amp);
	}).add;

//:--------------------------------------------------------------------
//: Test SynthDefs
fork {
	[\toyPiano, \musicBox, \glitchNoise, \heartPulse, \breathing,
 \fmSynth, \cuttingSound, \darkDrone, \choirVoice, \fragmentNoise] do: { | sd | 
	 var s;
	 sd.postln;
	 s = Synth(sd);
	 1.wait;
	 s.release;
	 1.wait;
};
	"DONE".postln;
}

//:
~s = Synth(\toyPiano); // OK
~s.release;
//:
~s = Synth(\musicBox); // fixed duration
~s.release; // release not applicable 
//:
~s = Synth(\glitchNoise);		
~s.release;
//:
~s = Synth(\heartPulse);
~s.release;
//:
~s = Synth(\breathing);
~s.release;
//:
~s = Synth(\fmSynth);
~s.release;
//:
~s = Synth(\cuttingSound);
~s.release;
//:
~s = Synth(\darkDrone);
~s.release;
//:
~s = Synth(\choirVoice);
~s.release;
//:
~s = Synth(\fragmentVoice);
~s.release;
//:
~s = Synth(\heartPulse);
~s.release;
//: