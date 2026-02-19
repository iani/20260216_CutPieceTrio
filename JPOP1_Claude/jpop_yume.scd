// ============================================================
//  "Yume no Kakera" -- A J-Pop Piece in SuperCollider
//  Key of A major, I-V-vi-IV progression, 128 BPM
//  Usage: Boot server first with s.boot, then Cmd+Return to run
// ============================================================

(
s.waitForBoot({

    // ---- Tempo --------------------------------------------------
    var bpm  = 128;
    var beat = 60 / bpm;

	var reverbBus, root, chordIntervals, bassRoots, melody, padPans, numBars; 
    // ---- SynthDefs ----------------------------------------------

    // Bell / glockenspiel lead
    SynthDef(\jpopBell, { |out=0, freq=440, amp=0.3, pan=0, rel=1.0|
        var sig, env;
        env = EnvGen.kr(Env.perc(0.01, rel, 1, -5), doneAction: 2);
        sig = SinOsc.ar(freq)          * 0.6
            + SinOsc.ar(freq * 2.756)  * 0.3
            + SinOsc.ar(freq * 5.404)  * 0.1;
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Lush detuned pad
    SynthDef(\jpopPad, { |out=0, freq=220, amp=0.15, pan=0, gate=1|
        var sig, env;
        env = EnvGen.kr(Env.asr(0.4, 1.0, 0.8), gate, doneAction: 2);
        sig = Mix.ar(Saw.ar(freq * [1.0, 1.003, 0.997, 2.001, 1.997]));
        sig = LPF.ar(sig, freq * 4);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Sub bass
    SynthDef(\jpopBass, { |out=0, freq=55, amp=0.5, rel=0.32|
        var sig, env;
        env = EnvGen.kr(Env.perc(0.02, rel, 1, -4), doneAction: 2);
        sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.25);
        sig = sig * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    // Kick
    SynthDef(\jpopKick, { |out=0, amp=0.85|
        var sig, env, fenv;
        fenv = EnvGen.kr(Env([220, 60, 40], [0.02, 0.08], \exp));
        env  = EnvGen.kr(Env.perc(0.005, 0.35, 1, -4), doneAction: 2);
        sig  = SinOsc.ar(fenv) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    // Snare
    SynthDef(\jpopSnare, { |out=0, amp=0.5|
        var sig, env;
        env = EnvGen.kr(Env.perc(0.004, 0.18, 1, -5), doneAction: 2);
        sig = (SinOsc.ar(200) * 0.4)
            + (BPF.ar(WhiteNoise.ar, 1200, 0.8) * 0.8);
        sig = sig * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    // Hi-hat
    SynthDef(\jpopHat, { |out=0, amp=0.22|
        var sig, env;
        env = EnvGen.kr(Env.perc(0.002, 0.07, 1, -6), doneAction: 2);
        sig = HPF.ar(WhiteNoise.ar, 8000) * env * amp;
        Out.ar(out, sig ! 2);
    }).add;

    // Reverb effect
    SynthDef(\jpopReverb, { |in=0, out=0|
        var sig = In.ar(in, 2);
        sig = FreeVerb2.ar(sig[0], sig[1], mix: 0.45, room: 0.8, damp: 0.5);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // ---- Buses and effects --------------------------------------
    reverbBus = Bus.audio(s, 2);
    Synth(\jpopReverb, [\in, reverbBus, \out, 0]);

    s.sync;

    // ---- Musical data -------------------------------------------
    // A major: root MIDI = 69
    root = 69;

    // Chord intervals from root (semitones), 4-voice voicings
    // I=Amaj  V=Emaj  vi=F#min  IV=Dmaj
    chordIntervals = [
        [0,  4,  7, 12],   // I   Amaj
        [-5, 2,  7, 11],   // V   Emaj
        [-3, 2,  7, 12],   // vi  F#min
        [-7, 2,  5,  9]    // IV  Dmaj
    ];

    // Bass MIDI notes (low register)
    bassRoots = [45, 40, 42, 38];  // A2 E2 F#2 D2

    // Melody: semitones from root, 4 notes per bar over 4 bars
    melody = [
         0,  4,  7,  9,
        12,  9,  7,  4,
         2,  4,  7, 12,
         9,  7,  4,  0
    ];

    // Pan positions for pad voices
    padPans = [-0.5, 0.0, 0.3, -0.2];

    // ---- Sequencer ----------------------------------------------
    numBars = 8;

    Routine({
        var padSynths;

        numBars.do { |barIdx|
            var ci = barIdx % 4;

            // -- Launch pad chord (one synth per voice)
            padSynths = chordIntervals[ci].collect { |interval, i|
                Synth(\jpopPad, [
                    \out,  reverbBus,
                    \freq, (root + interval).midicps,
                    \amp,  0.12,
                    \pan,  padPans[i],
                    \gate, 1
                ]);
            };

            // -- 4 beats per bar
            4.do { |beatIdx|
                var melNote = root + melody[(ci * 4) + beatIdx];

                // Melody bell
                Synth(\jpopBell, [
                    \out,  reverbBus,
                    \freq, melNote.midicps,
                    \amp,  0.28,
                    \pan,  [-0.3, 0.2, -0.1, 0.35][beatIdx],
                    \rel,  0.85
                ]);

                // Bass: root on beat 1, fifth on beat 3
                if ((beatIdx == 0) || (beatIdx == 2)) {
                    var bFreq = bassRoots[ci].midicps;
                    Synth(\jpopBass, [
                        \out,  0,
                        \freq, if(beatIdx == 2, bFreq * 1.5, bFreq),
                        \amp,  0.5
                    ]);
                };

                // Kick on 1 and 3
                if ((beatIdx == 0) || (beatIdx == 2)) {
                    Synth(\jpopKick, [\out, 0]);
                };

                // Snare on 2 and 4
                if ((beatIdx == 1) || (beatIdx == 3)) {
                    Synth(\jpopSnare, [\out, 0]);
                };

                // Eighth-note hi-hats
                Synth(\jpopHat, [\out, 0, \amp, 0.22]);
                (beat * 0.5).wait;
                Synth(\jpopHat, [\out, 0, \amp, 0.13]);
                (beat * 0.5).wait;
            };

            // Release pad at bar end
            padSynths.do(_.set(\gate, 0));
        };

        "Yume no Kakera -- finished playing!".postln;
    }).play;

});
)
