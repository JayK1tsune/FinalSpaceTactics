extends Node2D
class_name TestSignals

signal node2DTouched
signal node2DExited
signal secondSignal

var signalSent : bool = false

const TEST_SIGNAL = "TestSignal"

func _ready() -> void:
	add_to_group(TEST_SIGNAL)
	self.connect("secondSignal",_secondSignalpop)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("Node2dClicked")
		emit_signal("node2DTouched")
		emit_signal("secondSignal")


func _on_area_2d_mouse_exited() -> void:
	signalSent = true
	emit_signal("node2DExited")
	
func _secondSignalpop():
	print("Second Signal Sent")
		
	
