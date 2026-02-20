// Pdefs to check: (7)
// \kick, \snare, \hat, \chords, \bass, \arp, \lead, \
//: 
Pdef(\hat).play; // ok
//: Details:
Synth(\jpHat);
//:

Pdef(\kick).play; // OK
// After fixing error:
// FAILURE IN SERVER /n_set Node 1002 not found
// Fixed by removing the \finish key.
//:detail:
Synth(\jpKick);
//:
Pdef(\snare).play; // 
//: both play together, synchrized by quant:
Pdef(\snare).play; // OK
Pdef(\hat).play; // ok
//: \snare, \hat, \kick: OK
Pdef(\kick).play; // OK
Pdef(\snare).play; // OK
Pdef(\hat).play; // ok

//----------------------------------------------------------------------
//: NO sound. Needs checking:
Pdef(\chords).play;
Pdef(\bass).play;


