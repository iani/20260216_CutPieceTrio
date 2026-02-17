/*
========================================
CUT PIECE - Sound Performance System
For Yoshiya Yoshimitsu's Object Theatre Performance
Based on Yoko Ono's Cut Piece

Three sections for live performance:
1. Introduction (Haruto introduction, playful/anticipatory)
2. Interaction (Flirtation, cutting, human-object boundary)
3. Dissolution (Passion play, ritual, fragmentation)

SETUP INSTRUCTIONS:
1. Boot the server first
2. Run this entire file (Cmd/Ctrl+Enter on whole document)
3. Use the GUI sliders and buttons during performance
4. See performance notes at bottom

========================================
*/

s.boot;

(
// Wait for server to boot, then initialize
s.waitForBoot({
	
	~cutPiece = ();  // Main namespace
	
	// ===== AUDIO BUSSES =====
	~cutPiece.masterBus = Bus.audio(s, 2);
	~cutPiece.reverbBus = Bus.audio(s, 2);
	~cutPiece.delayBus = Bus.audio(s, 2);
	
	// ===== BUFFERS FOR SAMPLES =====
	// Generate noise buffers for texture
	~cutPiece.noiseBuf = Buffer.alloc(s, s.sampleRate * 2, 1);
	~cutPiece.noiseBuf.loadCollection(
		Array.fill(s.sampleRate * 2, { 1.0.rand2 })
	);
	
	// ===== SYNTHDEF DEFINITIONS =====
	
	// SECTION 1: Toy Piano / Music Box (J-Pop aesthetic)
	SynthDef(\toyPiano, {
		arg out=0, freq=440, amp=0.3, gate=1, cutoff=2000, rq=0.5;
		var sig, env;
		env = EnvGen.kr(Env.adsr(0.01, 0.2, 0.3, 0.8), gate, doneAction: 2);
		sig = SinOsc.ar(freq) * 0.7;
		sig = sig + SinOsc.ar(freq * 2.01) * 0.2;  // Slight detuning
		sig = sig + SinOsc.ar(freq * 4.02) * 0.1;
		sig = RLPF.ar(sig, cutoff, rq);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\musicBox, {
		arg out=0, freq=440, amp=0.25, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.perc(0.005, 0.4), gate, doneAction: 2);
		sig = Pulse.ar(freq, 0.3) + SinOsc.ar(freq * 2);
		sig = BPF.ar(sig, freq * 4, 0.1);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\glitchNoise, {
		arg out=0, amp=0.1, rate=1, cutoff=1000;
		var sig;
		sig = Dust.ar(rate * [30, 35]);
		sig = sig * WhiteNoise.ar(0.3);
		sig = BPF.ar(sig, cutoff, 0.3);
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;
	
	// SECTION 2: Pulse / Breathing / Cutting
	SynthDef(\heartPulse, {
		arg out=0, freq=60, amp=0.4, gate=1;
		var sig, env, trig;
		trig = Impulse.kr(freq/60);
		env = EnvGen.kr(Env.perc(0.001, 0.3), trig);
		sig = SinOsc.ar(80 + (env * 200));
		sig = sig + LFTri.ar(40);
		sig = sig * env * amp;
		sig = Pan2.ar(sig, LFNoise1.kr(0.3));
		Out.ar(out, sig);
	}).add;
	
	SynthDef(\breathing, {
		arg out=0, amp=0.3, rate=0.15;
		var sig, breathEnv;
		breathEnv = LFTri.kr(rate).range(0, 1);
		sig = PinkNoise.ar(0.3);
		sig = BPF.ar(sig, breathEnv.linexp(0, 1, 300, 1200), 0.5);
		sig = sig * breathEnv * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\fmSynth, {
		arg out=0, freq=440, amp=0.3, modRatio=3, modIndex=5, gate=1;
		var sig, env, mod;
		env = EnvGen.kr(Env.adsr(0.1, 0.3, 0.5, 1.2), gate, doneAction: 2);
		mod = SinOsc.ar(freq * modRatio) * modIndex * freq;
		sig = SinOsc.ar(freq + mod);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\cuttingSound, {
		arg out=0, amp=0.5;
		var sig, env;
		env = EnvGen.kr(Env.perc(0.001, 0.1), doneAction: 2);
		sig = WhiteNoise.ar();
		sig = HPF.ar(sig, 3000);
		sig = sig * env * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	// SECTION 3: Drone / Choir / Ritual
	SynthDef(\darkDrone, {
		arg out=0, freq=65, amp=0.4, gate=1;
		var sig, env;
		env = EnvGen.kr(Env.asr(2, 1, 4), gate, doneAction: 2);
		sig = Mix([
			Saw.ar(freq),
			Saw.ar(freq * 1.01),
			Saw.ar(freq * 0.99),
			Pulse.ar(freq * 0.5, 0.3)
		]);
		sig = LPF.ar(sig, 400);
		sig = sig * env * amp * 0.25;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\choirVoice, {
		arg out=0, freq=440, amp=0.3, gate=1, spread=0.01;
		var sig, env;
		env = EnvGen.kr(Env.asr(1.5, 0.8, 3), gate, doneAction: 2);
		sig = Mix([
			SinOsc.ar(freq),
			SinOsc.ar(freq * (1 + spread)),
			SinOsc.ar(freq * (1 - spread)),
			SinOsc.ar(freq * 2) * 0.1
		]);
		sig = sig * env * amp * 0.33;
		Out.ar(out, sig ! 2);
	}).add;
	
	SynthDef(\fragmentNoise, {
		arg out=0, amp=0.2, density=5;
		var sig, trig;
		trig = Dust.ar(density);
		sig = BrownNoise.ar(0.5) * Decay.ar(trig, 0.3);
		sig = CombC.ar(sig, 0.2, LFNoise1.kr(0.3).range(0.02, 0.15), 2);
		sig = sig * amp;
		Out.ar(out, sig ! 2);
	}).add;
	
	// EFFECTS
	SynthDef(\reverb, {
		arg in=0, out=0, mix=0.6, room=3;
		var sig;
		sig = In.ar(in, 2);
		sig = FreeVerb.ar(sig, mix, room.clip(0, 1), 0.5);
		Out.ar(out, sig);
	}).add;
	
	SynthDef(\masterOut, {
		arg in=0, out=0, amp=0.7;
		var sig;
		sig = In.ar(in, 2);
		sig = Limiter.ar(sig, 0.95);
		Out.ar(out, sig * amp);
	}).add;
	
	// ===== SCALES =====
	// Japanese pentatonic (J-Pop flavor)
	~cutPiece.jPop = Scale.new(
		#[0, 2, 4, 7, 9],  // Pentatonic
		12,
		Tuning.et12
	);
	
	// ===== PATTERNS & SEQUENCES =====
	~cutPiece.patterns = ();
	
	// Wait for SynthDefs to load
	s.sync;
	
	// ===== SECTION 1 PATTERNS =====
	~cutPiece.patterns.section1Melody = Pbind(
		\instrument, \toyPiano,
		\scale, ~cutPiece.jPop,
		\degree, Pwhite(0, 9),
		\octave, Pwrand([4, 5], [0.7, 0.3], inf),
		\dur, Pwrand([0.5, 1, 2], [0.5, 0.3, 0.2], inf),
		\amp, Pwhite(0.2, 0.35),
		\cutoff, Pfunc({ ~cutPiece.gUi.s1FilterVal ? 2000 }),
		\out, ~cutPiece.reverbBus
	);
	
	~cutPiece.patterns.section1Arp = Pbind(
		\instrument, \musicBox,
		\scale, ~cutPiece.jPop,
		\degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf),
		\octave, 5,
		\dur, 0.25,
		\amp, Pfunc({ ~cutPiece.gUi.s1ArpVal ? 50 }) / 200,
		\out, ~cutPiece.reverbBus
	);
	
	// ===== SECTION 2 PATTERNS =====
	~cutPiece.patterns.section2Texture = Pbind(
		\instrument, \fmSynth,
		\freq, Pwhite(200, 800),
		\modRatio, Pfunc({ ~cutPiece.gUi.s2HarmVal ? 60 }) / 20,
		\modIndex, Pwhite(3, 8),
		\dur, Pwrand([2, 3, 4], [0.5, 0.3, 0.2], inf),
		\sustain, 2,
		\amp, Pfunc({ ~cutPiece.gUi.s2BreathVal ? 40 }) / 150,
		\out, ~cutPiece.reverbBus
	);
	
	// ===== SYNTH GROUPS =====
	~cutPiece.groups = ();
	~cutPiece.groups.section1 = Group.new;
	~cutPiece.groups.section2 = Group.new;
	~cutPiece.groups.section3 = Group.new;
	~cutPiece.groups.fx = Group.after(~cutPiece.groups.section3);
	
	// Start effects
	~cutPiece.synths = ();
	~cutPiece.synths.reverb = Synth(\reverb, [
		\in, ~cutPiece.reverbBus,
		\out, ~cutPiece.masterBus,
		\mix, 0.4,
		\room, 0.7
	], ~cutPiece.groups.fx);
	
	~cutPiece.synths.master = Synth(\masterOut, [
		\in, ~cutPiece.masterBus,
		\out, 0,
		\amp, 0.7
	], ~cutPiece.groups.fx, \addAfter);
	
	// ===== STATE TRACKING =====
	~cutPiece.state = ();
	~cutPiece.state.currentSection = nil;
	~cutPiece.state.players = ();
	
	// ===== GUI =====
	~cutPiece.gUi = ();
	~cutPiece.gUi.wIndow = Window("✂️ CUT PIECE Performance Control", Rect(100, 100, 900, 700))
		.front
		.alwaysOnTop_(true);
	
	~cutPiece.gUi.layout = VLayout();
	~cutPiece.gUi.wIndow.layout = ~cutPiece.gUi.layout;
	
	// Title
	~cutPiece.gUi.layout.add(
		StaticText().string_("CUT PIECE - Sound Performance System")
			.font_(Font("Arial", 24, true))
			.align_(\center)
	);
	
	~cutPiece.gUi.layout.add(
		StaticText().string_("Live sound for Yoshiya Yoshimitsu's Object Theatre Performance")
			.font_(Font("Arial", 12))
			.align_(\center)
	);
	
	~cutPiece.gUi.layout.add(nil); // Spacer
	
	// Master controls
	~cutPiece.gUi.masterBox = VLayout();
	~cutPiece.gUi.layout.add(~cutPiece.gUi.masterBox);
	
	~cutPiece.gUi.masterBox.add(
		StaticText().string_("🎭 MASTER CONTROLS").font_(Font("Arial", 16, true))
	);
	
	~cutPiece.gUi.masterVol = EZSlider(
		label: "Master Volume",
		controlSpec: ControlSpec(-40, 0, \lin, 1, -12),
		action: { |ez|
			~cutPiece.synths.master.set(\amp, ez.value.dbamp);
		},
		initVal: -12,
		labelWidth: 120
	);
	~cutPiece.gUi.masterBox.add(~cutPiece.gUi.masterVol);
	
	// Section buttons
	~cutPiece.gUi.sectionButtons = HLayout();
	~cutPiece.gUi.layout.add(~cutPiece.gUi.sectionButtons);
	
	~cutPiece.gUi.sec1Btn = Button()
		.states_([["SECTION 1: Introduction", Color.white, Color.blue]])
		.action_({ ~cutPiece.activateSection.(1); });
	
	~cutPiece.gUi.sec2Btn = Button()
		.states_([["SECTION 2: Interaction", Color.white, Color.magenta]])
		.action_({ ~cutPiece.activateSection.(2); });
	
	~cutPiece.gUi.sec3Btn = Button()
		.states_([["SECTION 3: Dissolution", Color.white, Color.red(0.5)]])
		.action_({ ~cutPiece.activateSection.(3); });
	
	~cutPiece.gUi.stopBtn = Button()
		.states_([["⏹ STOP ALL", Color.white, Color.red]])
		.action_({ ~cutPiece.stopAll.(); });
	
	~cutPiece.gUi.sectionButtons.add(~cutPiece.gUi.sec1Btn);
	~cutPiece.gUi.sectionButtons.add(~cutPiece.gUi.sec2Btn);
	~cutPiece.gUi.sectionButtons.add(~cutPiece.gUi.sec3Btn);
	~cutPiece.gUi.sectionButtons.add(~cutPiece.gUi.stopBtn);
	
	// ===== SECTION 1 CONTROLS =====
	~cutPiece.gUi.s1Box = VLayout();
	~cutPiece.gUi.layout.add(~cutPiece.gUi.s1Box);
	
	~cutPiece.gUi.s1Box.add(
		StaticText().string_("🎎 SECTION 1: Introduction (Playful/Anticipatory)")
			.font_(Font("Arial", 14, true))
			.background_(Color.blue(0.3, 0.3))
	);
	
	~cutPiece.gUi.s1Speed = EZSlider(
		label: "Melody Speed",
		controlSpec: ControlSpec(0.5, 4, \lin, 0.1, 2),
		labelWidth: 120
	);
	~cutPiece.gUi.s1Box.add(~cutPiece.gUi.s1Speed);
	
	~cutPiece.gUi.s1Arp = EZSlider(
		label: "Arpeggio Amount",
		controlSpec: ControlSpec(0, 100, \lin, 1, 50),
		action: { |ez| ~cutPiece.gUi.s1ArpVal = ez.value; },
		labelWidth: 120
	);
	~cutPiece.gUi.s1Box.add(~cutPiece.gUi.s1Arp);
	
	~cutPiece.gUi.s1Filter = EZSlider(
		label: "Filter Cutoff",
		controlSpec: ControlSpec(200, 5000, \exp, 10, 2000),
		action: { |ez| ~cutPiece.gUi.s1FilterVal = ez.value; },
		labelWidth: 120
	);
	~cutPiece.gUi.s1Box.add(~cutPiece.gUi.s1Filter);
	
	~cutPiece.gUi.s1Glitch = EZSlider(
		label: "Glitch/Noise",
		controlSpec: ControlSpec(0, 100, \lin, 1, 20),
		labelWidth: 120
	);
	~cutPiece.gUi.s1Box.add(~cutPiece.gUi.s1Glitch);
	
	~cutPiece.gUi.s1Sparkle = Button()
		.states_([["✨ TRIGGER SPARKLE", Color.white, Color.cyan]])
		.action_({ ~cutPiece.triggerSparkle.(); });
	~cutPiece.gUi.s1Box.add(~cutPiece.gUi.s1Sparkle);
	
	// ===== SECTION 2 CONTROLS =====
	~cutPiece.gUi.s2Box = VLayout();
	~cutPiece.gUi.layout.add(~cutPiece.gUi.s2Box);
	
	~cutPiece.gUi.s2Box.add(
		StaticText().string_("💕 SECTION 2: Interaction (Flirtation/Cutting)")
			.font_(Font("Arial", 14, true))
			.background_(Color.magenta(0.3, 0.3))
	);
	
	~cutPiece.gUi.s2Pulse = EZSlider(
		label: "Pulse BPM",
		controlSpec: ControlSpec(40, 180, \lin, 1, 72),
		labelWidth: 120
	);
	~cutPiece.gUi.s2Box.add(~cutPiece.gUi.s2Pulse);
	
	~cutPiece.gUi.s2Breath = EZSlider(
		label: "Breathing Texture",
		controlSpec: ControlSpec(0, 100, \lin, 1, 40),
		action: { |ez| ~cutPiece.gUi.s2BreathVal = ez.value; },
		labelWidth: 120
	);
	~cutPiece.gUi.s2Box.add(~cutPiece.gUi.s2Breath);
	
	~cutPiece.gUi.s2Harm = EZSlider(
		label: "Synth Harmonics",
		controlSpec: ControlSpec(0, 100, \lin, 1, 60),
		action: { |ez| ~cutPiece.gUi.s2HarmVal = ez.value; },
		labelWidth: 120
	);
	~cutPiece.gUi.s2Box.add(~cutPiece.gUi.s2Harm);
	
	~cutPiece.gUi.s2Buttons = HLayout();
	
	~cutPiece.gUi.s2Cut = Button()
		.states_([["✂️ CUTTING SOUND", Color.white, Color.red(0.7)]])
		.action_({ Synth(\cuttingSound, [\out, ~cutPiece.masterBus, \amp, 0.6]); });
	
	~cutPiece.gUi.s2Flirt = Button()
		.states_([["💋 FLIRT GESTURE", Color.white, Color.magenta]])
		.action_({ ~cutPiece.triggerFlirt.(); });
	
	~cutPiece.gUi.s2Buttons.add(~cutPiece.gUi.s2Cut);
	~cutPiece.gUi.s2Buttons.add(~cutPiece.gUi.s2Flirt);
	~cutPiece.gUi.s2Box.add(~cutPiece.gUi.s2Buttons);
	
	// ===== SECTION 3 CONTROLS =====
	~cutPiece.gUi.s3Box = VLayout();
	~cutPiece.gUi.layout.add(~cutPiece.gUi.s3Box);
	
	~cutPiece.gUi.s3Box.add(
		StaticText().string_("⛪ SECTION 3: Dissolution (Passion Play/Ritual)")
			.font_(Font("Arial", 14, true))
			.background_(Color.red(0.3, 0.3))
	);
	
	~cutPiece.gUi.s3Drone = EZSlider(
		label: "Drone Darkness",
		controlSpec: ControlSpec(0, 100, \lin, 1, 50),
		labelWidth: 120
	);
	~cutPiece.gUi.s3Box.add(~cutPiece.gUi.s3Drone);
	
	~cutPiece.gUi.s3Choir = EZSlider(
		label: "Choir/Vocal",
		controlSpec: ControlSpec(0, 100, \lin, 1, 30),
		labelWidth: 120
	);
	~cutPiece.gUi.s3Box.add(~cutPiece.gUi.s3Choir);
	
	~cutPiece.gUi.s3Frag = EZSlider(
		label: "Fragmentation",
		controlSpec: ControlSpec(0, 100, \lin, 1, 40),
		labelWidth: 120
	);
	~cutPiece.gUi.s3Box.add(~cutPiece.gUi.s3Frag);
	
	~cutPiece.gUi.s3Reverb = EZSlider(
		label: "Reverb Space",
		controlSpec: ControlSpec(0.5, 10, \exp, 0.1, 3),
		action: { |ez|
			~cutPiece.synths.reverb.set(\room, ez.value.linlin(0.5, 10, 0.5, 0.95));
		},
		labelWidth: 120
	);
	~cutPiece.gUi.s3Box.add(~cutPiece.gUi.s3Reverb);
	
	~cutPiece.gUi.s3Buttons = HLayout();
	
	~cutPiece.gUi.s3Ritual = Button()
		.states_([["🕊️ RITUAL MOMENT", Color.white, Color.new(0.4, 0.2, 0.5)]])
		.action_({ ~cutPiece.triggerRitual.(); });
	
	~cutPiece.gUi.s3Wash = Button()
		.states_([["🌊 WASHING (Pilate)", Color.white, Color.cyan(0.6)]])
		.action_({ ~cutPiece.triggerWash.(); });
	
	~cutPiece.gUi.s3Buttons.add(~cutPiece.gUi.s3Ritual);
	~cutPiece.gUi.s3Buttons.add(~cutPiece.gUi.s3Wash);
	~cutPiece.gUi.s3Box.add(~cutPiece.gUi.s3Buttons);
	
	// Initialize GUI values
	~cutPiece.gUi.s1ArpVal = 50;
	~cutPiece.gUi.s1FilterVal = 2000;
	~cutPiece.gUi.s2BreathVal = 40;
	~cutPiece.gUi.s2HarmVal = 60;
	
	// ===== PERFORMANCE FUNCTIONS =====
	
	~cutPiece.activateSection = { |section|
		~cutPiece.stopAll.();
		~cutPiece.state.currentSection = section;
		
		switch(section,
			1, {
				// Section 1: Introduction
				~cutPiece.state.players.melody = ~cutPiece.patterns.section1Melody.play;
				~cutPiece.state.players.arp = ~cutPiece.patterns.section1Arp.play;
				~cutPiece.state.players.glitch = Synth(\glitchNoise, [
					\out, ~cutPiece.reverbBus,
					\amp, 0.1,
					\rate, 1
				], ~cutPiece.groups.section1);
				
				"✂️ SECTION 1 ACTIVE: Introduction".postln;
			},
			2, {
				// Section 2: Interaction
				~cutPiece.state.players.pulse = Synth(\heartPulse, [
					\out, ~cutPiece.masterBus,
					\freq, ~cutPiece.gUi.s2Pulse.value,
					\amp, 0.35
				], ~cutPiece.groups.section2);
				
				~cutPiece.state.players.breathing = Synth(\breathing, [
					\out, ~cutPiece.reverbBus,
					\amp, 0.25,
					\rate, 0.15
				], ~cutPiece.groups.section2);
				
				~cutPiece.state.players.texture = ~cutPiece.patterns.section2Texture.play;
				
				"✂️ SECTION 2 ACTIVE: Interaction".postln;
			},
			3, {
				// Section 3: Dissolution
				~cutPiece.state.players.drone = Synth(\darkDrone, [
					\out, ~cutPiece.reverbBus,
					\freq, 65,
					\amp, ~cutPiece.gUi.s3Drone.value.linlin(0, 100, 0.1, 0.5)
				], ~cutPiece.groups.section3);
				
				~cutPiece.state.players.choir1 = Synth(\choirVoice, [
					\out, ~cutPiece.reverbBus,
					\freq, 164.81,  // E3
					\amp, ~cutPiece.gUi.s3Choir.value.linlin(0, 100, 0, 0.3)
				], ~cutPiece.groups.section3);
				
				~cutPiece.state.players.choir2 = Synth(\choirVoice, [
					\out, ~cutPiece.reverbBus,
					\freq, 196,  // G3
					\amp, ~cutPiece.gUi.s3Choir.value.linlin(0, 100, 0, 0.3)
				], ~cutPiece.groups.section3);
				
				~cutPiece.state.players.choir3 = Synth(\choirVoice, [
					\out, ~cutPiece.reverbBus,
					\freq, 261.63,  // C4
					\amp, ~cutPiece.gUi.s3Choir.value.linlin(0, 100, 0, 0.3)
				], ~cutPiece.groups.section3);
				
				~cutPiece.state.players.fragment = Synth(\fragmentNoise, [
					\out, ~cutPiece.reverbBus,
					\amp, ~cutPiece.gUi.s3Frag.value.linlin(0, 100, 0, 0.25),
					\density, 5
				], ~cutPiece.groups.section3);
				
				"✂️ SECTION 3 ACTIVE: Dissolution".postln;
			}
		);
	};
	
	~cutPiece.stopAll = {
		~cutPiece.state.players.do({ |player|
			if(player.isPlaying, { player.stop });
			if(player.isRunning, { player.free });
		});
		~cutPiece.state.players = ();
		~cutPiece.groups.section1.freeAll;
		~cutPiece.groups.section2.freeAll;
		~cutPiece.groups.section3.freeAll;
		
		"⏹ ALL STOPPED".postln;
	};
	
	// ===== TRIGGER EVENTS =====
	
	~cutPiece.triggerSparkle = {
		// Ascending sparkle cascade
		fork {
			8.do({ |i|
				Synth(\toyPiano, [
					\freq, ~cutPiece.jPop.degreeToFreq(7 - i, 60.midicps, 5),
					\amp, 0.4,
					\cutoff, 5000,
					\out, ~cutPiece.reverbBus
				]);
				0.05.wait;
			});
		};
	};
	
	~cutPiece.triggerFlirt = {
		// Playful ascending gesture
		fork {
			[0, 2, 4, 7].do({ |degree|
				Synth(\fmSynth, [
					\freq, ~cutPiece.jPop.degreeToFreq(degree, 60.midicps, 4),
					\amp, 0.3,
					\modRatio, 2,
					\modIndex, 8,
					\out, ~cutPiece.reverbBus
				]);
				0.1.wait;
			});
		};
	};
	
	~cutPiece.triggerRitual = {
		// Deep bell-like tones
		[130.81, 196, 261.63].do({ |freq|
			Synth(\choirVoice, [
				\freq, freq,
				\amp, 0.4,
				\out, ~cutPiece.reverbBus
			]);
		});
	};
	
	~cutPiece.triggerWash = {
		// Water-like noise wash
		var washNoise = Synth(\fragmentNoise, [
			\out, ~cutPiece.reverbBus,
			\amp, 0.4,
			\density, 20
		]);
		
		fork {
			2.wait;
			washNoise.release(1.5);
		};
	};
	
	// ===== CLEANUP ON WINDOW CLOSE =====
	~cutPiece.gUi.wIndow.onClose = {
		~cutPiece.stopAll.();
		~cutPiece.groups.fx.freeAll;
		~cutPiece.masterBus.free;
		~cutPiece.reverbBus.free;
		~cutPiece.delayBus.free;
		~cutPiece.noiseBuf.free;
		"✂️ Cut Piece Performance System Closed".postln;
	};
	
	"✂️ CUT PIECE Performance System Ready!".postln;
	"Use the GUI to control the performance.".postln;
	"Select sections 1, 2, or 3 to begin.".postln;
});
)

/*
========================================
PERFORMANCE NOTES:
========================================

SECTION 1 - Introduction (Haruto enters)
- Start with playful toy piano melodies
- Adjust Filter Cutoff to brighten/darken
- Increase Glitch for tension
- Use SPARKLE trigger for magical moments

SECTION 2 - Interaction (Flirtation/Cutting)
- Pulse creates heartbeat rhythm
- Breathing adds intimacy
- Adjust Synth Harmonics for complexity
- CUTTING SOUND for scissor moments
- FLIRT GESTURE for tender moments

SECTION 3 - Dissolution (Passion Play)
- Drone creates dark foundation
- Choir adds ritual quality
- Fragmentation for deconstruction
- RITUAL MOMENT for solemn gestures
- WASHING for Pilate reference

LIVE CODING TIPS:
- Access synths: ~cutPiece.state.players
- Modify on the fly: ~cutPiece.state.players.drone.set(\freq, 80)
- Create new patterns and add to ~cutPiece.patterns
- All values are live-modifiable through GUI

KEYBOARD SHORTCUTS:
- Cmd/Ctrl+Period: Stop all sound (emergency!)
- Cmd/Ctrl+Enter: Execute highlighted code

Have a powerful performance!
========================================
*/
