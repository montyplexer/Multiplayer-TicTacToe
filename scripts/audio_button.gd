extends Button
class_name AudioButton

@export var sound: AudioStream = preload("res://assets/audio/tic-tac-toe_button-press-default.wav")
var audio_player = null

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = -3
	add_child(audio_player)
	self.connect("pressed", play_button_sound)
	
	if sound != null:
		audio_player.stream = sound
	
func play_button_sound():
	if audio_player.stream:
		audio_player.play()
	else:
		print("Button ")
