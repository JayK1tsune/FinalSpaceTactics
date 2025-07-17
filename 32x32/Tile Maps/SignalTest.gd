extends Node2D
class_name TestSignals

signal node2DTouched
const TEST_SIGNAL = "TestSignal"

func _ready() -> void:
	add_to_group(TEST_SIGNAL)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("Node2dClicked")
		emit_signal("node2DTouched")
