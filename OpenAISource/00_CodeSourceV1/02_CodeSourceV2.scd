//:1 Motif devfinition
~motifDegrees = [0, 2, 4, 1, 0];  // pentatonic contour
~motifDur = [0.125, 0.125, 0.25, 0.125, 0.25];
~scale = Scale.majorPentatonic;
//:2 Phase 1 -- Idol Plastic Version - define
//### Phase 1 — Idol Plastic Version
Pdef(\motif_phase1,
	Pbind(
		\instrument, \toySparkle,
		\scale, ~scale,
		\degree, Pseq(~motifDegrees, inf),
		\dur, Pseq(~motifDur, inf),
		\octave, 6,
		\amp, 0.08
));
//:2b PHase1 Idol Plastic Version - play
Pdef(\motif_phase1).play
//:3 Phase 2 - Sensual Blur version
//### Phase 2 — Sensual Blur Version
Pdef(\motif_phase2,
	Pbind(
		\instrument, \postPad,
		\scale, ~scale,
		\degree, Pseq(~motifDegrees, inf),
		\dur, Pseq(~motifDur * 8, inf),
		\octave, 4,
		\amp, 0.15
));
//:
Pdef(\motif_phase2).play;
//: 2c Phase 3 — Ritual Fragment Version
Pdef(\motif_phase3,
	Pbind(
		\instrument, \ritualDrum,
		\dur, Pseq(~motifDur * 4, inf)
));
//:
Pdef(\motif_phase3).play;

//: 3 ============================== Global clock and quantized switching
~clock = TempoClock.new(120/60);
Pdef(\motif_phase1).play(~clock, quant:1);
Pdef(\motif_phase1).stop;
Pdef(\motif_phase2).play(~clock, quant:1);
Pdef(\motif_phase2).stop;

//: 4 Phase manager function
~phase = { |n|
	Pdef.all.do(_.stop);

	case
	{ n == 1 } { Pdef(\motif_phase1).play(~clock, quant:1); }
	{ n == 2 } { Pdef(\motif_phase2).play(~clock, quant:1); }
	{ n == 3 } { Pdef(\motif_phase3).play(~clock, quant:1); };
};
//: Test phases
~phase.(1);
~phase.(2);
~phase.(3);
//: 5 Individually triggerred short sounds
Synth(\cutNoise);

Synth(\metalSlice);
//: 5b repeated variations -clouds- of short sounds
~cloud = { | synthdef = \cutNoise, n = 5, dt = 0.1 |
	fork {
		n do: {
			Synth(synthdef);
			dt.next.wait;
		}
	}
};
// NOTE: the above can be developed to perform more varied shapes! (cloud-phrases)
// 
//: Test
~cloud.(\cutNoise);
~cloud.(\metalSlice);
//: Alternate cloud model: Pbind
Pbind(\instrument, \metalSlice, \dur, Pn(0.1, 5), \freq, 5000).play;
Pbind(\instrument, \metalSlice, \dur, Pn(0.1, 5), \freq, Pgeom(4000, 1.1, 5)).play;
Pbind(\instrument, \metalSlice, \dur, Pn(0.05, 50), \freq, Pwhite(4000, 5000, inf)).play;
//:
~metalCloud

//:------ J-Pop Parody Chorus -------
//: chorus melody
~chorus = [0,4,5,4,2,0];
//:
Pdef(\chorus_clean,
	Pbind(
		\instrument, \toySparkle,
		\scale, Scale.major,
		\degree, Pseq(~chorus, inf),
		\dur, 0.25,
		\octave, 6,
		\amp, 0.1
));
//: play chorus
Pdef(\chorus_clean).play; //:!!!!! we need more varied sounds and longer duration synths!