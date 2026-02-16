//:01 Plastic Innocence _ Kawaii Ritual
//: --------- If using sc-hacks-redux, then enable Mediator environment for operators:
User.enable; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
//:01a synthdef 
// Toy Sparkle Synth
SynthDef(\toySparkle, { |out=0, freq=800, amp=0.1|
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.2), doneAction:2);
	sig = SinOsc.ar(freq * [1, 1.01]) * 0.4;
	sig = sig + Pulse.ar(freq*2, 0.3, 0.2);
	sig = LPF.ar(sig, 4000);
	Out.ar(out, (sig * env * amp).dup);
}).add;
//:01b synthdef test
Synth(\toySparkle);
//:01c glitter pattern - define but do not start
// Glitter Pattern
Pdef(\phase1,
	Pbind(
		\instrument, \toySparkle,
		\scale, Scale.major,
		\degree, Pwhite(0, 7),
		\octave, 6,
		\dur, 0.125,
		\amp, 0.08
	))
//: experiment: start and stop

Pdef(\phase1).play;
Pdef(\phase1).stop;
