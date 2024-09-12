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
	Global.board = self
	randomize()
	ui_update_settings()
	Global.end_turn_signal.connect(end_turn)
	for r in rows:
		grid.append([])
		for c in cols:
			grid[r].append(".")
	%BackgroundMusicPlayer.bus = &"BGM"
	%BackgroundMusicPlayer.play()

func clear_board():
	Global.turn_num = 0
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
func has_won(player: String, grid: Array):
	for n in 3:
		# Row Wins
		if player == grid[n][0] and player == grid[n][1] and player == grid[n][2]: 
			#print("r n=",str(n))
			return true
		# Col Wins
		if player == grid[0][n] and player == grid[1][n] and player == grid[2][n]: 
			#print("c n=",str(n))
			return true
	# Diagonal TL to BR Win
	if player == grid[0][0] and player == grid[1][1] and player == grid[2][2]: 
		#print("d1")
		return true
	# Diagonal TR to BL Win
	if player == grid[0][2] and player == grid[1][1] and player == grid[2][0]: 
		#print("d2")
		return true
	# No Win
	return false

## Check if there is a draw
# TODO: make this function smarter
func is_draw(grid: Array):
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
	if has_won(Global.ptos(Global.turn),grid):
		# Updated score
		Global.scores[Global.turn] += 10
		message = str(Global.ptos(Global.turn)," won!")
		handle_ui_and_wrap_up(message)
		return
	
	# Check for a draw
	if is_draw(grid):
		# Updated score
		Global.scores[Global.PLAYER.X] += 5
		Global.scores[Global.PLAYER.O] += 5
		message = "It's a draw!"
		handle_ui_and_wrap_up(message)
		return
	
	# Move to next person's turn
	if Global.turn == Global.PLAYER.X: Global.turn = Global.PLAYER.O
	elif Global.turn == Global.PLAYER.O: Global.turn = Global.PLAYER.X
	else: Global.turn = Global.PLAYER.X
	Global.turn_num += 1
	toggle_settings_buttons(false)
	
	# Update UI Labels
	message = str("It is ",Global.ptos(Global.turn),"'s turn.")
	ui_update_turn_label(message)
	
	# 
	if Global.ptos(Global.turn) == Global.game_settings.your_piece:
		Global.toggle_remaining_tiles_signal.emit(true)
	else:
		if Global.game_settings.game_mode == "Singleplayer":
			Global.toggle_remaining_tiles_signal.emit(false)
			if Global.game_settings.ai_difficulty == "Easy":
				ai_make_move(ai_easy())
			if Global.game_settings.ai_difficulty == "Medium":
				ai_make_move(ai_medium())
			if Global.game_settings.ai_difficulty == "Hard":
				ai_make_move(ai_hard())
		elif Global.game_settings.game_mode == "Multiplayer":
			if Global.game_settings.multiplayer_mode == "Hot Seat":
				pass
			if Global.game_settings.multiplayer_mode == "Online":
				online_wait()
	
	# Debug
	print("Turn Num: ",Global.turn_num)
	print(message)
	print(grid_to_string())

func handle_ui_and_wrap_up(message: String):
	# Wrap up game
	Global.turn_num = 0
	Global.end_game_signal.emit()
	
	# Enable Buttons
	toggle_settings_buttons(true)
	
	# Update UI Labels
	ui_update_score_labels()
	ui_update_turn_label(message)
	
	# Debug
	print(message)
	print(grid_to_string())

# ------------------
# --- NETWORKING ---
# ------------------

func online_wait():
	pass

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
		%OnlineSettingsBox.hide()
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

func toggle_settings_buttons(enable: bool):
	# Singleplayer
	%SingleplayerButton.disabled = not enable
	%AIEasyButton.disabled = not enable
	%AIMediumButton.disabled = not enable
	%AIHardButton.disabled = not enable
	# Multiplayer
	%MultiplayerButton.disabled = not enable
	%HotSeatButton.disabled = not enable
	%OnlineButton.disabled = not enable
	%IPLineEdit.editable = enable
	%IPConnectButton.disabled = not enable

# ----------------------
# --- BUTTON SIGNALS ---
# ----------------------

# (New Game Button)

