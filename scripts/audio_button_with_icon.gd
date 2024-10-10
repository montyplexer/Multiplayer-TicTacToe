extends AudioButton
class_name AudioIconButton

@export var icon_on: Texture2D
@export var icon_off: Texture2D

func _ready():
	super._ready()
	if pressed:
		icon = icon_on
	else:
		icon = icon_off

func _on_button_press():
	super._on_button_press()
	toggle_icon()

func toggle_icon():
	if icon == icon_off:
		icon = icon_on
	else:
		icon = icon_off
