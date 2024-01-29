extends StateMachine

@onready var state_label := get_node("/root/Prototype/UILayer/PlayerMovementState")

func _on_state_transition(state: State, new_state_name: String):
	super._on_state_transition(state, new_state_name)
	state_label.text = current_state.name