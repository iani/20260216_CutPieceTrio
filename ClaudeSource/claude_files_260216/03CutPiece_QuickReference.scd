/*
========================================
CUT PIECE - Quick Reference Guide
========================================

SETUP (Do this first):
1. Open SuperCollider
2. Boot server: s.boot; (or click "Boot Server")
3. Run CutPiecePerformance.scd (Cmd/Ctrl+Enter on whole file)
4. GUI window will open
5. (Optional) Run CutPiece_Advanced.scd for extra tools

========================================
GUI QUICK REFERENCE
========================================

MASTER CONTROLS:
• Master Volume: Overall output level (-40 to 0 dB)
• SECTION buttons: Switch between three main sections
• STOP ALL: Emergency stop (kills all sound)

SECTION 1: Introduction (Haruto)
Sound: Playful, toy piano, music box, J-Pop cute with tension
Controls:
• Melody Speed: How fast the toy piano plays (0.5-4 seconds)
• Arpeggio Amount: Intensity of music box arpeggios (0-100%)
• Filter Cutoff: Brightness of sound (200-5000 Hz)
• Glitch/Noise: Amount of distortion/unease (0-100%)
Trigger:
• SPARKLE: Ascending cascade of notes (magical moment)

SECTION 2: Interaction (Flirtation/Cutting)
Sound: Pulsing, breathing, FM synthesis, intimate tension
Controls:
• Pulse BPM: Heart-like rhythm speed (40-180 BPM)
• Breathing Texture: Noise/breath amount (0-100%)
• Synth Harmonics: Complexity of FM tones (0-100%)
Triggers:
• CUTTING SOUND: Sharp scissor snip sound
• FLIRT GESTURE: Playful ascending melodic phrase

SECTION 3: Dissolution (Passion Play)
Sound: Dark drones, choir, ritual, fragmentation
Controls:
• Drone Darkness: Low frequency drone intensity (0-100%)
• Choir/Vocal: Sustained vocal-like harmonies (0-100%)
• Fragmentation: Noise/textural breakdown (0-100%)
• Reverb Space: Cathedral-like space size (0.5-10 seconds)
Triggers:
• RITUAL MOMENT: Deep bell-like chord
• WASHING (Pilate): Water-like noise texture

========================================
PERFORMANCE WORKFLOW SUGGESTIONS
========================================

OPENING (Haruto Introduction):
1. Start SECTION 1
2. Keep Filter Cutoff bright (3000-4000 Hz)
3. Low Glitch (10-20%)
4. Use SPARKLE trigger when Haruto appears
5. Gradually increase Glitch as tension builds

BUILDING TO INTERACTION:
1. Slowly lower Filter Cutoff (down to 1000 Hz)
2. Increase Glitch to 60-80%
3. Slow Melody Speed to 3-4 seconds
4. When ready, switch to SECTION 2

FLIRTATION PHASE:
1. Start with moderate Pulse (80-100 BPM)
2. Increase Breathing Texture gradually (20→60%)
3. Adjust Synth Harmonics for complexity
4. Use FLIRT GESTURE for tender moments
5. Use CUTTING SOUND for each scissor action

BUILDING TO CLIMAX:
1. Increase Pulse BPM (120-150)
2. Max out Synth Harmonics (80-100%)
3. Rapid CUTTING SOUND triggers
4. (Advanced users: ~cutPiece.macro.climax.())

DISSOLUTION:
1. Switch to SECTION 3
2. Start with moderate Drone (40-50%)
3. Gradually increase Choir (30→70%)
4. Increase Reverb Space (5-8 seconds)
5. Use RITUAL MOMENT for solemn gestures
6. Use WASHING for Pilate hand-washing reference

ENDING:
1. Increase Fragmentation to 70-90%
2. Slowly decrease Drone and Choir
3. Maximum Reverb Space (10 seconds)
4. Let sounds fade naturally
5. Or use STOP ALL for sudden ending

========================================
LIVE CODING DURING PERFORMANCE
========================================

Access the post window (Cmd/Ctrl+P) to see status messages.
You can type and execute code live during the performance!

USEFUL LIVE COMMANDS:

// See what's playing
~cutPiece.state.players;

// Change a synth parameter directly
~cutPiece.state.players.drone.set(\freq, 80);

// Add vinyl crackle texture
~cutPiece.vinyl = Synth(\vinylCrackle, [\out, ~cutPiece.reverbBus]);

// Stop vinyl
~cutPiece.vinyl.free;

// Emergency fade to silence
~cutPiece.synths.master.set(\amp, 0);

// Restore volume
~cutPiece.synths.master.set(\amp, 0.5);

// Trigger bell
Synth(\bell, [\freq, 196, \amp, 0.6, \out, ~cutPiece.reverbBus]);

// Multiple random cuts
fork { 10.do({ Synth(\cuttingSound, [\out, ~cutPiece.masterBus]); rrand(0.2, 0.5).wait; }); };

========================================
ADVANCED MACROS (if Advanced file loaded)
========================================

// Gradual tension build (automated)
~cutPiece.macro.buildTension.();

// Climax sequence (cuts + shatter + silence + drone)
~cutPiece.macro.climax.();

// Pilate washing sequence (bells + water + choir)
~cutPiece.macro.pilateWashing.();

// Smooth transition Section 1 → 2
~cutPiece.transitionTo2.();

// Smooth transition Section 2 → 3
~cutPiece.transitionTo3.();

// Sudden silence (dramatic pause)
~cutPiece.macro.silence.();

// Restore volume
~cutPiece.macro.restoreVolume.();

========================================
TROUBLESHOOTING
========================================

NO SOUND:
• Check Master Volume slider
• Make sure server is booted (s.boot;)
• Check system audio output
• Try: s.meter; to see if audio is being generated

SECTION NOT STARTING:
• Wait a moment after clicking button
• Check post window for error messages
• Try STOP ALL then restart section

CLICKS/GLITCHES:
• Increase server options before booting:
  s.options.memSize = 8192 * 16;
  s.options.numBuffers = 1024 * 16;
  s.reboot;

EMERGENCY STOP:
• Click STOP ALL button
• Or press: Cmd/Ctrl + Period

PERFORMANCE TOO QUIET/LOUD:
• Adjust Master Volume slider
• Or live code: ~cutPiece.synths.master.set(\amp, 0.6);

========================================
REHEARSAL TIPS
========================================

1. PRACTICE SECTION TRANSITIONS
   - Know when to switch sections
   - Practice smooth vs. abrupt changes

2. MAP DRAMATIC MOMENTS
   - Note where you'll use triggers
   - Plan SPARKLE, CUTTING, RITUAL moments

3. EXPERIMENT WITH PARAMETERS
   - Find your preferred settings
   - Note extreme values for dramatic effect

4. PREPARE BACKUP PLAN
   - Know emergency stop (Cmd+Period)
   - Have simple patterns ready
   - Can always fall back to basic drones

5. COORDINATE WITH PERFORMERS
   - Match sound to stage action
   - Be responsive to timing changes
   - Watch for cues from Yoshiya

6. TEST AUDIO SETUP
   - Check speakers/monitors
   - Test volume levels in venue
   - Have backup audio interface ready

========================================
PERFORMANCE MINDSET
========================================

You are not just triggering sounds - you are:
• Creating atmosphere for ritual
• Supporting the human-object dialogue
• Bridging the playful and the profound
• Holding space for the audience's experience

Trust your instincts. Respond to the room.
The code is your instrument - play it live!

Good luck with the performance! ✂️

========================================
*/
