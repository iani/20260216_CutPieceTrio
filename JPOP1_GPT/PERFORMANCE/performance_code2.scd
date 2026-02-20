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
//: 1 LOAD --------------- SYNTHDEFS, PDEFS, BUSES --------------
(PathName(Document.current.path).pathOnly +/+ "performance_code1.scd").load;

// -------- List of Pdefs --------
// \kick, \snare, \hat, \chords, \bass, \arp, \lead
//: 2 Enable selective starting and stopping of Pdefs
~pdefs = [\kick, \snare, \hat, \chords, \bass, \arp, \lead];
~startdef = { | defname | Pdef(defname).play }; 
~stopdef = { | defname | Pdef(defname).stop };
~startdefs = { | defs |
	(defs ?? { ~pdefs }).asArray do: { | d | ~startdef.(d) }
};
~stopdefs = { | defs |
	(defs ?? { ~pdefs }).asArray do: { | d | ~stopdef.(d) }
};
//: 3 ------------ start all Pdefs --------------
~startdefs.();
//: 4. Fadeout voice by voice, at intervals growing by golden ratio

var phi   = (1 + 5.sqrt) * 0.5;
var base  = 5;       // in beats
var q     = 4.asQuant;
var t0    = q.nextTimeOnGrid(TempoClock.default);

var names = [\kick, \snare, \hat, \chords, \bass, \arp, \lead];

names do: { |defn, i|
    var t = base * phi.pow(i + 1);  // φ, φ², φ³, ...

    TempoClock.default.schedAbs(t0 + t, {
		postln("Stopping:" + defn);
        Pdef(defn).stop;
        nil
    });
};

//: fadein single voices for short intervals at diverse time points
Pdef(\kick).play;
Pdef(\kick).stop;
Pdef(\snare).play;
Pdef(\snare).stop;
Pdef(\hat).play;
Pdef(\hat).stop;
Pdef(\chords).play;
Pdef(\chords).stop;
Pdef(\bass).play;
Pdef(\bass).stop;
Pdef(\arp).play;
Pdef(\arp).stop;
Pdef(\lead).play;
Pdef(\lead).stop;

//: Randomised fadein single voices for short intervals at diverse time points
{
	var phrase;
	phrase = { | defname = \kick, duration = 1 |
		{
		Pdef(defname).play;
		duration.wait;
		Pdef(defname).stop;	
		}.fork;
	};

	15 do: { | n |
		n.postln;
		phrase.([\kick, \snare, \hat, \chords, \bass, \arp, \lead].choose.postln, [3, 5].choose);
		[3, 5, 8, 13, 21].choose.postln.wait;
	};
	"END".postln;
}.fork;
//: ------------- Selectively change beat dur of voices -------- 
//: ---------------- Change kick cycle and amp
~startdefs.();
~stopdefs.();
~kickAmp = 1;
~kickDur = 1.5;
~kickDur = 1;
~kickDur = Pseq([0.5, 1.5, 0.1, 0.1, 2], inf).asStream;
~kickDur = Prand([0.5, 1.5, 0.1, 0.1, 2], inf).asStream;
~startdefs.(\kick);
~stopdefs.([\hat, \snare, \bass]);
~stopdefs.(\kick);
~kickDur = 0.5;
~kickAmp = Pwhite(0.01, 0.9, inf).asStream;
~kickAmp = Pbrown(0.01, 0.9, 0.1, inf).asStream;
~kickAmp = Pseq((1..100).normalize, inf).asStream;
~kickAmp = Pseq((1..100).normalize.reverse, inf).asStream;
~kickAmp = 1;
~kickFreq = 10;
~kickFreq = Pwhite(5000, 6000, inf).asStream;
~kickEnvDur = 0.004;
~kickEnvDur = 20.004;

~snareDur = 2.5;
~snareDur = 0.25;

//: ------ debug runaway synths from Pdefs!!! ------
~startdefs.();
~stopdefs.();
~arpAmp = Pseq((1..100).normalize.reverse, inf).asStream; // !!!
~arpTranspose = Pstutter(12, Pseq((10..-30), inf)).asStream; // !!!
~startdefs.(\arp);
~arpAmp = 2.1;
~arpAmp = Pseq((1..100).normalize, inf).asStream;
~arpAmp = Pseq((1..100).normalize.reverse, inf).asStream; // !!!
~arpAmp = Pwhite(0, 1.0, inf).asStream;
~arpTranspose = -10;
~arpTranspose = 10;
~arpTranspose = 1;
~arpTranspose = Pstutter(12, Pseq((-10..10), inf)).asStream;
~arpTranspose = Pstutter(12, Pseq((10..-30), inf)).asStream; // !!!


//:
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ], inf).asStream;
~prog = Pseq([ [0,2,4], [0,2,4] + 3, [0,2,4] + 1, [0,2,4] + 4, [0,2,4] + 5 ], inf).asStream;
Pdef(\chords).play;
Pdef(\chords).stop;

~prog = Pseq([ [0,4], [4,6], [5,2], [3,5] ] + 10, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] + 10, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 1, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 2, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 3, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 4, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 5, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 6, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 7, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 8, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 9, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 10, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 11, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 12, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 13, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 14, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 15, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 16, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 17, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 18, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 19, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 20, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 21, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 22, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 23, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 24, inf).asStream;
~prog = Pseq([ [0,2,4], [4,6,1], [5,0,2], [3,5,0] ] - 25, inf).asStream;
~prog = Pseq([ [4], [6], [2], [3] ] + 10, inf).asStream;
~prog = Pseq((-10..10).clump(3) + 10, inf).asStream;
~prog = Pseq((-10..10).clump(2) + 10, inf).asStream;
~prog = Pseq((-10..10).clump(1) + 10, inf).asStream;
~prog = Pseq((-10..10).clump(4) + 10, inf).asStream;


