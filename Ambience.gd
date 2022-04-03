extends Node

var fadeout_duration = 5.0
var current_periodic_effect_player = null
var rng = RandomNumberGenerator.new()
var periodic_min = 5
var periodic_max = 10

onready var ambient_sounds = {
    "eerie_thunder": $EerieThunderAmbience,
    "wind": $WindAmbience,
    "earthquake": $EarthquakeAmbience,
}

onready var periodic_effects = {
    "near_thunder": [$NearThunderPlayer, false]
}

signal shake_screen
signal flash_screen

var all_effects = ["eerie_thunder", "wind", "earthquake", "near_thunder"]

func _ready():
    $PeriodicEffectTimer.connect("timeout", self, "_do_periodic_effect")

func set_ambience(plays):
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
        tween.interpolate_property(sound, "volume_db", -80, 0, fadeout_duration, Tween.TRANS_SINE, Tween.EASE_IN)
    elif name in periodic_effects:
        print("Ambience playing ", name)
        var timeout = rng.randf_range(periodic_min, periodic_max)
        print("Starting effect ", name, " in ", timeout, " seconds")
        self.current_periodic_effect_player = self.periodic_effects[name][0]
        $PeriodicEffectTimer.start(timeout)

func stop(name):
    if name in ambient_sounds && ambient_sounds[name].playing:
        print("Ambience stopping ", name)
        var sound = self.ambient_sounds[name]
        var tween = sound.find_node("Tween")
        tween.interpolate_property(sound, "volume_db", 0, -80, fadeout_duration, Tween.TRANS_SINE, Tween.EASE_IN)
        yield(tween, "tween_all_completed")
        sound.stop()
    elif name in periodic_effects && periodic_effects[name][1]:
        print("Ambience stopping ", name)
        self.current_periodic_effect_player = null
        $PeriodicEffectTimer.stop()

func _do_periodic_effect():
    print("Doing periodic effect: ", self.current_periodic_effect_player)
    self.current_periodic_effect_player.play()
    var timeout = rng.randf_range(periodic_min, periodic_max)
    print("Starting effect ", current_periodic_effect_player, " in ", timeout, " seconds")
    $PeriodicEffectTimer.start(timeout)

    emit_signal("shake_screen")
    emit_signal("flash_screen")
