extends Node2D

func _ready():
	$ColorRect.size = settings.size
	$FoodTimer.wait_time = settings.foodSpawnTime / settings.simulationSpeed
	
	$PreyLabel/PreySlider.max_value = settings.maxPrey
	$FoodLabel/FoodSlider.max_value = settings.maxFood
	
	for i in settings.initialPrey:
		spawnCreature(Vector2(randf_range(0, settings.size.x), randf_range(0, settings.size.y)))

var foodNode = preload("res://food.tscn")
func _on_food_timer_timeout():
	if $Food.get_child_count() < settings.maxFood:
		var foodInstance = foodNode.instantiate()
		var randPos = Vector2(randf_range(0, settings.size.x), randf_range(0, settings.size.y))
		foodInstance.position = randPos
		$Food.add_child(foodInstance)

var preyNode = preload("res://prey.tscn")
func spawnCreature(location: Vector2):
	var newPrey = preyNode.instantiate()
	newPrey.position = location
	$Creatures.add_child(newPrey)

func _process(delta):
	var preyCount = $Creatures.get_child_count()
	var foodCount = $Food.get_child_count()
	$PreyLabel.text = 'Prey: %s' % preyCount
	$PreyLabel/PreySlider.value = preyCount
	$FoodLabel.text = 'Food: %s' % foodCount
	$FoodLabel/FoodSlider.value = foodCount
