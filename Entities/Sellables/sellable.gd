class_name Sellable extends Node3D

@export var sell_price: int

func on_put_down(body_put_down_on: Node3D):
	if body_put_down_on is SellBox:
		queue_free()
