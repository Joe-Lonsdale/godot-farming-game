class_name Player extends CharacterBody3D

@export var WALK_SPEED = 4

@onready var pivot: Node3D = $Pivot
@onready var interactable_area: Area3D = $Pivot/Area3D
@onready var money_display: Label = $MoneyDisplay

var money: int = 0:
	get:
		return money
	set(value):
		money = value
		money_display.text = "$" + str(money)
var currently_interacting_with_body: Node3D = null
var currently_interacting_with_listener: InteractionTypeHold = null
var heldItem: Node3D = null

func _ready() -> void:
	interactable_area.body_entered.connect(_on_body_entered_interactable_area)
	pass

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = direction.x * WALK_SPEED
			velocity.z = direction.z * WALK_SPEED
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * WALK_SPEED, delta)
		velocity.z = lerp(velocity.z, direction.z * WALK_SPEED, delta)
	
	var look_input = Input.get_vector("look_right", "look_left", "look_down", "look_up")
	if look_input != Vector2.ZERO:
		var look_dir = (transform.basis * Vector3(look_input.x, 0, look_input.y)).normalized()
		var current_forward = transform.basis.z.normalized()
		var target_angle = current_forward.signed_angle_to(look_dir, Vector3.UP)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, target_angle, delta * 8.0)
	move_and_slide()
	
	if currently_interacting_with_listener != null:
		if Input.is_action_pressed("interact"):
			currently_interacting_with_listener.is_being_held = true
			currently_interacting_with_listener.hold_for(delta)
	

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var interactable_bodies: Array[Node3D] = interactable_area.get_overlapping_bodies()
		if self in interactable_bodies:
			interactable_bodies.erase(self)
		if interactable_bodies.size() == 1:
			interact_with_body(interactable_bodies[0])
	if event.is_action_released("interact") && currently_interacting_with_body != null:
		clear_currently_interacting()
	if event.is_action_released("delete (debug)") && heldItem:
		heldItem.queue_free()
		heldItem = null
		
func _on_body_entered_interactable_area(body: Node3D):
	if body == self: return

func interact_with_body(body: Node3D):
	if body == currently_interacting_with_body:
		return
	if body.has_method("interact"):
		if body.has_method("can_interact"):
			if !body.can_interact(self):
				return 
		clear_currently_interacting()
		var interaction_type: InteractionType = null
		if body.has_method("get_interaction_type"):
			interaction_type = body.get_interaction_type()
		if interaction_type is InteractionTypeHold:
			currently_interacting_with_body = body
			currently_interacting_with_listener = interaction_type
			interaction_type.interact.connect(on_held_interact_finish)
		else: 
			# base case, let us just press to interact.
			body.interact(self)

func on_held_interact_finish():
	currently_interacting_with_body.interact(self)
	clear_currently_interacting()

func clear_currently_interacting():
	if currently_interacting_with_body:
		currently_interacting_with_body = null
	if currently_interacting_with_listener:
		currently_interacting_with_listener.is_being_held = false
		currently_interacting_with_listener.interact.disconnect(on_held_interact_finish)
		currently_interacting_with_listener = null

func pick_up(item: PackedScene):
	if heldItem:
		return [heldItem, false]
	var item_node = item.instantiate()
	pivot.add_child(item_node)
	heldItem = item_node
	heldItem.translate(Vector3(0,1,1))
	return [item_node, true]

func put_down():
	var tempHeldItem
	heldItem.queue_free()
	heldItem = null
	return tempHeldItem
