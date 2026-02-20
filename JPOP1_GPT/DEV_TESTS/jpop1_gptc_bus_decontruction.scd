// Deconstructing the pdefs and reconstructing them with effects.
// Try out different effect settings to tune the piece.

// -------- List of Pdefs --------
// \kick, \snare, \hat, \chords, \bass, \arp, \lead

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
Pdef(\arp).play; // tweaked: amp 0.12 -> 0.72 !
Pdef(\arp).stop; // tweaked: amp 0.12 -> 0.72 !
Pdef(\lead).play;
Pdef(\lead).stop;


Pdef(\chords).stop;

~kickAmp = 0.21;
~kickDur = 1.5;
~kickDur = 2.9;
~kickDur = 2.5;

//:
a = Synth(\jpPluck);
