
SynthDef(\jpKick, { |out=0, amp=0.9|
	var env  = EnvGen.kr(Env.perc(0.001, 0.22, curve: -4), doneAction: 2);
	var fenv = EnvGen.kr(Env([80, 48, 32], [0.02, 0.18], curve: -6));
	var click = HPF.ar(WhiteNoise.ar(0.2), 6000) * EnvGen.kr(Env.perc(0.001, 0.02));
	var body = SinOsc.ar(fenv.midicps) * env;
	var sig  = (body*1.2 + click*0.35) * amp;
	sig = LeakDC.ar(sig);
	Out.ar(out, sig!2);
}).add;

SynthDef(\jpSnare, { |out=0, amp=0.6|
	var env     = EnvGen.kr(Env.perc(0.002, 0.18, curve: -3), doneAction: 2);
	var toneEnv = EnvGen.kr(Env.perc(0.001, 0.09, curve: -4));
	var noise   = BPF.ar(WhiteNoise.ar, 2600, 0.55) + HPF.ar(WhiteNoise.ar, 6000)*0.5;
	var tone    = SinOsc.ar(200) * toneEnv * 0.6;
	var sig = (noise*0.9 + tone) * env * amp;
	Out.ar(out, sig!2);
}).add;

SynthDef(\jpHat, { |out=0, amp=0.22, decay=0.05|
	var env = EnvGen.kr(Env.perc(0.001, decay, curve: -6), doneAction: 2);
	var sig = HPF.ar(WhiteNoise.ar, 7000);
	sig = BPF.ar(sig, 9000, 0.4) + BPF.ar(sig, 12000, 0.25);
	sig = sig * env * amp;
	Out.ar(out, sig!2);
}).add;

SynthDef(\jpDucker, { |in=0, out=0, duck=0.0, amount=0.65|
	var sig = In.ar(in, 2);
	var g   = (1 - duck).clip(0, 1).pow(2);
	sig = sig * (g.linlin(0, 1, 1-amount, 1));
	Out.ar(out, sig);
}).add;

SynthDef(\jpPumpCtl, { |out=0, trig=0, att=0.001, rel=0.22|
	var e = EnvGen.kr(Env([0, 1, 0], [att, rel], curve: [-6, -4]), trig);
	Out.kr(out, e);
}).add;

SynthDef(\jpBass, { |out=0, amp=0.35, gate=1, freq=55, cutoff=900, pan=0|
	var env = EnvGen.kr(Env.asr(0.005, 1, 0.08, curve: -4), gate, doneAction: 2);
	var osc = Saw.ar(freq * [1, 1.005]).sum * 0.5;
	var sub = SinOsc.ar(freq*0.5) * 0.25;
	var sig = (osc + sub);
	sig = LPF.ar(sig, cutoff.clip(100, 8000));
	sig = sig.tanh * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\jpChord, { |out=0, amp=0.22, gate=1, freq=220, pan=0, bright=0.6|
	var env = EnvGen.kr(Env.asr(0.01, 1, 0.25, curve: -4), gate, doneAction: 2);
	var det = [0.0, 0.7, -0.6].midiratio;
	var osc = Pulse.ar(freq * det, 0.45) * 0.35
	+ Saw.ar(freq * det) * 0.20;
	var sig = Splay.ar(osc, 0.35, 1);
	var cf  = (freq * (6 + (bright*10))).clip(300, 9000);
	sig = RLPF.ar(sig, cf, 0.25);
	sig = sig * env * amp;
	Out.ar(out, Balance2.ar(sig[0], sig[1], pan));
}).add;

SynthDef(\jpPluck, { |out=0, amp=0.18, freq=440, decay=2.0, pan=0|
	var exc = PinkNoise.ar(0.5) * EnvGen.kr(Env.perc(0.001, 0.02));
	var sig = Pluck.ar(exc, 1, 1/freq, 1/freq, decay, coef: 0.35);
	sig = HPF.ar(sig, 180);
	sig = (sig * 3).tanh * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\jpLead, { |out=0, amp=0.18, gate=1, freq=440, pan=0, vib=0.18|
	var env = EnvGen.kr(Env.adsr(0.01, 0.10, 0.65, 0.18, curve: -4), gate, doneAction: 2);
	var v   = SinOsc.kr(5.8, 0, vib).midiratio;
	var sig = (Saw.ar(freq*v) * 0.45 + Pulse.ar(freq*v*2, 0.48) * 0.18);
	sig = RLPF.ar(sig, (freq*10).clip(800, 9000), 0.18);
	sig = (sig * 2).tanh * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
