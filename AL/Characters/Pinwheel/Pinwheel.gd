extends Position2D

export(float) var degrees_per_second = 72

func _ready():
	set_process(true)

func _process(delta):
	$Pivot.rotate((PI/180.0) * degrees_per_second * delta)
