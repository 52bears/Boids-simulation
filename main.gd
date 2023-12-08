extends Node2D

@onready var spawn_location_list = [$SpawnLocations/east, $SpawnLocations/SE, $SpawnLocations/SW, $SpawnLocations/NE, $SpawnLocations/NW, $SpawnLocations/centerright, $SpawnLocations/centerleft, $SpawnLocations/south, $SpawnLocations/west, $SpawnLocations/north]
@onready var fishscene = preload("res://Fish/fish.tscn")
const FISH_COUNT = 100
var boids = []

func _ready():
	for i in FISH_COUNT:
		var fish = fishscene.instantiate()
		fish.position = Vector2(randf_range(0, 1110), randf_range(0, 600))
		$FishHolder.add_child(fish)
		boids.append(fish)

	for boid in $FishHolder.get_children():
		boid.boids = boids

func _process(_delta):
	if Globals.score == 1000:
		$UI/WinLabel.show()

func _on_fish_spawn_timer_timeout():
	var fish = fishscene.instantiate()
	fish.position = spawn_location_list[randf_range(0,9)].global_position
	$FishHolder.add_child(fish)
	boids.append(fish)
	
	for boid in $FishHolder.get_children():
		boid.boids = boids
