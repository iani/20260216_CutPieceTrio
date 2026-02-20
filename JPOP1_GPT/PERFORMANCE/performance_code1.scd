// Removing all busses to see how all patterns sound together
// Busses should be added back later
// Before doing that, we explore the SynthDefs, with emphasis of the role
// of the fx synthdefs.
// -------- List of SynthDefs --------
// ---- A: Instrument sources
// jpKick : kick drum
// jpSnare : snare drum
// jpHat : high-hat
// jpBass : Sound for bass line.
// jpChord : Sound for chords.
// jpPluck : Plucked instrument sound
// jpLead : Quasi-lead guitar sound
// ---- B: Control-signal Sources
// jpPumpCtl : Outputs a control-rate envelope.  WHERE IS THIS USED?
// ---- C: Effects (process audio input and output a changed result)
// jpDucker : Effect. Ducks the signal.  TO EXPLORE HOW DOES DUCKING CHANGE THE SOUND?
// jpGlue : Effect. Adds modulated chorus delay and reverb.
// 
// -------- List of Pdefs --------
// \kick, \snare, \hat, \chords, \bass, \arp, \lead

(
s.waitForBoot({

	TempoClock.default.tempo = 128/60; // 128 BPM

	SynthDef(\jpKick, { |out=0, amp=0.9, freq = 6000 |
		var env  = EnvGen.kr(Env.perc(0.001, 0.22, curve: -4), doneAction: 2);
		var fenv = EnvGen.kr(Env([80, 48, 32], [0.02, 0.18], curve: -6));
		var click = HPF.ar(WhiteNoise.ar(0.2), freq) * EnvGen.kr(Env.perc(0.001, 0.02));
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
		DetectSilence.ar(sig, 0.001, 0.1, 2);
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

	SynthDef(\jpGlue, { |in=0, out=0, mix=0.22|
		var sig = In.ar(in, 2);
		var mod  = SinOsc.kr([0.23, 0.27], 0, 0.002, 0.003);
		var chor = DelayC.ar(sig, 0.03, mod);
		var wet  = FreeVerb2.ar(chor[0], chor[1], mix, 0.75, 0.25);
		Out.ar(out, (sig*(1-mix) + wet*mix));
	}).add;

	s.sync;

	[\kick, \snare, \hat, \chords, \bass, \arp, \lead].do { |k| Pdef(k).stop };

	~musicBus = Bus.audio(s, 2);
	~glueBus  = Bus.audio(s, 2);
	~duckBus  = Bus.control(s, 1);

	~glue.tryPerform(\free);
	~ducker.tryPerform(\free);
	~pump.tryPerform(\free);

	~glue   = Synth.tail(s, \jpGlue, [\in, ~glueBus, \out, 0, \mix, 0.24]);
	~ducker = Synth.before(~glue, \jpDucker, [\in, ~musicBus, \out, ~glueBus, \duck, ~duckBus, \amount, 0.70]);
	~pump   = Synth.head(s, \jpPumpCtl, [\out, ~duckBus]);

	~majorSteps = #[0, 2, 4, 5, 7, 9, 11];
	~rootMidi   = 60;

	~degToMidi = { |deg, oct=0|
		var d        = deg.asInteger;
		var step     = ~majorSteps.wrapAt(d);
		var octShift = (d.div(7) + oct) * 12;
		~rootMidi + step + octShift
	};

	~prog       = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ], inf).asStream;
	~curTri     = [0,2,4];

	~hookStream = Pseq([
		7, 7, 9, 7, 12, Rest(0), 11, 9,
		7, 7, 9, 7, 14, Rest(0), 12, 11
	], inf).asStream;

	~kickAmp = 1;
	~kickDur = 1;
	~kickFreq = 6000;
	Pdef(\kick,
		Pbind(
			\instrument, \jpKick,
			\dur, Pfunc { 1 * ~kickDur.next },
			\amp, Pfunc { 0.95 * ~kickAmp.next },
			\freq, Pfunc { 1 * ~kickFreq.next },
			\finish, Pfunc { ~pump.set(\trig, 1); }
		)); // .play;

	Pdef(\snare,
		Pbind(
			\instrument, \jpSnare,
			// \dur, 1,
			// \amp, Pseq([0, 0.65, 0, 0.72], inf),
			\dur, Pfunc { 1 * ~snareDur.next },
			\amp, Pfunc { 0.95 * ~snareAmp.next },
			\out, 0
		)); // .play;

	Pdef(\hat,
		Pbind(
			\instrument, \jpHat,
			\dur, 0.5,
			\decay, Pseq([0.05,0.04,0.05,0.04, 0.06,0.04,0.05,0.09], inf),
			\amp, 0.18,
			\out, 0
		)); // .play;

	Pdef(\chords,
		Pbind(
			\instrument, \jpChord,
			\out, ~musicBus,
			// \out, 0,
			\dur, 2,
			\amp, 0.20,
			\bright, Pseg(Pseq([0.45, 0.7, 0.55, 0.75], inf), 8),
			\legato, 0.95,
			\pan, Pwhite(-0.2, 0.2),
			\midinote, Pfunc {
				var tri = ~prog.next;
				if (tri.isNil) { tri = [0,2,4] };
				~curTri = tri;
				tri.collect { |d| ~degToMidi.(d, 1) }
			},
			\strum, 0.02
		)); // .play;

	Pdef(\bass,
		Pbind(
			\instrument, \jpBass,
			\out, ~musicBus,
			// \out, 0,
			\dur, Pseq([0.5, 0.5, 1, 0.5, 0.5, 1], inf),
			\amp, 0.33,
			\cutoff, Pseg(Pseq([650, 900, 780, 1050], inf), 8),
			\legato, 0.9,
			\midinote, Pfunc {
				var tri     = if(~curTri.isArray) { ~curTri } { [0,2,4] };
				var rootDeg = tri[0];
				var choices = [rootDeg, rootDeg+1, rootDeg-1, rootDeg+7];
				~degToMidi.(choices.choose, -2)
			}
		)); // .play;

	Pdef(\arp,
		Pbind(
			\instrument, \jpPluck,
			\out, ~musicBus,
			// \out, 0,
			\dur, 0.25,
			// \amp, 0.12,
			\amp, 0.72,
			\decay, Pwhite(1.2, 2.4),
			\pan, Pwhite(-0.6, 0.6),
			\midinote, Pfunc {
				var tri = if(~curTri.isArray) { ~curTri } { [0,2,4] };
				var d   = tri.choose + [0,7,14].choose;
				~degToMidi.(d, 2)
			}
		)); // .play;

	Pdef(\lead,
		Pbind(
			\instrument, \jpLead,
			\out, ~musicBus,
			// \out, 0,
			\dur, Pseq([0.5,0.25,0.25, 0.5,0.5,0.25,0.25,0.5], inf),
			\amp, Pseg(Pseq([0.0, 0.16, 0.18, 0.0], inf), 16),
			\vib, 0.12,
			\legato, 0.95,
			\pan, Pwhite(-0.1, 0.1),
			\midinote, Pfunc {
				var d = ~hookStream.next;
				if (d.isNil)  { d = 7 };
				if (d.isRest) { d } { ~degToMidi.(d, 2) }
			}
		)); // .play;

	"J-Pop generator running!".postln;

	// Gradual Cut-out deconstruction of piece:
	{
		var dt; 
		[\kick, \snare, \hat, \chords, \bass, \arp, \lead] do: {
			
		}
	}.fork;
	
}); // end s.waitForBoot
)
