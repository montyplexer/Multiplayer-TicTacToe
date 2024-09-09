extends Node

signal end_turn_signal(tile_id: Vector2)
signal end_game_signal()
signal new_game_signal()
# signal started_game_signal()
signal tile_pressed_signal(tile_id: Vector2)
signal toggle_remaining_tiles_signal(enable: bool)

var board = null

enum PLAYER { X, O }
var turn: int = PLAYER.X
var turn_num: int = 0
var scores: Array = []

var game_settings = GameSettings.new()

class GameSettings:
	var game_mode: String = "Singleplayer"
	var multiplayer_mode: String = "Hot Seat"
	var ai_difficulty: String = "Easy"
	var your_piece: String = "X"
	var opponent_piece: String = "O"

func game_ongoing() -> bool: return (turn_num > 0)

func _init():
	for players in PLAYER:
		scores.append(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func ptos(current_player: int):
	return PLAYER.keys()[current_player]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
