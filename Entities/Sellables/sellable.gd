class_name Sellable extends Node3D

@export var sell_price: int

func on_put_down():
	queue_free()
