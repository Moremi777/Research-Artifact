extends Node

@export var pipe_scene : PackedScene

var pipe_timer: Timer
var game_running : bool
var game_over : bool
var scroll : float
var score : int
const SCROLL_SPEED : int = 4
var screen_size : Vector2
var ground_height : int
var pipes : Array = []
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

func _ready():
	screen_size = get_viewport().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	pipe_timer = $PipeTimer
	pipe_timer.wait_time = 2
	pipe_timer.one_shot = false
	
	if not pipe_timer.is_connected("timeout", Callable(self, "_on_pipe_timer_timeout")):
		pipe_timer.timeout.connect(_on_pipe_timer_timeout)
	new_game()
	start_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	for pipe in pipes:
		if is_instance_valid(pipe):
			pipe.queue_free()
	pipes.clear()
	$Bird.reset()
	generate_pipes()  # initial pipe

func _input(event):
	if not game_over and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not game_running:
			start_game()
		elif $Bird.flying:
			$Bird.flap()
			check_top()

func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	pipe_timer.start()  # will repeat every wait_time seconds

func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		var ground_width = $Ground.get_node("Sprite2D").texture.get_width()
		if scroll > ground_width:
			scroll -= ground_width
		
		$Ground.position.x = -scroll
		
		for pipe in pipes:
			if is_instance_valid(pipe):
				pipe.position.x -= SCROLL_SPEED

func _on_pipe_timer_timeout():
	if not game_running:   # 👈 guard to prevent spawning after game over
		return
	
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + 50
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)

	# Clean up offscreen pipes
	for i in range(pipes.size() - 1, -1, -1):
		var p = pipes[i]
		if is_instance_valid(p) and p.position.x < -100:
			pipes.remove_at(i)
			p.queue_free()

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
	$ScoreLabel.text = "SCORE: " + str(score)

func check_top():
	if $Bird.position.y < 0:
		print("Bird flew too high!")
		$Bird.falling = true
		stop_game()

func stop_game():	
	print("GAME STOPPED!")
	pipe_timer.stop()
	$Bird.flying = false
	game_running = false
	game_over = true

func bird_hit():
	print("Bird hit a pipe!")
	$Bird.falling = true
	stop_game()

func _on_ground_hit():
	var ground_y = $Ground.position.y - $Ground.get_node("Sprite2D").texture.get_height() / 2
	if $Bird.position.y >= ground_y:
		print("Bird hit the ground!")
		print("Bird Y when ground hit: ", $Bird.position.y)
		$Bird.falling = false
		stop_game()
