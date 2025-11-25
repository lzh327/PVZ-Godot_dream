extends Node2D
class_name Ladder

@onready var iron_node: IronNode = $IronNode
@onready var area_2d: Area2D = $Area2D

## 梯子所属植物格子
var plant_cell:PlantCell
## 梯子所在行
var lane:int

func _ready() -> void:
	## 斜面与水平面的差值
	var diff_slope_flat:float = 0
	if is_instance_valid(plant_cell):
		diff_slope_flat = plant_cell.position.y

	if diff_slope_flat != 0:
		area_2d.position.y -= diff_slope_flat

## 初始化梯子
func init_ladder(curr_plant_cell:PlantCell):
	self.plant_cell = curr_plant_cell
	self.lane = plant_cell.row_col.x

## 梯子死亡
func ladder_death():
	plant_cell.ladder_loss()
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var zombie :Zombie000Base = area.owner
	if lane == zombie.lane and not zombie.is_ignore_ladder:
		zombie.start_climbing_ladder()
