extends Node2D


class_name Character

@export var resource : character_resource
@export var tileLogic : Tile_Movement
@onready var mage: AnimatedSprite2D = $Mage
@onready var movementRange = resource.movement
@onready var attackDmg = resource.attackDmg
@onready var health = resource.health
@onready var speed = resource.speed
signal playerClicked(event: InputEvent)
var spawn_number : int :
	get:
		return resource.spawnNumber



func update_animation(direction: Vector2) -> void:
	
	var anim = ""
	if direction.y < 0: 
		if direction.x > 0:
			anim = "Walk_NE"
		else:
			anim = "Walk_NW"
	else:
		if direction.x > 0:
			anim = "Walk_SE"
		else:
			anim = "Walk_SW"
	if mage.animation != anim:
		mage.play(anim)
			

func _on_ui_movment_updated(value: Variant) -> void:
	print(value)
	tileLogic.tileMap.highlight.clear()
	tileLogic.character.movementRange = value


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		print("I clicked the Mage")
		playerClicked.emit(self, event)
		get_viewport().set_input_as_handled()	
