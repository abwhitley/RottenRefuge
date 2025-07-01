extends CharacterBody2D

@export var speed: float = 100.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var weaponSprite: Sprite2D = $WeaponSprite

var facing_left: bool = false  # Track direction manually
var is_attacking = false
@export var attack_duration: float = 0.50

func _ready():
	weaponSprite.flip_h = false
	
func _input(event):
	if event.is_action_pressed("attack") and !is_attacking:
		start_attack()
		print("Attack Started")

func start_attack():
	
	is_attacking = true
	weaponSprite.z_as_relative = false
	$WeaponHitbox.monitoring = true
	$WeaponHitbox.set_deferred("monitorable", true)
	
	var start_position = weaponSprite.position
	var end_position = Vector2(25,3) if !facing_left else Vector2(-25,3)
	var end_angle = 360 if !facing_left else -360
	
	weaponSprite.position = start_position
	weaponSprite.rotation_degrees = 0
	weaponSprite.z_index = 10
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(weaponSprite, "rotation_degrees", end_angle, attack_duration)
	tween.tween_property(weaponSprite, "position", end_position, attack_duration)
	
	tween.set_parallel(false)
	tween.tween_callback(Callable(self, "end_attack"))
	tween.tween_interval(0.01)
	tween.tween_callback(Callable(self, "reset_weapon_z"))
	
	#is_attacking = true
	#weaponSprite.z_as_relative = false
	#$WeaponHitbox.monitoring = true
	#$WeaponHitbox.set_deferred("monitorable", true)
	#
	#var start_angle = 0;
	#var weapon_z_start = -1
	#var weapon_z_end = 10
	#var start_position = weaponSprite.position
	#var end_position = Vector2(25,3) if !facing_left else Vector2(-25,3)
	#var end_angle = 360 if !facing_left else -360
	#
	#weaponSprite.position = start_position
	#
	#var tween = create_tween()
	#tween.set_parallel(true)
	#tween.tween_property(weaponSprite, "rotation_degrees", end_angle, attack_duration).from(0)
	#tween.tween_property(weaponSprite, "position", end_position, attack_duration)
	#tween.tween_property(weaponSprite, "z_index", weapon_z_end, attack_duration)
	#
	#tween.tween_interval(0.01)
	#tween.tween_property(weaponSprite, "z_index", weapon_z_start, 0.01)
	#tween.tween_callback(Callable(self, "end_attack"))

func reset_weapon_z():
	weaponSprite.z_index = -1
	weaponSprite.z_as_relative = true


func end_attack():
	is_attacking = false
	weaponSprite.rotation_degrees = 0
	weaponSprite.z_as_relative = true
	$WeaponHitbox.monitoring = false
	$WeaponHitbox.set_deferred("monitorable", false)



func _physics_process(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = input_vector * speed
	move_and_slide()

	# Update facing direction only when moving horizontally
	if input_vector.x != 0:
		facing_left = input_vector.x < 0

	# Apply flipping consistently every frame
	sprite.flip_h = facing_left
	weaponSprite.flip_h = !facing_left
	
	if facing_left:
		weaponSprite.position = Vector2(8,3)
	else:
		weaponSprite.position = Vector2(-5,3)

	# Play animation based on movement
	if input_vector != Vector2.ZERO:
		sprite.play("run")
	else:
		sprite.play("idle")


func _on_weapon_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(1)
