extends Node2D
class_name Tile_Map


@onready var line_2d : Line2D = $UI/Line2D
@onready var highlight: TileMapLayer = $Highlight
var players : Array[Character] = []
var astar_grid : AStarGrid2D
@export var tile_map: TileMapLayer
@export var spawn_points : Array[Vector2i]
@export var start_point : Vector2i
@export var end_point : Vector2i
@export var deep_water_weight : float
@export var shallow_water_weight : float			
@export var highlight_color : Color
@export var destination_color : Color
var selected_tile : Vector2i
var current_tile_map: TileMapLayer

func _ready():
	var signalNode: Node2D = get_tree().get_first_node_in_group("TestSignal")
	signalNode.connect("node2DTouched", _test_clicked)
	
		
	for child in get_children():
		if child is Character:
			players.append(child)
			print("players are: " , players)
	for c in get_tree().get_nodes_in_group("characters"):
		c.playerClicked.connect(_on_player_clicked)
	
	current_tile_map = tile_map
	#region AstarSetup
	astar_grid = AStarGrid2D.new()
	astar_grid.region = current_tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32,32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	#endregion
	#region TileMapData
	for maps in get_children():
		print(maps)
		if maps is TileMapLayer:
			#region for why == is not correct. note for myself
			# == is not correct because maps is an instance of TileMapLayer, but TileMapLayer is a class reference.
			# Instead, you want to check if maps is an instance of TileMapLayer, which is does correctly.
			#endregion
			astar_map_data(maps)
			print("HI IM IN HERE")
	#endregion 
	

func clicked_tile() -> Vector2i:
	var local_mouse_pos = to_local((get_global_mouse_position()))
	var selected_tiles = current_tile_map.local_to_map(local_mouse_pos)
	print("Selected tile:= ", selected_tiles)
	return selected_tiles

func draw_path():
	line_2d.clear_points()
	highlight.clear()
	var path = astar_grid.get_id_path(start_point,end_point,true)
	if path.is_empty():
		print("No path found!")
		return
	var camera := get_viewport().get_camera_2d()
	for point in path:
		var world_pos: Vector2 = tile_map.map_to_local(point)
		var screen_pos: Vector2 = camera.get_screen_position() + (world_pos - camera.get_global_position())                 
		line_2d.add_point(screen_pos)
		#region old modulate tile code. 
		#highlight.modulate = Color(highlight_color)
		#highlight.set_cell(point,1,Vector2i(0,0))
		#endregion
		
func _on_mage_player_clicked(clicked_player,event: InputEvent) -> void:
	highlight.clear()
	print("Player Clicked! ", clicked_player)
	var path = clicked_player.tileLogic.get_reachable_tiles()
	print("reachableTiles:= ", path)
	for point in path:
		highlight.set_cell(point,1,Vector2i(0,0))
		
func astar_map_data(map: TileMapLayer):
	for x in map.get_used_rect().size.x:
		for y in map.get_used_rect().size.y:
				var tile_pos:Vector2i = Vector2i(
					x + map.get_used_rect().position.x,
					y + map.get_used_rect().position.y
				)
				var tile_data : TileData = map.get_cell_tile_data(tile_pos)
				if tile_data == null or tile_data.get_custom_data("Hazzard") == true:
					astar_grid.set_point_solid(tile_pos)
				elif tile_data.get_custom_data("DeepWater") == true:
					astar_grid.set_point_weight_scale(tile_pos,deep_water_weight)
				elif  tile_data.get_custom_data("ShallowWater") == true:
					astar_grid.set_point_weight_scale(tile_pos, shallow_water_weight)

func get_current_tile_map() -> TileMapLayer:
	var tilemap = current_tile_map
	return tilemap
func destination_colour(destination: Vector2i):
	print("destination_colour called...")
	if destination == clicked_tile():
		print("Changing Colour to:=",clicked_tile())
		highlight.clear()
		highlight.set_cell(clicked_tile(),1,Vector2i(0,0),1)

var current_player: Tile_Movement = null
func _on_player_clicked(character: Character, event: InputEvent) -> void:	
		highlight.clear()
		current_player = character.tileLogic
		var reachable = current_player.get_reachable_tiles()
		for point in reachable:
			highlight.set_cell(point, 1, Vector2i(0, 0))	

func _test_clicked():
	print("Test Singal was clicked!")
