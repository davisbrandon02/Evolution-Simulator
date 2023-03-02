class_name Prey
extends CharacterBody2D

var speed = 400
var turnStrength = .035
var visionCone = 180
var dirTolerance: float = 20

var hunger: int = 1000
var maxHunger: int = 2000

# Wander
var desiredDir: Vector2 = Vector2(randf_range(-1,1), randf_range(-1,1))
var wanderDirChangeTime: float = 3

enum STATE {
	WANDER,
	FORAGE
}
var state: STATE = STATE.WANDER

var check = false

func _ready():
	$WanderTimer.wait_time = wanderDirChangeTime
	rotation_degrees = randf_range(-180, 180)

func _physics_process(delta):
	hunger -= 1 * settings.simulationSpeed
	if hunger < 0:
		queue_free()
	
	keepInBounds()
	
	match state:
		STATE.WANDER:
			$WanderTimer.start()
			var angleToDesiredDir = rad_to_deg(desiredDir.angle())
			
			var leftBoundary = angleToDesiredDir - dirTolerance / 2
			var rightBoundary = angleToDesiredDir + dirTolerance / 2
			
			if (rotation_degrees > leftBoundary and rotation_degrees < rightBoundary):
				pass
			else:
				if rotation_degrees < leftBoundary:
					rotate(turnStrength)
				if rotation_degrees > rightBoundary:	
					rotate(-turnStrength)
		
		STATE.FORAGE:
			$WanderTimer.stop()
			
			var nearestFood = null
			
			var foods = $SightArea.get_overlapping_bodies()
			for food in foods:
				if food == self:
					continue
				if food.is_in_group('prey'):
					continue
				if nearestFood == null or position.distance_to(food.position) < position.distance_to(nearestFood.position):
					nearestFood = food
			
			if nearestFood == null:
				state = STATE.WANDER
				return
			
			var fp = nearestFood.position
			var p = position
			var foodDir = (nearestFood.position - position).normalized()
			
			var angleToFood = rad_to_deg(foodDir.angle())
			var leftBoundary = angleToFood - dirTolerance / 2
			var rightBoundary = angleToFood + dirTolerance / 2
			
			if (rotation_degrees > leftBoundary and rotation_degrees < rightBoundary):
				pass
			else:
				if rotation_degrees < leftBoundary:
					rotate(turnStrength * settings.simulationSpeed)
				if rotation_degrees > rightBoundary:	
					rotate(-turnStrength * settings.simulationSpeed)

	velocity = Vector2(1,0).rotated(rotation) * (speed * settings.simulationSpeed)
	move_and_slide()

func keepInBounds():
	if position.x < 0:
		position = Vector2(settings.size.x, position.y)
	if position.x > settings.size.x:
		position = Vector2(0, position.y)
	if position.y < 0:
		position = Vector2(position.x, settings.size.y)
	if position.y > settings.size.x:
		position = Vector2(position.x, 0)

func _on_wander_timer_timeout():
	desiredDir = Vector2(randf_range(-1,1), randf_range(-1,1))

func _on_sight_area_body_entered(body):
	if body.is_in_group('food'):
		if state == STATE.WANDER:
			state = STATE.FORAGE

func eat(food):
	food.queue_free()
	hunger += settings.foodAmount
	if hunger >= maxHunger:
		hunger = maxHunger / 2
		split()

var preyNode = preload("res://prey.tscn")
func split():
	var preyInstance = preyNode.instantiate()
	preyInstance.position = position
	get_parent().add_child(preyInstance)
