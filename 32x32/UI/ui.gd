extends Control
class_name ui_control
var amount = 2
var button_container
signal movement_updated(value)

func _ready() -> void:
	button_container = %HBoxContainer
	print(button_container)
	for button: Button in button_container.get_children():
		button.text = str(amount)
		button.pressed.connect(_on_button_pressed.bind(amount))
		amount += 1
		
func _on_button_pressed(number: int) -> void:
	print(number)
	movement_updated.emit(number)
