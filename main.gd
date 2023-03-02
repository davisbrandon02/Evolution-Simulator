extends Node2D

func _ready():
	$ColorRect.size = settings.size
	$FoodTimer.wait_time = settings.foodSpawnTime / settings.simulationSpeed
	
	$PreyLabel/PreySlider.max_value = settings.maxPrey
	$FoodLabel/FoodSlider.max_value = settings.maxFood
	
	for i in settings.initialFood:
		spawnFood(Vector2(randf_range(0, settings.size.x), randf_range(0, settings.size.y)))
	
	for i in settings.initialPrey:
		spawnPrey(Vector2(randf_range(0, settings.size.x), randf_range(0, settings.size.y)))
	
	for i in settings.initialPredators:
		spawnPredator(Vector2(randf_range(0, settings.size.x), randf_range(0, settings.size.y)))

func _on_food_timer_timeout():
	spawnFood(Vector2(randf_range(0, settings.size.x), randf_range(0, settings.size.y)))

var foodNode = preload("res://food.tscn")
func spawnFood(location: Vector2):
	if $Food.get_child_count() < settings.maxFood:
		var foodInstance = foodNode.instantiate()
		foodInstance.position = location
		$Food.add_child(foodInstance)

var preyNode = preload("res://prey.tscn")
func spawnPrey(location: Vector2):
	var newPrey = preyNode.instantiate()
	newPrey.position = location
	$Prey.add_child(newPrey)
	
var predNode = preload("res://predator.tscn")
func spawnPredator(location: Vector2):
	var newPred = predNode.instantiate()
	newPred.position = location
	$Predator.add_child(newPred)

func _process(delta):
	var preyCount = $Prey.get_child_count()
	var predCount = $Predator.get_child_count()
	var foodCount = $Food.get_child_count()
	$PredatorLabel.text = 'Predator: %s' % predCount
	$PredatorLabel/PredatorSlider.value = predCount
	$PreyLabel.text = 'Prey: %s' % preyCount
	$PreyLabel/PreySlider.value = preyCount
	$FoodLabel.text = 'Food: %s' % foodCount
	$FoodLabel/FoodSlider.value = foodCount