func _on_new_game_button_pressed():
	clear_board()
	toggle_settings_buttons(true)
	
	if Global.game_settings.game_mode == "Singleplayer":
		Global.turn = Global.PLAYER.X
		Global.new_game_signal.emit()
		# If AI goes first, make them go first
		if Global.game_settings.opponent_piece == Global.ptos(Global.turn): 
			toggle_settings_buttons(false)
			ai_make_move(ai_easy())
	if Global.game_settings.game_mode == "Multiplayer":
		Global.new_game_signal.emit()
		if Global.game_settings.multiplayer_mode == "Hot Seat":
			if Global.game_settings.your_piece == "X": Global.turn = Global.PLAYER.X
			if Global.game_settings.your_piece == "O": Global.turn = Global.PLAYER.O
	
	# Update UI Labels
	var message = str("It is ",Global.ptos(Global.turn),"'s turn.")
	ui_update_turn_label(message)

# (Gamemode Settings Buttons)

func _on_singleplayer_button_pressed():
	Global.game_settings.game_mode = "Singleplayer"
	ui_update_settings()
	_on_new_game_button_pressed()

func _on_multiplayer_button_pressed():
	Global.game_settings.game_mode = "Multiplayer"
	ui_update_settings()
	_on_new_game_button_pressed()

# (Multiplayer Settings Buttons)

func _on_hot_seat_button_pressed():
	Global.game_settings.multiplayer_mode = "Hot Seat"
	ui_update_settings()

func _on_online_button_pressed():
	Global.game_settings.multiplayer_mode = "Online"
	ui_update_settings()

# (Singleplayer Settings Buttons)

func _on_ai_easy_button_pressed():
	Global.game_settings.ai_difficulty = "Easy"
	ui_update_settings()

func _on_ai_medium_button_pressed():
	Global.game_settings.ai_difficulty = "Medium"
	ui_update_settings()

func _on_ai_hard_button_pressed():
	Global.game_settings.ai_difficulty = "Hard"
	ui_update_settings()

# (Change Who's Turn It Is Buttons)

func _on_x_score_title_button_pressed():
	Global.game_settings.your_piece = "X"
	Global.game_settings.opponent_piece = "O"
	ui_update_turn_label("Now playing as X.")
	ui_update_settings()
	_on_new_game_button_pressed()

func _on_o_score_title_button_pressed():
	Global.game_settings.your_piece = "O"
	Global.game_settings.opponent_piece = "X"
	ui_update_turn_label("Now playing as O.")
	ui_update_settings()
	_on_new_game_button_pressed()

func _on_music_button_pressed():
	var bgm_channel = AudioServer.get_bus_index(&"BGM")
	var bgm_channel_volume = AudioServer.get_bus_volume_db(bgm_channel)
	if Global.bgm:
		Global.bgm = false
		AudioServer.set_bus_volume_db(bgm_channel,-80)
	else:
		Global.bgm = true
		AudioServer.set_bus_volume_db(bgm_channel,0)

func _on_sound_button_pressed():
	var sfx_channel = AudioServer.get_bus_index(&"SFX")
	var sfx_channel_volume = AudioServer.get_bus_volume_db(sfx_channel)
	if Global.sfx:
		Global.sfx = false
		AudioServer.set_bus_volume_db(sfx_channel,-80)
	else:
		Global.sfx = true
		AudioServer.set_bus_volume_db(sfx_channel,0)

func _on_reset_score_button_pressed():
	Global.scores[Global.PLAYER.X] = 0 
	Global.scores[Global.PLAYER.O] = 0
	ui_update_score_labels()
	_on_new_game_button_pressed()

# ----------
# --- AI ---
# ----------

## The function representing the AI's turn
func ai_make_move(ai_move: Vector2):
	ai_toggle_buttons(false)
	await get_tree().create_timer(0.75).timeout
	Global.tile_pressed_signal.emit(ai_move)
	ai_toggle_buttons(true)
	end_turn(ai_move)

func ai_toggle_buttons(enable: bool):
	%NewGameButton.disabled = not enable
	%XScoreTitleButton.disabled = not enable
	%OScoreTitleButton.disabled = not enable

## Choose a random tile
func ai_easy():
	var open_tiles: Array = available_moves(grid)
	return open_tiles[randi() % open_tiles.size()]

