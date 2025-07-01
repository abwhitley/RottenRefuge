extends CharacterBody2D

@onready var animator = $HealthBarAnimator
@onready var fillbar = $HealthBar/Fill
@onready var bgbar = $HealthBar/Background

@export var speed := 100.0
@export var max_health := 3
@export var player: NodePath  # Drag Player here in main scene

@onready var player_ref: Node2D = get_node(player)

var current_health = max_health

func _ready():
	update_healthbar(true)

func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_healthbar()
	if current_health <= 0:
		die()

func update_healthbar(immediate:= false):
	var percent = float(current_health) / float(max_health)
	var target_width = bgbar.size.x * percent
	
	if immediate:
		fillbar.size.x = target_width
	else:
		animator.stop()
		var anim = animator.get_animation("UpdateHealthBar")
		anim.track_set_key_value(0, 1, fillbar.size.x)
		anim.track_set_key_value(0, 2, target_width)
		animator.play("UpdateHealthBar")
		

func die():
	print("Enemy Died.")
	queue_free()

func _physics_process(delta: float) -> void:
	if not should_chase():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir = (player_ref.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

func should_chase() -> bool:
	var safe_zone = get_tree().get_first_node_in_group("SafeZone")
	if safe_zone and safe_zone.overlaps_body(player_ref):
		return false
	return true  # We’ll replace this in the next step
	
