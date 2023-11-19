extends Node2D

export var skillSelctionAmount : int
export var spawnTime : float
export var enemyPerWave : float
export var spawnCap : int
export(int, 0, 100) var healChance : int;
export var itemEvery : int
export var healAmount : float;
export var skillSelection : PackedScene;
export var itemFrame : PackedScene;
export var point : PackedScene;
export var heal : PackedScene;
export(Array, PackedScene) var items;
export var enemy1 : PackedScene;
export var enemy2 : PackedScene;
export var enemy3 : PackedScene;
export var boss : PackedScene;
export var music : AudioStream;

onready var player = $MC as Player;
onready var spawnTimer = $SpawnTimer as Timer;
onready var difficultyTimer = $DifficultyTimer as Timer;

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


onready var itemDisplayPanel = $CanvasLayer/UI/ItemDisplay as Panel;
onready var itemNameLabel = $CanvasLayer/UI/ItemDisplay/NameLabel as Label;
onready var itemDescriptionLabel = $CanvasLayer/UI/ItemDisplay/DescLabel as Label;
onready var itemDisplayProgress = $CanvasLayer/UI/ItemDisplay/ProgressBar as ProgressBar
onready var itemDisplayTimer = $ItemDisplayTimer as Timer;


onready var inventory = $CanvasLayer/UI/PauseMenu/Inventory as Panel;

onready var itemsGrid= $CanvasLayer/UI/PauseMenu/Inventory/ScrollContainer/GridContainer as GridContainer

onready var statAtkSpeedLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/AtkSpeedLabel as Label;
onready var statCapacityLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/CapacityLabel as Label;
onready var statCritChanceLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/CritChanceLabel as Label;
onready var statCritDmgLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/CritDmgLabel as Label;
onready var statDmgLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/DmgLabel as Label;
onready var statMaxHpLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/HPLabel as Label;
onready var statInvulnTimeLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/InvulnTimeLabel as Label;
onready var statPiercingLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/PiercingLabel as Label;
onready var statProjScaleLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/ProjScaleLabel as Label;
onready var statReloadSpeedLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/ReloadSpeedLabel as Label;
onready var statSpeedLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/SpeedLabel as Label;
onready var statDefenseLabel = $CanvasLayer/UI/PauseMenu/Inventory/Stats/DefenseLabel as Label;


onready var goBtn = $CanvasLayer/UI/PauseMenu/Inventory/GoButton as Button;
onready var cheatCodeField = $CanvasLayer/UI/PauseMenu/Inventory/CheatCodeField as LineEdit;


onready var deathAnim = $DeathAnim as AnimationPlayer;
onready var retryBtn = $CanvasLayer/GameOver/Buttons/RetryButton as Button
onready var quitBtn2 = $CanvasLayer/GameOver/Buttons/QuitButton as Button;

onready var volumeSlider = $CanvasLayer/UI/PauseMenu/MenuButtons/Volume as HSlider;

onready var itemSnd = $ItemAppear as AudioStreamPlayer2D;
onready var pickUpSnd = $PickUpSnd as AudioStreamPlayer2D;
onready var levelUpSnd = $LevelUpSnd as AudioStreamPlayer;

onready var bossTimer = $BossTimer as Timer;

onready var timerLabel = $CanvasLayer/UI/TimerLabel as Label;

var skillDebt : int = 0
var enemyCount : int = 0;
var killsSinceItem : int = 0;
var itemsKept = {};
var itemFrames = {};

func skillPool():
	return [
	"Mobility: movement speed + %.2f" % ((player.speed*1.08+8)-player.speed), #0
	"Reaction: attack speed + %.2f" % ((player.weapon.attackSpeed*1.1+0.1)-player.weapon.attackSpeed), #1
	"Babushkability: crit chance + %.2f %%" % ((player.weapon.critChance*1.08+1.8)-player.weapon.critChance), #2
	"Kindness: health + %.2f" % ((player.maxHealthPoints*1.04+4)-player.maxHealthPoints), #3
	"Cooking: capacity + %.2f" % (ceil(player.weapon.maxAmmo*1.1+1)-player.weapon.maxAmmo), #4
	"Saltiness: crit damage + %.2f %%" % ((player.weapon.critDamgeMultiplier *1.2+10)-player.weapon.critDamgeMultiplier), #5
	"Flavor: damage + %.2f" % ((player.weapon.damage*1.08+8)-player.weapon.damage), #6
	"Stirring: reload speed + %.2f" % ((player.weapon.reloadSpeed*1.2+0.2)-player.weapon.reloadSpeed) #7
];

