extends Node2D

export var skillSelctionAmount : int
export var spawnTime : float
export var spawnCap : int
export var skillSelection : PackedScene;
export var point : PackedScene
export var enemy1 : PackedScene

onready var player = $MC as Player;
onready var spawnTimer = $SpawnTimer as Timer;

onready var LvlLabel = $CanvasLayer/UI/XP/LvlLabel as Label;
onready var XPBar = $CanvasLayer/UI/XP/XPBar as TextureProgress;
onready var HPBar = $CanvasLayer/UI/HP/HPBar as TextureProgress;
onready var AMMOBar = $CanvasLayer/UI/AMMO/AMMOBar as TextureProgress;


onready var pauseMenu = $CanvasLayer/UI/PauseMenu as Control;

onready var btnBox = $CanvasLayer/UI/PauseMenu/MenuButtons as VBoxContainer;
onready var resumeBtn = $CanvasLayer/UI/PauseMenu/MenuButtons/Resume as Button;
onready var quitBtn = $CanvasLayer/UI/PauseMenu/MenuButtons/Quit as Button;

onready var skillBox = $CanvasLayer/UI/PauseMenu/SkillPanel/SkillSelect as VBoxContainer;
onready var skillPanel = $CanvasLayer/UI/PauseMenu/SkillPanel as Panel;

var skillDebt : int = 0
var enemyCount : int = 0;

func skillPool():
	return [
	"Mobility: movement speed + %f" % ((player.speed*1.04+4)-player.speed), #0
	"Reaction: attack speed + %f" % ((player.weapon.attackSpeed*1.05+0.05)-player.weapon.attackSpeed), #1
	("Babushkability: crit chance + %f" % ((player.weapon.critChance*1.04+1.4)-player.weapon.critChance))+"%", #2
	"Kindness: health + %f" % ((player.maxHealthPoints*1.02+2)-player.maxHealthPoints), #3
	"Cooking: capacity + %f" % (ceil(player.weapon.maxAmmo*1.015+0.5)-player.weapon.maxAmmo), #4
	("Saltiness: crit damage + %f" % ((player.weapon.critDamgeMultiplier *1.10+5)-player.weapon.critDamgeMultiplier))+"%", #5
	"Flavor: damage + %f" % ((player.weapon.damage*1.04+4)-player.weapon.damage), #6
	"Stirring: reload speed + %f" % ((player.weapon.reloadSpeed*1.10+0.10)-player.weapon.reloadSpeed) #7
];

func _ready():
	
	spawnTimer.connect("timeout",self,"spawnWave");
	spawnTimer.wait_time = spawnTime;
	
	resumeBtn.connect("pressed",self,"resumeGame");
	quitBtn.connect("pressed",self,"quitGame");
	
	player.connect("levelUp",self,"levelUp")
	player.connect("XPupdate",self,"XPupdate");
	player.connect("HPupdate",self,"HPupdate");
	player.weapon.connect("AMMOupdate",self,"AMMOupdate");
	
	LvlLabel.text = "Lvl. 0";
	
	XPBar.max_value = player.XPtoLevel(1);
	XPBar.value = 0;
	XPBar.hint_tooltip = str(XPBar.value)+"/"+str(XPBar.max_value);
	
	HPBar.max_value = player.maxHealthPoints;
	HPBar.value = HPBar.max_value;
	HPBar.hint_tooltip = str(HPBar.value)+"/"+str(HPBar.max_value);
	
	AMMOBar.max_value = player.weapon.maxAmmo;
	AMMOBar.value = AMMOBar.max_value;
	AMMOBar.hint_tooltip = str(AMMOBar.value)+"/"+str(AMMOBar.max_value);
	
	spawnWave();

func HPupdate(hp):
	HPBar.value = hp;
	HPBar.hint_tooltip = str(hp)+"/"+str(HPBar.max_value);

func AMMOupdate(ammo):
	AMMOBar.value = ammo;
	AMMOBar.hint_tooltip = str(ammo)+"/"+str(AMMOBar.max_value);

func XPupdate(xp):
	XPBar.value = xp;
	XPBar.hint_tooltip = str(xp)+"/"+str(XPBar.max_value);

func levelUp(lvl):
	XPBar.max_value = player.XPtoLevel(lvl+1);
	LvlLabel.text = "Lvl. %d" % lvl;
	skillDebt += 1;

func spawnWave():
	spawn((player.global_position) + Vector2(1024,0).rotated(rand_range(-TAU,TAU)));

func spawn(pos):
	if enemyCount >= spawnCap: return;
	var E = enemy1.instance() as Enemy;
	E.connect("death",self,"enemyDied",[1]);
	E.global_position = pos
	E.target = player;
	add_child(E);
	enemyCount += 1

func enemyDied(pos, n):
	enemyCount -= 1;
	if randi()%10 == 0: n *= 2;
	for i in range(0,n):
		var P = point.instance() as Point;
		P.target = player;
		P.global_position = pos + Vector2(rand_range(-20,20),rand_range(-20,20));
		P.connect("collected",player,"addXP",[1]);
		add_child(P);

func skillSelect():
	pauseMenu.visible = true;
	btnBox.visible = false;
	skillPanel.visible = true;
	
	for ch in skillBox.get_children():
		ch.queue_free();
	
	var indecies = []
	
	for i in range(0,skillSelctionAmount):
		var S = skillSelection.instance() as Button;
		var idx = 0
		while true:
			idx = randi() % len(skillPool());
			if not (idx in indecies): break; # looking for a unique one
		indecies.append(idx);
		S.text = skillPool()[idx];
		S.connect("pressed",self,"skillSelected", [idx]);
		skillBox.add_child(S);

func skillSelected(id):
	skillDebt -= 1;
	skillPanel.visible = false;
	btnBox.visible = true;
	pauseMenu.visible = false;
	
	match (id):
		0: #movement speed +4%
			player.speed = player.speed*1.04 + 4
			player.sprite.speed_scale *= 1.04;
		1: #attack speed +5%
			player.weapon.attackSpeed = player.weapon.attackSpeed * 1.05 + 0.05
		2: #crit chance +4%
			player.weapon.critChance = player.weapon.critChance*1.04+1.4;
		3: #health +2
			player.maxHealthPoints = player.maxHealthPoints*1.02 + 2;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints = player.healthPoints*1.02 + 2;
		4: #capacity +1
			player.weapon.maxAmmo = ceil(player.weapon.maxAmmo*1.015+0.5);
			AMMOBar.max_value = player.weapon.maxAmmo;
		5: #crit damage +10%
			player.weapon.critDamgeMultiplier = (player.weapon.critDamgeMultiplier *1.10+0.05);
		6: #damage +4%
			player.weapon.damage = player.weapon.damage * 1.04 + 4;
		7: #reload speed +10%
			player.weapon.reloadSpeed = player.weapon.reloadSpeed * 1.10 + 0.10;

func _physics_process(_delta):
	get_tree().paused = pauseMenu.visible; # idk if this is optimal
	if skillDebt > 0 and not skillPanel.visible:
		skillSelect();
	if Input.is_action_just_pressed("pause") and skillDebt == 0:
		pauseMenu.visible = not pauseMenu.visible

func resumeGame():
	pauseMenu.visible = false;

func quitGame():
	get_tree().quit();
