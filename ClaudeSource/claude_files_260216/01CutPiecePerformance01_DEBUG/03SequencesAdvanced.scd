// 
~climax = {
	fork {
		"CLIMAX SEQUENCE".postln;
		
		// Rapid cuts
		10.do({
			// Synth(\cuttingSound, [\out, ~cutPiece.masterBus, \amp, 0.7]);
			Synth(\cuttingSound, [\out, ~cutPiece.masterBus, \amp, 0.1 rrand: 0.7]);
			0.2.wait;
		});
		
		0.5.wait;
		
		// Shatter
		Synth(\shatter, [\out, ~cutPiece.masterBus, \amp, 0.6]);
		
		1.wait;
		
		// Deep silence
		// ~cutPiece.macro.silence.();
		
		2.wait;
		
		// Restore with drone
		// ~cutPiece.macro.restoreVolume.();
		Synth(\darkDrone, [
			\out, ~cutPiece.reverbBus,
			\freq, 55,
			\amp, 0.3
		]
		//,  ~cutPiece.groups.section3);
		);
	};
}
//:
~climax.value;