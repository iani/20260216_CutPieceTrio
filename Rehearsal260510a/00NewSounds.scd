

//: 2 Enable selective starting and stopping of Pdefs
~pdefs = [\kick, \snare, \hat, \chords, \bass, \arp, \lead];
//:
~startdef.(\kick);
Pdef(\kick).stop;
//:
~startdef.(\snare);
Pdef(\snare).stop;
//:
~startdef.(\hat);
Pdef(\hat).stop;
//:
~startdef.(\chords);
Pdef(\chords).stop;
//:
~startdef.(\bass);
Pdef(\bass).stop;
//:
~startdef.(\arp);
Pdef(\arp).stop;
//:
~startdef.(\lead);
Pdef(\lead).stop;
//:
Pdef(\ostinato, )
//
//

~startdef = { | defname | Pdef(defname).play };
~stopdef = { | defname | Pdef(defname).stop };
~startdefs = { | defs |
	(defs ?? { ~pdefs }).asArray do: { | d | ~startdef.(d) }
};
~stopdefs = { | defs |
	(defs ?? { ~pdefs }).asArray do: { | d | ~stopdef.(d) }
};
// 
//:--------------------------------------------------------------------------------
Pdef(\ostinato, Pbind(
			\instrument, \jpChord,
			\out, ~musicBus,
			// \out, 0,
			\dur, 2,
			\amp, Prand([0.20, 0.40, 0.50, 0.70], inf),
			\bright, Pseg(Pseq([0.45, 0.7, 0.55, 0.75], inf), 8),
			\legato, 0.95,
			\pan, Pwhite(-0.2, 0.2),
			\degree, Pseq([0, 3, 4, 5], inf),
			\strum, 0.02
		)
).play;
//:--------------------------------------------------------------------------------
Pdef(\ostinato, Pbind(
			\instrument, \jpChord,
			\out, ~musicBus,
			// \out, 0,
			\dur, Prand([2, Pseq([1, 1], 1), Pseq([1, 2, 1], 1)], inf),
			\amp, Prand([0.20, 0.40, 0.50, 0.70], inf),
			\bright, Pseg(Pseq([0.45, 0.7, 0.55, 0.75], inf), 8),
			\legato, 0.95,
			\pan, Pwhite(-0.2, 0.2),
			\degree, Pseq([0, 3, 4, 5], inf),
			\octave, Prand([5, 3, 4, 6, 7], inf),
			\strum, 0.02
			)
).play;
//:
Pdef(\ostinato).stop;