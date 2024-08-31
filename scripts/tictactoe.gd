class_name TicTacToe
extends Control

var grid: Array = []
var rows: int = 3
var cols: int = 3

# ------------------------
# --- START-UP & RESET ---
# ------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	ui_update_settings()
	Global.end_turn_signal.connect(end_turn)
	for r in rows:
		grid.append([])
		for c in cols:
			grid[r].append(".")

func clear_board():
	for r in rows:
		for c in cols:
			grid[r][c] = "."

# -------------
# --- DEBUG ---
# -------------

## Return a string representation of the current board
func grid_to_string():
	var ttt = ""
	for r in rows:
		for c in cols:
			ttt = str(ttt,grid[c][r])
		if r-1 < rows:
			ttt += '\n'
	return ttt

# ---------------------------------------------
# --- TURN-BASED MECHANICS & WIN CONDITIONS ---
# ---------------------------------------------

## Check if a player has won
func has_won(player: String):
	for n in 3:
		# Row Wins
		if player == grid[n][0] and player == grid[n][1] and player == grid[n][2]: 
			print("r n=",str(n))
			return true
		# Col Wins
		if player == grid[0][n] and player == grid[1][n] and player == grid[2][n]: 
			print("c n=",str(n))
			return true
	# Diagonal TL to BR Win
	if player == grid[0][0] and player == grid[1][1] and player == grid[2][2]: 
		print("d1")
		return true
	# Diagonal TR to BL Win
	if player == grid[0][2] and player == grid[1][1] and player == grid[2][0]: 
		print("d2")
		return true
	# No Win
	return false

## Check if there is a draw
# TODO: make this function smarter
func is_draw():
	for r in rows:
		for c in cols:
			if grid[c][r] == '.':
				return false
	return true

# Handle end of turn logic
func end_turn(tile_id: Vector2):
	var message: String
	
	# Update grid
	grid[tile_id.x][tile_id.y] = Global.ptos(Global.turn)
	
	# Check for win
	if has_won(Global.ptos(Global.turn)):
		# Updated score
		Global.scores[Global.turn] += 1
		Global.end_game_signal.emit()
		
		# Update UI Labels
		ui_update_score_labels()
		message = str(Global.ptos(Global.turn)," won!")
		ui_update_turn_label(message)
		
		# Debug
		print(message)
		print(grid_to_string())
		return
	
	# Check for a draw
	print(str(is_draw()))
	if is_draw():
		Global.end_game_signal.emit()
		
		# Update UI Labels
		ui_update_score_labels()
		message = "It's a draw!"
		ui_update_turn_label(message)
		
		# Debug
		print(message)
		print(grid_to_string())
		return
	
	# Move to next person's turn
	if Global.turn == Global.PLAYER.X: Global.turn = Global.PLAYER.O
	elif Global.turn == Global.PLAYER.O: Global.turn = Global.PLAYER.X
	else: Global.turn = Global.PLAYER.X
	
	# Update UI Labels
	message = str("It is ",Global.ptos(Global.turn),"'s turn.")
	ui_update_turn_label(message)
	
	# Debug
	print(message)
	print(grid_to_string())

# ------------------
# --- UI UPDATES ---
# ------------------

func ui_update_settings():
	ui_update_game_settings_label()
	ui_update_button_visiblity()

func ui_update_button_visiblity():
	if Global.game_settings.game_mode == "Singleplayer":
		%SingleplayerSettingsBox.show()
		%MultiplayerSettingsBox.hide()
	if Global.game_settings.game_mode == "Multiplayer":
		%SingleplayerSettingsBox.hide()
		%MultiplayerSettingsBox.show()
		if Global.game_settings.multiplayer_mode == "Hot Seat":
			%OnlineSettingsBox.hide()
		if Global.game_settings.multiplayer_mode == "Online":
			%OnlineSettingsBox.show()

func ui_update_game_settings_label():
	var message = "--Game Settings--"
	
	message += "\n" + Global.game_settings.game_mode
	if Global.game_settings.game_mode == "Singleplayer":
		message += "\n" + Global.game_settings.ai_difficulty
	if Global.game_settings.game_mode == "Multiplayer":
		message += "\n" + Global.game_settings.multiplayer_mode
	
	%GameSettingsLabel.text = message

func ui_update_score_labels():
	%XScoreLabel.text = str(Global.scores[Global.PLAYER.X])
	%OScoreLabel.text = str(Global.scores[Global.PLAYER.O])

func ui_update_turn_label(message: String):
	%TurnLabel.text = message

# ----------------------
# --- BUTTON SIGNALS ---
# ----------------------

# New Game Button
func _on_new_game_button_pressed():
	clear_board()
	Global.new_game_signal.emit()

# Gamemode Settings Buttons
func _on_singleplayer_button_pressed():
	Global.game_settings.game_mode = "Singleplayer"
	ui_update_settings()

func _on_multiplayer_button_pressed():
	Global.game_settings.game_mode = "Multiplayer"
	ui_update_settings()

# Multiplayer Settings Buttons
func _on_hot_seat_button_pressed():
	Global.game_settings.multiplayer_mode = "Hot Seat"
	ui_update_settings()

func _on_online_button_pressed():
	Global.game_settings.multiplayer_mode = "Online"
	ui_update_settings()

# Singleplayer Settings Buttons
func _on_ai_easy_button_pressed():
	Global.game_settings.ai_difficulty = "Easy"
	ui_update_settings()

func _on_ai_medium_button_pressed():
	Global.game_settings.ai_difficulty = "Medium"
	ui_update_settings()

func _on_ai_hard_button_pressed():
	Global.game_settings.ai_difficulty = "Hard"
	ui_update_settings()

func _on_x_score_title_button_pressed():
	Global.game_settings.player_piece = "X"
	Global.game_settings.opponent_piece = "O"
	ui_update_settings()

func _on_o_score_title_button_pressed():
	Global.game_settings.player_piece = "0"
	Global.game_settings.opponent_piece = "X"
	ui_update_settings()

# ----------
# --- AI ---
# ----------

func ai_make_move(ai_move: Vector2):
	grid[ai_move.x][ai_move.y] = Global.game_settings.opponent_piece

## Choose a random tile
func ai_easy():
	var open_tiles: Array = []
	var ai_selection: Vector2
	for r in rows:
		for c in cols:
			if grid[r][c] == ".":
				open_tiles.append(Vector2(r,c))
	return open_tiles[randi() % open_tiles.size()]

func ai_medium():
	pass

func ai_hard():
	pass






