class_name StateMachine
extends Node

@export var initial_state : State

var current_state : State
var states := {}

func _ready():
	for node in get_children():
		if not node is State:
			continue
		states[node.name.to_lower()] = node
		node.transitioned.connect(_on_state_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if not current_state:
		return
	current_state.process(delta)

func _physics_process(delta):
	if not current_state:
		return
	current_state.physics_process(delta)

func _on_state_transition(state: State, new_state_name: String):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return
	
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