func _ready():
	randomize()
	MusicManager.stream = music
	MusicManager.play();
	itemDisplayTimer.connect("timeout",itemDisplayPanel,"hide");
	
	volumeSlider.connect("value_changed",self,"changeVolume")
	
	difficultyTimer.connect("timeout",self,"difficultyIncrease");
	bossTimer.connect("timeout",self,"spawnBoss");
	spawnTimer.connect("timeout",self,"spawnWave");
	spawnTimer.wait_time = spawnTime;
	
	goBtn.connect("pressed",self,"cheatCode");
	
	resumeBtn.connect("pressed",self,"resumeGame");
	quitBtn.connect("pressed",self,"quitGame");
	
	quitBtn2.connect("pressed",self,"quitGame");
	retryBtn.connect("pressed",self,"retryGame");
	
	player.connect("dead",self,"playerDead");
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

func playerDead():
	MusicManager.stop();
	deathAnim.play("death");

func HPupdate(hp):
	HPBar.value = hp;
	HPBar.hint_tooltip = str(round(hp))+"/"+str(round(HPBar.max_value));

func AMMOupdate(ammo):
	AMMOBar.value = ammo;
	AMMOBar.hint_tooltip = str(ammo)+"/"+str(AMMOBar.max_value);

func XPupdate(xp):
	XPBar.value = xp;
	XPBar.hint_tooltip = str(xp)+"/"+str(XPBar.max_value);

func levelUp(lvl):
	levelUpSnd.play();
	XPBar.max_value = player.XPtoLevel(lvl+1);
	LvlLabel.text = "Lvl. %d" % lvl;
	skillDebt += 1;

func difficultyIncrease():
	spawnTimer.wait_time *= 0.95;
	enemyPerWave *= 1.05;

func spawnWave():
	var pos = (player.global_position) + Vector2(1024,0).rotated(rand_range(-TAU,TAU));
	for i in range(0,100): # scary stuff
		if (abs(pos.x) < 1436.0) and (abs(pos.y) < 1052.0): 
			for j in range(0,(randi() % int(round(enemyPerWave)+1)) + 1):
				spawn(pos+Vector2(rand_range(-100,100),rand_range(-100,100)));
			break;
		pos = (player.global_position) + Vector2(1024,0).rotated(rand_range(-TAU,TAU));

func spawn(pos):
	if enemyCount >= spawnCap: return;
	var enemy = 0;
	if randi()%100 < 25:
		enemy = enemy2;
	elif randi()%100 < 15:
		enemy = enemy3;
	else:
		enemy = enemy1;
	var E = enemy.instance() as Enemy;
	var buff = (1+(float(player.level*2.0)/100.0));
	E.connect("death",self,"enemyDied");
	E.global_position = pos
	E.maxHealthPoints *= buff
	E.speed *= buff;
	E.baseDamage *= buff;
	E.target = player;
	add_child(E);
	enemyCount += 1

func spawnBoss():
	spawnTimer.wait_time *= 10.0;
	enemyPerWave /= 10.0;
	difficultyTimer.stop();
	
	var B = boss.instance() as Enemy
	B.global_position = (player.global_position) + Vector2(1024,0).rotated(rand_range(-TAU,TAU));
	B.global_position.x = clamp(B.global_position.x,-1436.0,1436.0);
	B.global_position.y = clamp(B.global_position.y,-1052.0,1052.0);
	B.target = player;
	B.connect("death",self,"bossDied")
	add_child(B);

func spawnItem(pos):
		items.shuffle()
		var I = items[0].instance() as Item;
		I.global_position = pos;
		I.connect("pickedUp",self,"addItem",[I]);
		add_child(I);
		itemSnd.global_position = pos;
		itemSnd.play();

