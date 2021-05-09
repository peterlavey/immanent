class_name Delay extends Node2D

var timer:Timer
var callback: String
var speed: float

func _init(callback, speed = 0.16):
	self.callback = callback
	self.speed = speed
	config_timer()
	
func config_timer()-> void:
	timer = Timer.new()
	timer.set_wait_time(speed)
	add_child(timer)

func set_speed(_speed):
	timer.set_wait_time(_speed)
	
func start()-> void:
	timer.connect("timeout", get_parent(), callback)
	timer.start()

func stop()-> void:
	timer.stop()
