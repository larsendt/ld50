extends Node

var fadeout_duration = 5.0
var current_periodic_effect = null
var rng = RandomNumberGenerator.new()
var periodic_min = 15
var periodic_max = 60

onready var ambient_sounds = {
    "eerie_thunder": $EerieThunderAmbience,
    "wind": $WindAmbience,
    "earthquake": $EarthquakeAmbience,
}

onready var periodic_effects = {
    "near_thunder": [$NearThunderPlayer, false],
    "lots_of_thunder": [$NearThunderPlayer, false]
}

var special_ambience_volumes = {
    "wind": -10,
    "eerie_thunder": -20,
}

var all_effects = ["eerie_thunder", "wind", "earthquake", "near_thunder", "lots_of_thunder"]

func _ready():
    $PeriodicEffectTimer.connect("timeout", self, "_do_periodic_effect")
    start_music()

func stop_music():
    print("Stopping music")
    $MusicBegin.disconnect("finished", $MusicLoop, "play")
    $MusicBegin.stop()
    $MusicLoop.stop()

func start_music():
    $MusicBegin.connect("finished", $MusicLoop, "play")
    $MusicBegin.play()

func set_ambience(plays):
    print("Set ambience: ", plays)
    for name in all_effects:
        if name in plays:
            play(name)
        else:
            stop(name)

func play(name):
    if name in ambient_sounds && !ambient_sounds[name].playing:
        print("Ambience playing ", name)
        var sound = self.ambient_sounds[name]
        var tween = sound.find_node("Tween")
        sound.play()

        var volume = 0
        if name in special_ambience_volumes:
            volume = special_ambience_volumes[name]

        tween.interpolate_property(sound, "volume_db", -80, volume, fadeout_duration, Tween.TRANS_SINE, Tween.EASE_IN)
        tween.start()
    elif name in periodic_effects:
        self.current_periodic_effect = name
        print("Ambience playing ", name)
        start_periodic_effect_timer()

func stop(name):
    if name in ambient_sounds && ambient_sounds[name].playing:
        print("Ambience stopping ", name)
        var sound = self.ambient_sounds[name]
        var tween = sound.find_node("Tween")

        var volume = 0
        if name in special_ambience_volumes:
            volume = special_ambience_volumes[name]

        tween.interpolate_property(sound, "volume_db", volume, -80, fadeout_duration, Tween.TRANS_SINE, Tween.EASE_IN)
        tween.start()
        yield(tween, "tween_all_completed")
        sound.stop()
    elif name in periodic_effects && periodic_effects[name][1]:
        print("Ambience stopping ", name)
        self.current_periodic_effect = null
        $PeriodicEffectTimer.stop()

func _do_periodic_effect():
    print("Doing periodic effect: ", self.current_periodic_effect)
    self.periodic_effects[self.current_periodic_effect][0].play()
    start_periodic_effect_timer()

func start_periodic_effect_timer():
    if self.current_periodic_effect == "lots_of_thunder":
        var timeout = rng.randf_range(3, 8)
        print("Starting effect ", self.current_periodic_effect, " in ", timeout, " seconds")
        $PeriodicEffectTimer.start(timeout)
    else:
        var timeout = rng.randf_range(periodic_min, periodic_max)
        print("Starting effect ", self.current_periodic_effect, " in ", timeout, " seconds")
        $PeriodicEffectTimer.start(timeout)
