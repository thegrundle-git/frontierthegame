extends Node


var current_survivor : Survivor
var survivor_data : SurvivorData

var game_ui

func _ready():

	print("GameManager loaded")
	print(FrontierInventory)
	start_new_game()


func start_new_game():

	survivor_data = load("res://resources/characters/first_survivor.tres")

	print("New survivor:")
	print(survivor_data.display_name)


	var survivor_scene = load("res://scenes/characters/Survivor.tscn")

	current_survivor = survivor_scene.instantiate()

	current_survivor.initialize(survivor_data)



func search_area():

	var search = SearchAction.new()

	search.perform(current_survivor)
