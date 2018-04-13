extends Position2D

export(NodePath) var TargetPath setget _set_target_path, _get_target_path
export(Vector2) var Offset setget _set_offset, _get_offset
export(bool) var Current setget _set_current, _get_current

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

func _set_target_path(val):
	TargetPath = val
	if not val == null:
		Target = get_node(val)
	else:
		Target = null

func _get_target_path():
	return TargetPath

func _set_offset(val):
	Offset = val
	if $Camera_Offset != null:
		$Camera_Offset.position = Offset

func _get_offset():
	return Offset

func _set_current(val):
	if $Camera_Offset/Camera2D != null:
		Current = val
		$Camera_Offset/Camera2D.current = val

func _get_current():
	if $Camera_Offset/Camera2D != null:
		Current = $Camera_Offset/Camera2D.current
		return $Camera_Offset/Camera2D.current
	else:
		return Current
