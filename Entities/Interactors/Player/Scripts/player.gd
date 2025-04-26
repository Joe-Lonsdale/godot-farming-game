class_name Player extends CharacterBody3D

@export var walk_speed := 4
@export var separate_look_controls := true

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
var held_item: Node3D = null
var smoothed_input_dir: Vector2 = Vector2.ZERO
	


func _ready() -> void:
	interactable_area.body_entered.connect(_on_body_entered_interactable_area)
	interactable_area.body_exited.connect(_on_body_exited_interactable_area)
	pass

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	smoothed_input_dir = smoothed_input_dir.lerp(input_dir, delta * 10.0)
	var world_input = transform.basis * Vector3(smoothed_input_dir.x, 0, smoothed_input_dir.y)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if is_on_floor():
		if world_input.length_squared() > 0.0001:
			horizontal_velocity = world_input.normalized() * walk_speed * smoothed_input_dir.length()
		else:
			horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, delta * 7.0)
	else:
		horizontal_velocity = horizontal_velocity.lerp(world_input.normalized() * walk_speed * smoothed_input_dir.length(), delta)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	if separate_look_controls:
		var look_input = Input.get_vector("look_right", "look_left", "look_down", "look_up")
		if look_input != Vector2.ZERO:
			var look_dir = (transform.basis * Vector3(look_input.x, 0, look_input.y)).normalized()
			var current_forward = transform.basis.z.normalized()
			var target_angle = current_forward.signed_angle_to(look_dir, Vector3.UP)
			pivot.rotation.y = lerp_angle(pivot.rotation.y, target_angle, delta * 8.0)
	
	else:
		var flat_velocity = Vector3(velocity.x, 0, velocity.z)
		if flat_velocity.length_squared() > 0.0001:
			var look_dir = (transform.basis * flat_velocity).normalized()
			var current_forward = transform.basis.z.normalized()
			var target_angle = current_forward.signed_angle_to(look_dir, Vector3.UP)
			pivot.rotation.y = lerp_angle(pivot.rotation.y, target_angle, delta * 8.0)
	move_and_slide()
	
	if currently_interacting_with_listener != null:
		if Input.is_action_pressed("interact"):
			currently_interacting_with_listener.is_being_held = true
			currently_interacting_with_listener.hold_for(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var interactable_body = get_interactable_body()
		if interactable_body:
			interact_with_body(interactable_body)
	if event.is_action_released("interact") && currently_interacting_with_body != null:
		clear_currently_interacting()
	if event.is_action_released("delete (debug)") && held_item:
		held_item.queue_free()
		held_item = null
	if event.is_action_pressed("pick_up"):
		var interactable_body = get_interactable_body()
		if !interactable_body:
			return
		if held_item:
			put_down(interactable_body)
		else:
			pick_up(interactable_body)

func get_interactable_body() -> Node3D:
	var interactable_bodies: Array[Node3D] = interactable_area.get_overlapping_bodies()
	if self in interactable_bodies:
		interactable_bodies.erase(self)
	if interactable_bodies.size() == 1:
		return interactable_bodies[0]
	var closest_body: Node3D
	for body in interactable_bodies:
		if !closest_body:
			closest_body = body
			continue
		if global_position.distance_to(body.global_position) < global_position.distance_to(closest_body.global_position):
			closest_body = body
	return closest_body

func _on_body_entered_interactable_area(body: Node3D):
	if body == self: return

func _on_body_exited_interactable_area(body: Node3D):
	if body == self: return
	if body == currently_interacting_with_body:
		clear_currently_interacting()

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

func pick_up(item):
	# check if we're already holding something
	# TODO: might need to rework this if i implement the ability to hold multiple things or have portable storages
	if held_item:
		return [held_item, false]
	var item_to_pick_up
	# if we're picking up from a provider, we need to see what we are picking up
	if item.has_method("get_item_to_pick_up"):
		item_to_pick_up = item.get_item_to_pick_up(self)
	# if not, check if the thing we're trying to pick up can be picked up
	elif item.has_method("pick_up"):
		item_to_pick_up = item
	# if not, we can't pick this up
	else:
		return [held_item, false]
	# check if the thing we're trying to pick up is Node3D or PackedScene
	if !item_to_pick_up is Node3D and !item_to_pick_up is PackedScene:
		return [held_item, false]
	# now we know that the thing we're trying to pick up can be picked up
	var item_node: Node3D
	# if the thing we're trying to pick up is a scene we need to instantiate it
	if item_to_pick_up is PackedScene:
		item_node = item_to_pick_up.instantiate()
		item_node.position = Vector3.ZERO
		item_node.owner = null
		pivot.add_child(item_node)
		item_node.translate(Vector3(0,1,1))
	# if it's a node, we can just pick up this instance
	elif item_to_pick_up is Node3D:
		item_node = item_to_pick_up
		item_node.position = Vector3.ZERO
		if item_node.get_parent():
			item_node.get_parent().remove_child(item_node)
		pivot.add_child(item_node)
		item_node.translate(Vector3(0,1,1))
	held_item = item_node
	# if the item we picked up has an on_pick_up() function, trigger it
	if item.has_method("on_pick_up"):
		item.on_pick_up(self, [held_item, true])
	return [item_node, true]

func put_down(body_to_put_down_on: Node3D):
	if body_to_put_down_on.has_method("put_down_on"):
		var put_down_on_response: bool = body_to_put_down_on.put_down_on(held_item, self)
		if !put_down_on_response:
			return null
	else: return null
	pivot.remove_child(held_item)
	body_to_put_down_on.add_child(held_item)
	if body_to_put_down_on.has_method("get_aabb"):
		var aabb: AABB = body_to_put_down_on.get_aabb()
		held_item.position = Vector3(0,aabb.size.y,0)
	var tempheld_item = held_item
	if held_item.has_method("on_put_down"):
		held_item.on_put_down(body_to_put_down_on)
	held_item = null
	return tempheld_item

func clear_held_item():
	held_item.queue_free()
	held_item = null
