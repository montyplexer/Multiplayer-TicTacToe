class_name Tile
extends Node2D

@export var player: String = "."
@export var id: Vector2 = Vector2(-1,-1)
var x_sprite
var o_sprite

#@export var shortcut_key: String = ""

func _init(tile_id: Vector2=Vector2(-1,-1)):
	id = Vector2(tile_id)
	player = "."
	#print("Tile (",id.x,",",id.y,"): Init!")

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_tile()
	Global.end_game_signal.connect(disable_tile)
	Global.new_game_signal.connect(reset_tile)
	Global.tile_pressed_signal.connect(virtual_press)
	Global.toggle_remaining_tiles_signal.connect(toggle_tile)
	$AudioMarkingX.bus = &"SFX"
	$AudioMarkingO.bus = &"SFX"

func virtual_press(id: Vector2):
	$ChoiceButton.visible = false
	#print("HERE ",str(id))
	set_tile_sprite(Vector2(id))

func toggle_tile(enable: bool):
	if player == ".":
		if enable == true: enable_tile()
		else: disable_tile()

func disable_tile():
	$ChoiceButton.visible = false

func enable_tile():
	$ChoiceButton.visible = true

func reset_tile():
	$X.visible = false
	$O.visible = false
	if Global.game_settings.game_mode == "Singleplayer":
		$ChoiceButton.visible = (Global.game_settings.your_piece == Global.ptos(Global.turn))
	if Global.game_settings.game_mode == "Multiplayer":
		if Global.game_settings.multiplayer_mode == "Hot Seat":
			$ChoiceButton.visible = true
	player = "."
	
	# Sprite variation
	match (randi() % 4):
		1:
			$X.rotate(PI)
			$O.rotate(PI)
		2:
			$X.flip_h = true
			$O.flip_h = true
		3:
			$X.rotate(PI)
			$O.rotate(PI)
			$X.flip_h = true
			$O.flip_h = true
	
	print("Tile (",id.x,",",id.y,"): Ready!")

func set_tile_sprite(tile_id: Vector2):
	if Global.turn == Global.PLAYER.X and tile_id == id: 
		$X.visible = true
		$AudioMarkingX.play()
		player = "X"
	if Global.turn == Global.PLAYER.O and tile_id == id: 
		$O.visible = true
		$AudioMarkingO.play()
		player = "O"

func _on_choice_button_pressed():
	$ChoiceButton.visible = false
	# print("HERE ",str(id))
	set_tile_sprite(Vector2(id))
	Global.end_turn_signal.emit(id)
