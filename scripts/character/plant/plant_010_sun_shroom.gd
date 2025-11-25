extends Plant000Base
class_name Plant010SunShroom

@onready var create_sun_component: CreateSunComponent = $CreateSunComponent
@onready var grow_timer: Timer = $GrowTimer

## 成长所需时间
@export var time_grow:float = 100
## 小阳光价值
@export var mini_sun_value := 15
## 正常阳光价值
@export var norm_sun_value := 25

@export_group("动画状态")
## 成长
@export var is_grow:=false

func ready_norm():
	super()
	grow_timer.wait_time = time_grow
	grow_timer.start()
	create_sun_component.change_sun_value(mini_sun_value)


func ready_norm_signal_connect():
	super()
	## 角色速度改变
	signal_update_speed.connect(update_grow_speed)
	signal_update_speed.connect(create_sun_component.owner_update_speed)

## 成长结束
func _on_grow_timer_timeout() -> void:
	self.is_grow = true
	create_sun_component.change_sun_value(norm_sun_value)

## 更新成长的速度
func update_grow_speed(speed_factor:float):
	if not grow_timer.is_stopped():
		if speed_factor == 0:
			grow_timer.paused = true
		else:
			grow_timer.paused = false

			grow_timer.start(grow_timer.time_left / speed_factor)
