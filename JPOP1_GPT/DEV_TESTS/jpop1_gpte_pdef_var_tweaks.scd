
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
Pdef(\kick,
	Pbind(
		\instrument, \jpKick,
		\dur, Pfunc { 1 * ~kickDur },
		\amp, Pfunc { 0.95 * ~kickAmp },
		\finish, Pfunc { ~pump.set(\trig, 1); }
	)).play;

Pdef(\snare,
	Pbind(
		\instrument, \jpSnare,
		\dur, 1,
		\amp, Pseq([0, 0.65, 0, 0.72], inf),
		\out, 0
	)).play;

Pdef(\hat,
	Pbind(
		\instrument, \jpHat,
		\dur, 0.5,
		\decay, Pseq([0.05,0.04,0.05,0.04, 0.06,0.04,0.05,0.09], inf),
		\amp, 0.18,
		\out, 0
	)).play;

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
	)).play;

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
	)).play;

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
	)).play;

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
	)).play;
