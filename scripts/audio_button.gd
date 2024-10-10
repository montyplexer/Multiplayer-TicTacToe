extends Button
class_name AudioButton

@export var sound: AudioStream = preload("res://assets/audio/tic-tac-toe_button-press-default.wav")
var audio_player = AudioStreamPlayer.new()


func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_setup()

func _on_button_press():
	play_button_sound()

func play_button_sound():
	if audio_setup(): audio_player.play()
	else: print("AudioStream not set up properly!")

func audio_setup():
	if sound == null: 
		print("Sound file not found!")
		return false
	if audio_player == null:
		print("Audio player not initialized!")
		return false
	if (audio_player.stream): 
		return true
	
	audio_player.stream = sound
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = &"SFX"
	audio_player.volume_db = -3
	add_child(audio_player)
	if not self.is_connected("pressed", _on_button_press): self.connect("pressed", _on_button_press)
	return (audio_player and audio_player.stream)
	
	






