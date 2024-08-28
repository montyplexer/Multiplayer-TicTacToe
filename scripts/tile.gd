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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func disable_tile():
	$ChoiceButton.visible = false

func reset_tile():
	$X.visible = false
	$O.visible = false
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
	if Global.turn == Global.PLAYER.X and tile_id == id: $X.visible = true
	if Global.turn == Global.PLAYER.O and tile_id == id: $O.visible = true

func _on_choice_button_pressed():
	$ChoiceButton.visible = false
	set_tile_sprite(Vector2(id))
	Global.end_turn_signal.emit(id)
