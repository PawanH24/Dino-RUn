extends Node

#preload obstacles
var stump_scene=preload("res://Scenes/stump.tscn")
var rock_scene=preload("res://Scenes/rock.tscn")
var barrel_scene=preload("res://Scenes/barrel.tscn")
var bird_scene=preload("res://Scenes/bird.tscn")
#ease of use to randomize objects.
var obstacle_types:=[stump_scene,rock_scene,barrel_scene]
var obstacles : Array
var bird_heights :=[200,390]

#game variables
const DINO_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576,324)
var difficulty
const MAX_DIFFICULTY : int =2
var score : int
const SCORE_MODIFIER : int =10
var high_score: int
#speed variables
var speed : float
const START_SPEED : float = 5.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs #track lst obs created

func _ready():
	screen_size =get_window().size
	ground_height=$Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	#reset variables
	score=0
	show_score()
	game_running=false
	get_tree().paused=false
	difficulty =0
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#resets the nodes
	$Dino.position = DINO_START_POS
	$Dino.velocity=Vector2i(0,0)
	$Camera2D.position=CAM_START_POS
	$Ground.position=Vector2i(0,0)
	
	#reset hud and game over scnee
	$HUD.get_node("Press").show()
	$GameOver.hide()
	
# called every frame 'delta' is the time elapsed since the previoous frame
func _process(delta):
	if game_running:
		#speed up and adjsut difficulty
		speed=START_SPEED+score/SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
			
		generate_obs()
		
		#move dino and camera
		$Dino.position.x+=speed
		$Camera2D.position.x+=speed
		
		#update score
		score+=speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x*1.5:
			$Ground.position.x+=screen_size.x
			
		#remove obs off screen
		for obs in obstacles:
			if obs.position.x<($Camera2D.position.x-screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running=true
			$HUD.get_node("Press").hide()
		
func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x<score +randi_range(300,500):
		var obs_type=obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs=difficulty+1
		for i in range(randi()%max_obs+1):
			obs=obs_type.instantiate()
			var obs_height=obs.get_node("Sprite2D").texture.get_height()
			var obs_scale=obs.get_node("Sprite2D").scale
			var obs_x:int=screen_size.x+score+100+(i*100)
			var obs_y:int=screen_size.y-ground_height-(obs_height*obs_scale.y)-10
			last_obs=obs 
			add_obs(obs,obs_x,obs_y)
		# random chance to spawn bird
		if difficulty==MAX_DIFFICULTY:
			if(randi()%2)==0:
				#generate bird
				obs=bird_scene.instantiate()
				var obs_x:int=screen_size.x+score+100
				var obs_y:int = bird_heights[randi()%bird_heights.size()]
				add_obs(obs,obs_x,obs_y)
		
func add_obs(obs,x,y):
	obs.position=Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name=="Dino":
		game_over()
		
func show_score():
	$HUD.get_node("Score").text = "SCORE:"+str(score/SCORE_MODIFIER)
	
func check_high_score():
	if score>high_score:
		high_score=score
		$HUD.get_node("HighScore").text = "HIGH SCORE:"+str(score/SCORE_MODIFIER)
	
func adjust_difficulty():
	difficulty=score/SPEED_MODIFIER
	if difficulty>MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over():
	check_high_score()
	get_tree().paused=true
	game_running=false
	$GameOver.show()
