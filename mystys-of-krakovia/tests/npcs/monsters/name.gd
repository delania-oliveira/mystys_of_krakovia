extends Label3D

@export var min_scale: float = 1.0   # when really far
@export var max_scale: float = 2.0   # when really close
@export var scale_distance: float = 100.0  # distance at which label is normal size

func _process(delta):
	var cam = get_viewport().get_camera_3d()
	if not cam:
		return

	# Make it face the camera
	look_at(cam.global_position, Vector3.UP)

	# Calculate distance-based scale
	var dist = global_position.distance_to(cam.global_position)

	# Scale factor: closer = bigger, farther = smaller
	var scale_factor = clamp(dist / scale_distance, min_scale, max_scale)
	
	# Optional: invert if you want closer = bigger
	scale_factor = clamp(scale_distance / dist, min_scale, max_scale)

	scale = Vector3.ONE * scale_factor
