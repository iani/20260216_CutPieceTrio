//: Add all synthdefs
//synthdef 1 toySparkle
SynthDef(\toySparkle, { |out=0, freq=800, amp=0.1|
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.2), doneAction:2);
	sig = SinOsc.ar(freq * [1, 1.01]) * 0.4;
	sig = sig + Pulse.ar(freq*2, 0.3, 0.2);
	sig = LPF.ar(sig, 4000);
	Out.ar(out, (sig * env * amp).dup);
}).add;
// SynthDef 2 softKick

SynthDef(\softKick, {
	var env = EnvGen.kr(Env.perc(0.001, 0.2), doneAction:2);
	var sig = SinOsc.ar(60, 0, 0.5) * env;
	Out.ar(0, sig.dup);
}).add;

// SynthDef 3 postPad (Posthuman Pad)

// Posthuman Pad
SynthDef(\postPad, { |out=0, freq=220, amp=0.2|
	var env = Env.asr(2,1,3);
	var sig;
	sig = Saw.ar(freq * [1,1.005]);
	sig = RLPF.ar(sig, XLine.kr(200, 2000, 10), 0.3);
	sig = sig * amp * env.kr(2, \gate.kr(1));
	Out.ar(out, sig);
}).add;

// SynthDef 4 cutNoise (Whisper cuts)
SynthDef(\cutNoise, {
	var env = EnvGen.kr(Env.perc(0.001, 0.15), doneAction:2);
	var sig = WhiteNoise.ar * env;
	sig = HPF.ar(sig, 3000);
	Out.ar(0, sig.dup * 0.1);
}).add;


// SynthDef 5 ritualDrum (Ritual Drum)
SynthDef(\ritualDrum, {
	var env = EnvGen.kr(Env.perc(0.01,0.6), doneAction:2);
	var sig = SinOsc.ar(70, 0, 0.8) * env;
	sig = sig + BPF.ar(WhiteNoise.ar, 200, 0.2) * 0.2;
	Out.ar(0, sig.dup * 0.4);
}).add;

// SynthDef 6 metalSlice (Metallic cut gesture)
SynthDef(\metalSlice, { | freq = 4000, ringtime = 0.2 |
	var env = EnvGen.kr(Env.perc(0.001, 0.2), doneAction:2);
	var sig = Ringz.ar(Impulse.ar(0), freq, ringtime);
	Out.ar(0, sig.dup * 0.3);
}).add;

SynthDef(\distChorus, { |freq=440|
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01,0.6), doneAction:2);
	sig = Saw.ar(freq) * 0.5;
	sig = tanh(sig * 4);
	sig = LPF.ar(sig, 1200);
	Out.ar(0, sig.dup * env * 0.3);
}).add;

//: Try the synthdefs individually
{
	[\toySparkle, \softKick, \postPad, \cutNoise, \ritualDrum, \metalSlice, \distChorus] do: { | sd |
		var s;
		sd.postln;
		s = Synth(sd);
		2.wait;
		s.release;
		1.wait;
	};
	"DONE".postln;
}.fork;

//
a = Synth(\postPad);
a.release;