## Defend against player attacks only. Otherwise choose a random tile.
func ai_medium():
	# Defend against player
	var move = imminent_victory(Global.game_settings.your_piece, grid)
	if move != Vector2(-1,-1): return move
	# Attack (randomly)
	return ai_easy()

## Actively try to win the game. Only defend if there is no imminent AI victory.
func ai_hard():
	if Global.turn_num == 1:
		if grid[1][1] == ".":
			return Vector2(1,1)
		var corners = available_corners()
		return corners[randi() % corners.size()]
	if Global.turn_num == 3:
		if grid[1][1] == Global.game_settings.opponent_piece:
			if Global.game_settings.your_piece == grid[0][0] and grid[0][0] == grid[2][2]:
				var edges = available_edges()
				return edges[randi() % edges.size()]
	var next_move = imminent_victory(Global.game_settings.opponent_piece, grid)
	if next_move != Vector2(-1,-1): return next_move
	return ai_medium()

## A board with an imminent victory is one where a player, on their next turn, wins the game.
## Returns true if the board has an imminent victory for the player specified.
func imminent_victory(piece: String, grid: Array):
	for n in 3:
		# Row-wise player victory imminent
		if piece == grid[n][0] and grid[n][0] == grid[n][1] and grid[n][2] == ".":
			return Vector2(n,2)
		if piece == grid[n][0] and grid[n][0] == grid[n][2] and grid[n][1] == ".":
			return Vector2(n,1)
		if piece == grid[n][1] and grid[n][1] == grid[n][2] and grid[n][0] == ".":
			return Vector2(n,0)
		# Column-wise player victory imminent
		if piece == grid[0][n] and grid[0][n] == grid[1][n] and grid[2][n] == ".":
			return Vector2(2,n)
		if piece == grid[0][n] and grid[0][n] == grid[2][n] and grid[1][n] == ".":
			return Vector2(1,n)
		if piece == grid[1][n] and grid[1][n] == grid[2][n] and grid[0][n] == ".":
			return Vector2(0,n)
	# Diagonal-wise player victory imminent
	# D1
	if piece == grid[0][0] and grid[0][0] == grid[1][1] and grid[2][2] == ".":
		return Vector2(2,2)
	if piece == grid[0][0] and grid[0][0] == grid[2][2] and grid[1][1] == ".":
		return Vector2(1,1)
	if piece == grid[1][1] and grid[1][1] == grid[2][2] and grid[0][0] == ".":
		return Vector2(0,0)
	# D2
	if piece == grid[0][2] and grid[0][2] == grid[1][1] and grid[2][0] == ".":
		return Vector2(2,0)
	if piece == grid[0][2] and grid[0][2] == grid[2][0] and grid[1][1] == ".":
		return Vector2(1,1)
	if piece == grid[1][1] and grid[1][1] == grid[2][0] and grid[0][2] == ".":
		return Vector2(0,2)
	return Vector2(-1,-1)

## Returns list of board corner tiles that are unclaimed.
func available_corners():
	var corners = []
	if grid[0][0] == ".": corners.append(Vector2(0,0))
	if grid[0][2] == ".": corners.append(Vector2(0,2))
	if grid[2][2] == ".": corners.append(Vector2(2,2))
	if grid[2][0] == ".": corners.append(Vector2(2,0))
	return corners

## Returns list of board edge tiles that are unclaimed.
func available_edges():
	var edges = []
	if grid[0][1] == ".": edges.append(Vector2(0,1))
	if grid[1][0] == ".": edges.append(Vector2(1,0))
	if grid[1][2] == ".": edges.append(Vector2(1,2))
	if grid[2][1] == ".": edges.append(Vector2(2,1))
	return edges

## Returns list of all unclaimed board tiles.
func available_moves(game_state: Array):
	var open_tiles: Array = []
	for r in rows:
		for c in cols:
			if grid[r][c] == ".":
				open_tiles.append(Vector2(r,c))
	return open_tiles

# ---------------
# --- Utility ---
# ---------------

## Creates a deep copy of a 2D array.
func deep_copy_2D(original: Array):
	var new_vector: Array = []
	for r in original.size():
		new_vector.append([])
		for c in original[r].size():
			new_vector[r].append(original[r][c])
	return new_vector
