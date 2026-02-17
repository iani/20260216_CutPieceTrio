/ERROR: Message 'asView' not understood.
Perhaps you misspelled 'view', or meant to call 'asView' on another receiver?
RECEIVER:
Instance of EZSlider {    (0x148b94738, gc=F0, fmt=00, flg=00, set=05)
  instance variables [21]
*
========================================
CUT PIECE - Advanced Performance Techniques
Additional sounds and live coding patterns

Run this AFTER the main CutPiecePerformance.scd file
These are additional tools and alternative approaches
========================================
*/

// ===== ADDITIONAL SYNTHDEFS =====

// Granular texture for cutting moments
SynthDef(\granularCut, {
	arg out=0, bufnum, rate=10, pos=0, amp=0.3, pan=0;
	var sig, trig;
	trig = Impulse.ar(rate);
	sig = TGrains.ar(
		numChannels: 2,
		trigger: trig,
		bufnum: bufnum,
		rate: LFNoise1.kr(0.5).range(0.8, 1.2),
		centerPos: pos,
		dur: 0.1,
		pan: LFNoise1.kr(1).range(-0.5, 0.5),
		amp: amp
	);
	Out.ar(out, sig);
}).add;

// Vinyl crackle (for nostalgic J-Pop feel)
SynthDef(\vinylCrackle, {
	arg out=0, amp=0.15, density=50;
	var sig;
	sig = Dust.ar(density ! 2) * 0.3;
	sig = BPF.ar(sig, LFNoise1.kr(2).range(2000, 8000), 0.1);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

// Ritualistic bell
SynthDef(\bell, {
	arg out=0, freq=440, amp=0.4, decay=3, strike=1;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
	sig = Klank.ar(
		`[[1, 2.1, 3.2, 4.7, 5.1],
		  [1, 0.5, 0.25, 0.1, 0.05],
		  [decay, decay*0.8, decay*0.6, decay*0.4, decay*0.2]],
		Impulse.ar(0) * strike,
		freq
	);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Whisper texture
SynthDef(\whisper, {
	arg out=0, amp=0.2, rate=0.1;
	var sig, mod;
	mod = LFNoise1.kr(rate).range(0, 1);
	sig = WhiteNoise.ar(0.5);
	sig = BPF.ar(sig, mod.linexp(0, 1, 800, 3000), 0.3);
	sig = sig * mod * amp;
	Out.ar(out, sig ! 2);
}).add;

// Shattered glass (for cutting climax)
SynthDef(\shatter, {
	arg out=0, amp=0.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.3), doneAction: 2);
	sig = WhiteNoise.ar();
	sig = Resonz.ar(sig, Array.fill(12, { exprand(2000, 12000) }), 0.001).sum;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Sostenuto strings (for emotional moments)
SynthDef(\strings, {
	arg out=0, freq=440, amp=0.25, gate=1, vibrato=5;
	var sig, env, vib;
	env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);
	vib = SinOsc.kr(vibrato).range(0.98, 1.02);
	sig = Mix([
		Saw.ar(freq * vib),
		Saw.ar(freq * 1.01 * vib),
		Saw.ar(freq * 0.99 * vib)
	]);
	sig = LPF.ar(sig, 3000);
	sig = sig * env * amp * 0.33;
	Out.ar(out, sig ! 2);
}).add;

// ===== ALTERNATIVE PATTERN IDEAS =====

// J-Pop chord progression
~cutPiece.patterns.jPopChords = Pbind(
	\instrument, \toyPiano,
	\scale, ~cutPiece.jPop,
	\degree, Pseq([
		[0, 2, 4],    // I
		[4, 6, 8],    // V  (in pentatonic context)
		[-2, 0, 2],   // IV
		[2, 4, 6]     // vi
	], inf),
	\dur, 4,
	\amp, 0.25,
	\cutoff, 3000,
	\out, ~cutPiece.reverbBus
);

// Pointillistic texture (Webern-like, for fragmentation)
~cutPiece.patterns.pointillism = Pbind(
	\instrument, \musicBox,
	\scale, ~cutPiece.jPop,
	\degree, Pwhite(0, 14),
	\octave, Pwrand([3, 4, 5, 6], [0.1, 0.3, 0.4, 0.2], inf),
	\dur, Pwhite(0.1, 1.5),
	\amp, Pwhite(0.1, 0.3),
	\out, ~cutPiece.reverbBus
);

// Mechanical rhythm (for ritualistic sections)
~cutPiece.patterns.mechanical = Pbind(
	\instrument, \cuttingSound,
	\dur, Pseq([1, 1, 0.5, 1.5], inf),
	\amp, Pwhite(0.2, 0.4),
	\out, ~cutPiece.masterBus
);

// ===== PERFORMANCE MACROS =====

// Gradually build tension (Section 1 → 2 transition)
~cutPiece.macro = ~cutPiece.macro ? ();

~cutPiece.macro.buildTension = {
	fork {
		var steps = 20;
		var waitTime = 0.5;
		
		"Building tension...".postln;
		
		steps.do({ |i|
			var progress = i / steps;
			
			// Increase glitch
			~cutPiece.gui.s1Glitch.value = progress * 80;
			
			// Lower filter
			~cutPiece.gui.s1Filter.value = 2000 - (progress * 1500);
			
			// Slow down melody
			~cutPiece.gui.s1Speed.value = 2 + (progress * 2);
			
			waitTime.wait;
		});
		
		"Tension built - ready for Section 2!".postln;
	};
};

// Sudden silence (dramatic pause)
~cutPiece.macro.silence = {
	~cutPiece.synths.master.set(\amp, 0);
	"SILENCE".postln;
};

~cutPiece.macro.restoreVolume = {
	~cutPiece.synths.master.set(\amp, (-12).dbamp);
	"Volume restored".postln;
};

// Climax sequence (for cutting climax moments)
~cutPiece.macro.climax = {
	fork {
		"CLIMAX SEQUENCE".postln;
		
		// Rapid cuts
		10.do({
			Synth(\cuttingSound, [\out, ~cutPiece.masterBus, \amp, 0.7]);
			0.2.wait;
		});
		
		0.5.wait;
		
		// Shatter
		Synth(\shatter, [\out, ~cutPiece.masterBus, \amp, 0.6]);
		
		1.wait;
		
		// Deep silence
		~cutPiece.macro.silence.();
		
		2.wait;
		
		// Restore with drone
		~cutPiece.macro.restoreVolume.();
		Synth(\darkDrone, [
			\out, ~cutPiece.reverbBus,
			\freq, 55,
			\amp, 0.3
		], ~cutPiece.groups.section3);
	};
};

// Washing ritual sequence
~cutPiece.macro.pilateWashing = {
	fork {
		"Pilate Washing Sequence".postln;
		
		// Bell tolls
		3.do({
			Synth(\bell, [
				\freq, 130.81,  // C3
				\amp, 0.5,
				\decay, 4,
				\out, ~cutPiece.reverbBus
			]);
			2.5.wait;
		});
		
		1.wait;
		
		// Water sounds
		~cutPiece.triggerWash.();
		
		3.wait;
		
		// Choir entrance
		[164.81, 196, 261.63, 329.63].do({ |freq|
			Synth(\choirVoice, [
				\freq, freq,
				\amp, 0.35,
				\out, ~cutPiece.reverbBus
			]);
		});
	};
};

// ===== LIVE CODING SNIPPETS =====

/*
// During performance, you can execute these directly:

// Add vinyl crackle to Section 1
~cutPiece.vinyl = Synth(\vinylCrackle, [\out, ~cutPiece.reverbBus, \amp, 0.1], ~cutPiece.groups.section1);

// Stop vinyl
~cutPiece.vinyl.free;

// Start whisper texture
~cutPiece.whisper = Synth(\whisper, [\out, ~cutPiece.reverbBus, \amp, 0.15, \rate, 0.05], ~cutPiece.groups.section2);

// Change drone pitch in Section 3
~cutPiece.state.players.drone.set(\freq, 80);

// Layer multiple drones
~cutPiece.drone2 = Synth(\darkDrone, [\freq, 98, \amp, 0.3, \out, ~cutPiece.reverbBus], ~cutPiece.groups.section3);

// Trigger bell for ritual moment
Synth(\bell, [\freq, 196, \amp, 0.6, \decay, 5, \out, ~cutPiece.reverbBus]);

// Start J-Pop chord progression
~cutPiece.chordPlayer = ~cutPiece.patterns.jPopChords.play;

// Stop chord progression
~cutPiece.chordPlayer.stop;

// Emergency fade to silence
~cutPiece.synths.master.set(\amp, 0);

// Restore
~cutPiece.synths.master.set(\amp, 0.5);

// Add strings for emotional moment
~cutPiece.strings = Synth(\strings, [\freq, 220, \amp, 0.3, \vibrato, 6, \out, ~cutPiece.reverbBus]);

// Stop strings gracefully
~cutPiece.strings.set(\gate, 0);

// Create random cutting sounds
fork { 20.do({ Synth(\cuttingSound, [\out, ~cutPiece.masterBus]); rrand(0.1, 0.5).wait; }); };

// Shatter moment
Synth(\shatter, [\out, ~cutPiece.masterBus, \amp, 0.7]);

// Start pointillistic texture
~cutPiece.points = ~cutPiece.patterns.pointillism.play;

// Stop pointillism
~cutPiece.points.stop;
*/

// ===== HYBRID SECTION IDEAS =====

// Transition from Section 1 to 2 (crossfade approach)
~cutPiece.transitionTo2 = {
	fork {
		"Transitioning to Section 2...".postln;
		
		// Start Section 2 elements quietly
		~cutPiece.state.players.pulse = Synth(\heartPulse, [
			\out, ~cutPiece.masterBus,
			\freq, 60,
			\amp, 0.05
		], ~cutPiece.groups.section2);
		
		2.wait;
		
		// Fade in pulse, fade out melody
		~cutPiece.state.players.pulse.set(\amp, 0.35);
		~cutPiece.state.players.melody.stop;
		
		3.wait;
		
		// Stop Section 1, continue Section 2
		~cutPiece.state.players.arp.stop;
		~cutPiece.state.players.glitch.free;
		
		~cutPiece.state.players.breathing = Synth(\breathing, [
			\out, ~cutPiece.reverbBus,
			\amp, 0.25
		], ~cutPiece.groups.section2);
		
		~cutPiece.state.players.texture = ~cutPiece.patterns.section2Texture.play;
		
		~cutPiece.state.currentSection = 2;
		"Section 2 active".postln;
	};
};

// Gradual dissolution (Section 2 → 3)
~cutPiece.transitionTo3 = {
	fork {
		"Dissolving into Section 3...".postln;
		
		// Start drones under Section 2
		~cutPiece.state.players.drone = Synth(\darkDrone, [
			\out, ~cutPiece.reverbBus,
			\freq, 65,
			\amp, 0.05
		], ~cutPiece.groups.section3);
		
		4.wait;
		
		// Increase reverb
		~cutPiece.synths.reverb.set(\mix, 0.75, \room, 0.9);
		
		// Fade out Section 2 elements
		~cutPiece.state.players.pulse.set(\amp, 0.1);
		~cutPiece.state.players.breathing.set(\amp, 0.05);
		~cutPiece.state.players.texture.stop;
		
		3.wait;
		
		// Increase drone
		~cutPiece.state.players.drone.set(\amp, 0.4);
		
		// Add choir
		~cutPiece.state.players.choir1 = Synth(\choirVoice, [
			\freq, 164.81,
			\amp, 0.25,
			\out, ~cutPiece.reverbBus
		], ~cutPiece.groups.section3);
		
		2.wait;
		
		// Stop Section 2 completely
		~cutPiece.state.players.pulse.free;
		~cutPiece.state.players.breathing.free;
		
		// Complete Section 3 activation
		~cutPiece.activateSection.(3);
	};
};

"Advanced performance tools loaded!".postln;
"Try: ~cutPiece.macro.buildTension.()".postln;
"Try: ~cutPiece.macro.climax.()".postln;
"Try: ~cutPiece.macro.pilateWashing.()".postln;
