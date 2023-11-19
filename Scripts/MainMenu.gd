extends Control

export var music : AudioStream

onready var playBtn = $Buttons/PlayButton as Button;
onready var helpBtn = $Buttons/HelpButton as Button;
onready var quitBtn = $Buttons/QuitButton as Button;

func _ready():
	MusicManager.stream = music;
	MusicManager.play();
	playBtn.connect("pressed",self,"play");
	helpBtn.connect("pressed",self,"help");
	quitBtn.connect("pressed",self,"quit");

func play():
	get_tree().change_scene("res://Scenes/Main.tscn");

func help():
	get_tree().change_scene("res://Scenes/HelpMenu.tscn")

func quit():
	get_tree().quit(0);
