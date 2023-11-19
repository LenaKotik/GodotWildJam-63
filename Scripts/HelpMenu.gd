extends Control

onready var backBtn = $Button as Button

func _ready():
	backBtn.connect("pressed",self,"backToMenu");

func backToMenu():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
