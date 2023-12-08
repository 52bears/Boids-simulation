extends CharacterBody2D

@onready var screen_size = get_viewport_rect().size
@onready var stambar_tween: Tween # not relevant to boid code

var boids := [] # used to temporarily store 'boids' for fish/birds/flocking behaviour objects
@export var perception_radius = 40 # range in which boids see neighbouring boids
@export var speed = 100
@export var centering_factor = 0.0005 # cohesion
@export var avoid_factor = 0.05 # separation
@export var matching_factor = 0.05

func _process(_delta): 
	if $StaminaBar.value == 0:
		Globals.score += 100
		queue_free()

func _physics_process(delta):
	var neighbours = get_neighbours(perception_radius)
	cohesion_process(neighbours)
	separation_process(neighbours)
	alignment_process(neighbours)
	constain_to_screen() # purpose of this fx is to keep objects in game window
	velocity = velocity.limit_length(speed)
	move_and_slide()

func get_neighbours(view_radius):
	var neighbours := []
	for i in boids: 
		if i == null:
			pass
		elif position.distance_to(i.position) <= view_radius and i != self: # view_radius = perception_radius
			neighbours.append(i)
	return neighbours

func cohesion_process(neighbours): # cohesion - boids fly towards centre of mass of neighbouring boids
	var cohesion_vector = Vector2.ZERO
	if neighbours.is_empty():
		return cohesion_vector
	for i in neighbours:
		cohesion_vector += i.position
		if not neighbours.is_empty():
			cohesion_vector = cohesion_vector / neighbours.size()
	velocity += cohesion_vector * centering_factor
	return velocity

func separation_process(neighbours): # separation - boids keep a small distance away from other boids/objects
	var position_difference = Vector2.ZERO
	for i in neighbours:
		position_difference += position - i.position
		velocity += position_difference * avoid_factor
	return velocity

func alignment_process(neighbours): # alignment - boids try to match velocity with nearby boids
	var alignment_vector = Vector2.ZERO
	for i in neighbours:
		alignment_vector += i.velocity
		if not neighbours.is_empty():
			alignment_vector = alignment_vector / neighbours.size()
		velocity += alignment_vector * matching_factor
	return velocity

func constain_to_screen():
	const MARGIN = 50
	const turn_factor = 1
	if global_position.x < MARGIN:
		velocity.x += turn_factor
	elif global_position.x > (screen_size.x - MARGIN):
		velocity.x -= turn_factor
	elif global_position.y > (screen_size.y - MARGIN):
		velocity.y -= turn_factor
	elif global_position.y < MARGIN:
		velocity.y += turn_factor

# hitting the fish and fish stamina bars
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		$StaminaBar.value -= 50
		velocity += Vector2(randf_range(-1,1), randf_range(-1,1)) * 500 

func _on_area_2d_mouse_entered():
	if stambar_tween:	
		stambar_tween.kill()
	stambar_tween = $StaminaBar.create_tween()
	stambar_tween.tween_property($StaminaBar, "modulate:a", 1, 0.2)
	
func _on_area_2d_mouse_exited():
	if stambar_tween:	
		stambar_tween.kill()
	stambar_tween = $StaminaBar.create_tween()
	stambar_tween.tween_property($StaminaBar, "modulate:a", 0, 1)

func _on_life_timer_timeout():
	queue_free()
	queue_free()
