extends CharacterBody2D

@onready var sprite = $Polygon2D
@onready var gun_pivot = $GunPivot
@onready var gun_tip = $GunPivot/GunTip
@onready var gun_bullets = preload('res://Nodes/Player/bullet_particles.tscn')

const SPEED = 400
const JUMP_VELOCITY = -600.0
const DOUBLE_JUMP_VELOCITY = -500.0
const GUN_COOLDOWN = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dashing = false
var dash_timer = 0
var can_double_jump = true
var is_jumping = false
var gravity_vector
var movement
var impulse = Vector2.ZERO
var gun_cooldown_timer = 0.0
var can_shoot = true

func _physics_process(delta):
	# Add the gravity.
	
	gravity_vector = velocity.y
	if not is_on_floor():
		gravity_vector += gravity * delta
	else:
		can_double_jump = true


	# Handle Jump
	var jump = 0
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		is_jumping = true
		sprite.scale.x = lerp(sprite.scale.x, 1.5, 0.3)
		jump = JUMP_VELOCITY

	# Handle Double Jump
	if Input.is_action_just_pressed('ui_accept') and not is_on_floor() and can_double_jump == true:
		jump = DOUBLE_JUMP_VELOCITY
		sprite.scale.x = lerp(sprite.scale.x, 1.5, 0.3)
		can_double_jump = false
		
	if sprite.scale.x != 2:
		sprite.scale.x = lerp(sprite.scale.x, 2.0, 0.3)
	if sprite.scale.y != 2:
		sprite.scale.y = lerp(sprite.scale.y, 2.0, 0.3)
	
	var direction = Input.get_axis("move_left", "move_right")
	
	
	if direction:
		if is_dashing == false:
			movement = direction * SPEED
			sprite.skew = direction * .1
	#Stops the player from moving
	elif is_dashing == false and is_on_floor():
		movement = move_toward(velocity.x, 0, 100)
		sprite.skew = lerp(sprite.skew, 0.0, 0.3)
	elif is_dashing == false:
		movement = move_toward(velocity.x, 0, 5)
		sprite.skew = lerp(sprite.skew, 0.0, 0.3)

	# Handle Dash
	if Input.is_action_just_pressed('dash'):
		is_dashing = true
		movement = direction * 1000
	
	if is_dashing:
		dash_timer += delta
		sprite.skew = direction * .5
		sprite.scale.y -= 0.1
		if dash_timer >= .2:
			is_dashing = false
			dash_timer = 0
			
	# Handle Gun
	gun_pivot.look_at(get_global_mouse_position())
	if can_shoot:
		if Input.is_action_just_pressed('shoot'):
			can_shoot = false
			var direction_to_target = global_position.direction_to(get_global_mouse_position()).normalized()
			impulse = direction_to_target * -1000
			var bullets = gun_bullets.instantiate()
			gun_tip.add_child(bullets)
	else:
		gun_cooldown_timer += delta
		if gun_cooldown_timer >= GUN_COOLDOWN:
			gun_cooldown_timer = 0
			can_shoot = true
	
	if impulse != Vector2.ZERO:
		impulse = lerp(impulse, Vector2(0, 0), .6)
		
	
	velocity.x = movement + impulse.x
	velocity.y = jump + impulse.y + gravity_vector
	
	move_and_slide()

		
func _on_ground_detection_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if is_jumping == true:
		is_jumping = false
		sprite.scale.y -= 0.5
		sprite.scale.x += 0.3
