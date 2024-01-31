class_name BuffResource
extends Resource

@export var type : BuffInfo.Type
@export var _base_amount : float
@export var _amount_per_extra_stack : float

func get_amount(stacks: int) -> float:
	return _base_amount + ((stacks - 1) * _amount_per_extra_stack)
