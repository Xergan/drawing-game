extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$StaticBody2D.add_child(new_shape)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment
		
		

func disable():
	hide()
	$StaticBody2D.set_collision_layer_value(1, false)
	
func enable():
	show()
	$StaticBody2D.set_collision_layer_value(1, true)