func enemyDied(pos, n):
	enemyCount -= 1;
	killsSinceItem += 1;
	if randi()%10 == 0: n *= 2;
	if randi()%100 < (100*ease(killsSinceItem/itemEvery,2)):
		spawnItem(pos);
		killsSinceItem = 0;
	if randi()%100 < healChance*(1.0-player.healthPoints/player.maxHealthPoints):
		var H = heal.instance();
		H.target = player;
		H.global_position = pos + Vector2(rand_range(-20,20),rand_range(-20,20));
		H.connect("collected",player,"addHP",[healAmount*player.maxHealthPoints]);
		add_child(H);
	for i in range(0,n):
		var P = point.instance() as Point;
		P.target = player;
		P.global_position = pos + Vector2(rand_range(-20,20),rand_range(-20,20));
		P.connect("collected",player,"addXP",[1]);
		add_child(P);

func bossDied(pos,_n):
	spawnTimer.wait_time /= 10.0;
	enemyPerWave *= 10.0;
	difficultyTimer.start();
	bossTimer.start();

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
			player.speed = player.speed*1.08 + 8
			player.sprite.speed_scale *= 1.08;
		1: #attack speed +5%
			player.weapon.attackSpeed = player.weapon.attackSpeed * 1.1 + 0.1
		2: #crit chance +4%
			player.weapon.critChance = player.weapon.critChance*1.08+1.8;
		3: #health +2
			player.maxHealthPoints = player.maxHealthPoints*1.04 + 4;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints = player.healthPoints*1.04 + 4;
		4: #capacity +1
			player.weapon.maxAmmo = ceil(player.weapon.maxAmmo*1.1+1);
			AMMOBar.max_value = player.weapon.maxAmmo;
		5: #crit damage +10%
			player.weapon.critDamgeMultiplier = (player.weapon.critDamgeMultiplier *1.2+0.1);
		6: #damage +4%
			player.weapon.damage = player.weapon.damage * 1.08 + 8;
		7: #reload speed +10%
			player.weapon.reloadSpeed = player.weapon.reloadSpeed * 1.2 + 0.2;

func addItem(item : Item):
	pickUpSnd.global_position = player.global_position;
	pickUpSnd.play();
	itemNameLabel.text = item.itemName;
	itemDescriptionLabel.text = item.itemDescription;
	itemDisplayPanel.visible = true;
	itemDisplayTimer.start()
	
	if itemsKept.has(item.itemID):
		itemsKept[item.itemID] += 1;
	else:
		itemsKept[item.itemID] = 1;
		var F = itemFrame.instance() as Frame;
		F.itemTexture = item.get_texture();
		F.itemDescription = item.itemDescription
		itemsGrid.add_child(F);
		itemFrames[item.itemID] = F;
	itemFrames[item.itemID].set_count(itemsKept[item.itemID])
	
	match item.itemID:
		0:
			player.weapon.damage *= 1.33;
			player.speed *= 0.85;
			player.invulnerabilityTime *= 0.85;
			player.weapon.critChance *= 0.85;
			player.weapon.critDamgeMultiplier *= 0.85;
			
			player.maxHealthPoints *= 0.85;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints = player.healthPoints;
			
			player.weapon.attackSpeed *= 0.85;
			player.weapon.reloadSpeed *= 0.85;
			player.weapon.maxAmmo = ceil(player.weapon.maxAmmo * 0.85);
		1:
			player.weapon.damage *= 1.03;
			player.weapon.attackSpeed *= 1.03;
			player.weapon.reloadSpeed *= 1.03;
			player.speed *= 1.03;
		2:
			player.maxHealthPoints *= 1.05;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints = player.healthPoints * 1.05;
			
			player.speed *= 1.05;
		3:
			player.weapon.damage *= 0.94;
			player.weapon.attackSpeed *= 1.04;
			player.weapon.projectileScale *= 1.1;
		4:
			player.speed *= 0.9;
			player.invulnerabilityTime *= 1.1;
		5:
			player.maxHealthPoints *= 1.04
			HPBar.max_value = player.maxHealthPoints
			player.healthPoints *= 1.04;
			player.weapon.maxAmmo = ceil(player.weapon.maxAmmo*1.05)
			AMMOBar.max_value = player.weapon.maxAmmo;
		6:
			player.weapon.projectilePierce += 1;
		7:
			player.maxHealthPoints *= 1.14;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints *= 1.14;
		8:
			player.weapon.damage *= 1.15
			player.weapon.projectileScale *= 0.8;
		9:
			player.weapon.projectilePierce += 2;
			player.weapon.damage *= 0.9;
			player.weapon.attackSpeed *= 0.9;
		10:
			player.defense = min(player.defense+0.04, 0.8);
		11:
			player.weapon.damage *= 0.9;
			player.weapon.attackSpeed *= 1.08;
			player.weapon.reloadSpeed *= 1.08;
		12:
			player.weapon.reloadSpeed *= 1.09;
		13:
			player.weapon.critChance *= 1.07;
			player.weapon.critDamgeMultiplier *= 1.15;
		14:
			player.speed *= 1.04;
			player.weapon.attackSpeed *= 1.04;
			player.maxHealthPoints *= 0.95;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints = player.healthPoints;
		15:
			player.invulnerabilityTime *= 1.15;
			player.weapon.critDamgeMultiplier *= 0.96;
		16:
			player.maxHealthPoints *= 1.06;
			HPBar.max_value = player.maxHealthPoints;
			player.healthPoints *= 1.06;
			player.weapon.damage *= 1.06;
			player.invulnerabilityTime *= 0.88;
		17:
			player.weapon.maxAmmo = ceil(player.weapon.maxAmmo*1.3);
			AMMOBar.max_value = player.weapon.maxAmmo;
			player.weapon.projectileScale *= 1.2;
			player.weapon.attackSpeed *= 0.96;
			player.weapon.reloadSpeed *= 0.96;
			player.weapon.projectilePierce = max(1,player.weapon.projectilePierce-3);

