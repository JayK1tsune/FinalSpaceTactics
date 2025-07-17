extends Node
class_name Tile_Movement

var tileMap : Tile_Map
var current_tile : Vector2i
var path: Array = []
var target_pos: Vector2i
var mage_was_clicked = false
var is_moving : bool = false

@export var sprite: AnimatedSprite2D 
@export var character : Character


func _ready() -> void:
	tileMap = get_parent().find_parent("TileMaps") as Tile_Map
	print(tileMap)
	current_tile = tileMap.spawn_points[character.spawn_number]
	sprite.global_position = tileMap.tile_map.map_to_local(current_tile)
	

func _process(delta: float) -> void:
	
	if is_moving and path.size() > 0:
		var next_tile = path[0]
		target_pos = tileMap.tile_map.map_to_local(next_tile)
		var direction = (target_pos as Vector2 - sprite.global_position).normalized()
		sprite.global_position = sprite.global_position.move_toward(target_pos, character.speed * delta)
		character.update_animation(direction)
		if sprite.global_position.distance_to(target_pos) < 1:
			sprite.global_position = target_pos
			current_tile = next_tile
			path.pop_front()
			if path.size() == 0 :
				is_moving = false
				sprite.play("Idle")
				#region Timer add
				var timer = Timer.new()
				timer.wait_time = 0.2
				timer.one_shot = true
				timer.timeout.connect(func(): clear_paths(timer))
				add_child(timer)
				timer.start()
				#endregion Timer Ends

func clear_paths(timer: Timer) -> void :
	tileMap.line_2d.clear_points()
	tileMap.highlight.clear()
	mage_was_clicked = false
	timer.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if self != tileMap.current_player:
		return
	if event is InputEventMouseButton and event.is_action_pressed("click") and !is_moving:
		tileMap.line_2d.clear_points()
		var local_mouse_pos = tileMap.to_local((sprite.get_global_mouse_position()))
		# check to see if the mouse is over the Mage
		if local_mouse_pos == %TextureRect.position:
			return
		# logic for tile selection 
		var click_tile = tileMap.tile_map.local_to_map(local_mouse_pos)
		var tile_data : TileData = tileMap.tile_map.get_cell_tile_data(click_tile)	
		if tile_data == null:
			return
			
		var start_tile = tileMap.tile_map.local_to_map(sprite.global_position)
		print("start tile := ", start_tile)
		print("click tile := ", click_tile)
		if get_reachable_tiles().has(click_tile):
			path = tileMap.astar_grid.get_id_path(start_tile, click_tile, true)
			tileMap.destination_colour(click_tile)
			if path.size() > 0:
				for tile in path:
					var world_pos  : Vector2 = tileMap.tile_map.map_to_local(tile)       # world
					var local_pos  : Vector2 = tileMap.line_2d.to_local(world_pos)
					tileMap.line_2d.add_point(local_pos)
				is_moving = true
			

func get_reachable_tiles():
	print("I was called")
	var reachable_tiles: Array = []
	var start_tile : Vector2i = current_tile
	#print("Current Tile := ", current_tile)
	#The -movementRange ensures the loop covers the entire grid of tiles around the character
	print(character.movementRange)
	for x in range(-character.movementRange, character.movementRange + 1):
		for y in range(-character.movementRange, character.movementRange+ 1):
			var check_tile: Vector2i = Vector2i(start_tile.x + x, start_tile.y +y)
			if !tileMap.astar_grid.is_in_bounds(check_tile.x , check_tile.y):
				continue
			var path := tileMap.astar_grid.get_id_path(start_tile, check_tile, true)
			var hazzards: TileData = tileMap.tile_map.get_cell_tile_data(check_tile)
			if hazzards == null or hazzards.get_custom_data("Hazzard") == true or hazzards.get_custom_data("Tree"):
				#print("Hazard found at tile:", check_tile)
				continue
			if path.size() > 0 and path.size() <= character.movementRange +1 :
				reachable_tiles.append(check_tile)
	return reachable_tiles
			
			
