extends AudioButton
class_name AudioIconButton

@export var icon_on: Texture2D
@export var icon_off: Texture2D

func _ready():
	self.connect("pressed", toggle_icon)
	if pressed:
		icon = icon_on
	else:
		icon = icon_off

func toggle_icon():
	if icon == icon_off:
		icon = icon_on
	else:
		icon = icon_off
