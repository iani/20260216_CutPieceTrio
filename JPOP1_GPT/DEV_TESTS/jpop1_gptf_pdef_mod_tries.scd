//
~pdefs = [\kick, \snare, \hat, \chords, \bass, \arp, \lead];
~startdef = { | defname | Pdef(defname).play }; 
~stopdef = { | defname | Pdef(defname).stop };
~startdefs = { | defs |
	(defs ?? { ~pdefs }).asArray do: { | d | ~startdef.(d) }
};
~stopdefs = { | defs |
	(defs ?? { ~pdefs }).asArray do: { | d | ~stopdef.(d) }
};
//:
~startdefs.value;
~stopdefs.value;
//:
~startdefs.();
~stopdefs.();
//:
~startdefs.(\hat);
~startdefs.(\chords);
~stopdefs.(\hat);

//: ---------------- Change kick cycle and amp
~startdefs.();
~kickAmp = 1;
~kickDur = 1.5;
~kickDur = 1;
~kickDur = Pseq([0.5, 1.5, 0.1, 0.1, 2], inf).asStream;
~kickDur = Prand([0.5, 1.5, 0.1, 0.1, 2], inf).asStream;
~startdefs.(\kick);
~stopdefs.([\hat, \snare, \bass]);
~stopdefs.(\kick);
~kickDur = 0.5;
~kickAmp = Pwhite(0.1, 0.4, inf).asStream;
~kickAmp = 1;

//: ------ debug runaway synths from Pdefs!!! ------
~startdefs.();
~stopdefs.();