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

func initialize():
	if initial_state:
		initial_state.enter({})
		current_state = initial_state

func _process(delta):
	if not current_state:
		return
	current_state.process(delta)

func _physics_process(delta):
	if not current_state:
		return
	current_state.physics_process(delta)

func _on_state_transition(state: State, new_state_name: String, params: Dictionary = {}):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		print("State %s not found in state machine!" % new_state_name)
		return
	
	if current_state:
		current_state.exit()
	new_state.enter(params)
	current_state = new_state
