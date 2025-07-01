extends CharacterBody2D

@export var dialogue_text: String = "Stay close to the light. It may not forgive, but it does not forget."

var player_in_range = false
@onready var npc_sprite: Sprite2D = $Sprite2D  # Change path if NPC is deeper

func _ready():
	var tex = npc_sprite.texture
	if tex:
		var image_size = tex.get_size()
		var scale = npc_sprite.scale
		var final_size = image_size * scale

		print("Original texture size: ", image_size)
		print("Sprite2D scale: ", scale)
		print("Final rendered size in pixels: ", final_size)
	else:
		print("NPC texture not assigned.")


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
		
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		show_dialogue()

func show_dialogue():
	print(dialogue_text)
