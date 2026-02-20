Produced in dialog with Chat-gpt

(
{
    var phi = (1 + 5.sqrt) / 2, dt = 1;

    [\kick, \snare, \hat, \chords, \bass, \arp, \lead] do: { |defn|
        dt = dt * phi;
        dt.wait;          // beats (because we fork on a TempoClock)
        Pdef(defn).stop;
    };
}.fork(TempoClock.default);
)
