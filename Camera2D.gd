extends Camera2D

var rng = RandomNumberGenerator.new()
var shake_strength = 4.0
var previous_shake_offset = Vector2.ZERO

func _ready():
    $ShakeTimer.connect("timeout", self, "_on_shake_timeout")
    $FlashTimer.connect("timeout", self, "_on_flash_timeout")