func showInventory():
	statAtkSpeedLabel.text = "Attack Speed: %.2f" % player.weapon.attackSpeed;
	statCapacityLabel.text = "Capacity: %d" % player.weapon.maxAmmo;
	statCritChanceLabel.text = "Crit Chance: %d%%" % player.weapon.critChance;
	statCritDmgLabel.text = "Crit Damage: %.2f" % player.weapon.critDamgeMultiplier;
	statDmgLabel.text = "Damage: %.2f" % player.weapon.damage;
	statInvulnTimeLabel.text = "Invulnerability Time: %.2f s" % player.invulnerabilityTime;
	statMaxHpLabel.text = "Max Health: %.2f" % player.maxHealthPoints;
	statPiercingLabel.text = "Piercing: %d" % (player.weapon.projectilePierce-1);
	statProjScaleLabel.text = "Projectile Size: %.2f" % player.weapon.projectileScale;
	statReloadSpeedLabel.text = "Reload Speed: %.2f" % player.weapon.reloadSpeed;
	statSpeedLabel.text = "Move Speed: %.2f" % player.speed;
	statDefenseLabel.text = "Defense: %d%%" % int(player.defense*100)

func _physics_process(_delta):
	get_tree().paused = pauseMenu.visible; # idk if this is optimal
	if skillDebt > 0 and not skillPanel.visible:
		skillSelect();
	if Input.is_action_just_pressed("pause") and skillDebt == 0:
		pauseMenu.visible = not pauseMenu.visible
		inventory.visible = false;
	if Input.is_action_just_pressed("inventory"):
		if inventory.visible:
			inventory.visible = false;
			pauseMenu.visible = false;
		else:
			pauseMenu.visible = true;
			inventory.visible = true;
			showInventory();
	if itemDisplayPanel.visible:
		itemDisplayProgress.value = (100 * itemDisplayTimer.time_left/itemDisplayTimer.wait_time)
	var timeLeft = int(round(bossTimer.time_left));
	if timeLeft == 0:
		timerLabel.text = "Boss!"
	else:
		timerLabel.text = "%d:%d" % [(timeLeft / 60), (timeLeft % 60)];

func cheatCode():
	var code = cheatCodeField.text;
	cheatCodeField.text = "";
	match code:
		"givehp":
			player.healthPoints = player.maxHealthPoints;
		"crowdcontrol":
			player.weapon.projectilePierce = 0;
		"reloadsucks":
			player.weapon.reloadSpeed = INF; # 0-0
		"moreboolets":
			player.weapon.maxAmmo *= 2;
			AMMOBar.max_value = player.weapon.maxAmmo;
			player.weapon.ammo *= 2;
		"givestuff":
			spawnItem(player.global_position);
		"coolhat":
			player.coolhat.show();

func changeVolume(v):
	MusicManager.volume_db = (float(v)/12.5 -4.0)

func resumeGame():
	pauseMenu.visible = false;

func quitGame():
	get_tree().paused = false;
	get_tree().change_scene("res://Scenes/MainMenu.tscn");

func retryGame():
	get_tree().reload_current_scene();
