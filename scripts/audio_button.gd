extends Button
class_name AudioButton

@export var sound: AudioStream = preload("res://assets/audio/Zapps_18.wav")
var audio_player = null

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	self.connect("pressed", play_button_sound)
	
	if sound != null:
		audio_player.stream = sound
	
func play_button_sound():
	if audio_player.stream:
		audio_player.play()
	else:
		print("Button ")
