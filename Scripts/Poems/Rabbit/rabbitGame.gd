extends Node

@export var pipe_scene : PackedScene

@onready var pipe_timer = $PipeTimer

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground2.get_node("Sprite2D").texture.get_height()
	new_game()
	
func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel2.text = "SCORE: " + str(score)
	pipes.clear()
	generate_pipes()
	$Bird2.reset()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird2.flying:
						$Bird2.flap()
						check_top()
		
func start_game():
	game_running = true
	$Bird2.flying = true
	$Bird2.flap()
	$PipeTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		
		if scroll >= screen_size.x:
			scroll = 0
			
		$Ground2.position.x = -scroll
		
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

func _on_pipe_timer_timeout():
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)
	
func scored():
	score += 1
	$ScoreLabel2.text = "Score: " + str(score)
	
func check_top():
	if $Bird2.position.y < 0:
		$Bird2.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$Bird2.flying = false
	game_running = false
	game_over = true

func bird_hit():
	$Bird2.falling = true
	stop_game()

func _on_ground_hit():
	$Bird2.falling = false
	stop_game()
	
func get_pipe_timer():
	return pipe_timer
