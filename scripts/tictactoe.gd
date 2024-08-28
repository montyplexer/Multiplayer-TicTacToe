class_name TicTacToe
extends Control

var grid: Array = []
var rows: int = 3
var cols: int = 3

## Create new empty board
func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	ui_update_settings()
	Global.end_turn_signal.connect(end_turn)
	for r in rows:
		grid.append([])
		for c in cols:
			grid[r].append(".")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func clear_board():
	for r in rows:
		for c in cols:
			grid[r][c] = "."

## Return a string to print to the output
func grid_to_string():
	var ttt = ""
	for r in rows:
		for c in cols:
			ttt = str(ttt,grid[c][r])
		if r-1 < rows:
			ttt += '\n'
	return ttt

## Check if a player has won
func has_won(player: String):
	for n in 3:
		# Row Wins
		if player == grid[n][0] and player == grid[n][1] and player == grid[n][2]: return true
		# Col Wins
		if player == grid[0][n] and player == grid[1][n] and player == grid[2][n]: return true
	# Diagonal TL to BR Win
	if player == grid[0][0] and player == grid[1][1] and player == grid[2][2]: return true
	# Diagonal TR to BL Win
	if player == grid[0][2] and player == grid[1][1] and player == grid[0][2]: return true
	# No Win
	return false

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
