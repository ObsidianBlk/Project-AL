extends Position2D

export(NodePath) var TargetPath
export(Vector2) var Offset
export(bool) var Current

var Target = null

func _ready():
	set_physics_process(true)
	$Camera_Offset.translate(Offset)
	$Camera_Offset/Camera2D.current = Current
	if TargetPath != null:
		Target = get_node(TargetPath)
	update_facing_and_position()

func _physics_process(delta):
	update_facing_and_position()

func update_facing_and_position():
	if Target:
		position = Target.position
		if Target.get("facing"):
			rotation = Target.facing.angle()
