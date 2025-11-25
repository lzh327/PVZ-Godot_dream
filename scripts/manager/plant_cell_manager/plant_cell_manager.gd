extends Node
class_name PlantCellManager

@onready var plant_cells_root: Node2D = %PlantCellsRoot
@onready var tomb_stone_manager: TombStoneManager = $TombStoneManager

## PlantCellManager初始化
## 二维数组，保存每个植物格子节点
var all_plant_cells: Array[Array] = []
## 植物格子的行和列
var row_col:Vector2i = Vector2i.ZERO
## TombStoneManager(PlantCellManager子节点)初始化
## 生成的墓碑列表(一维)
var tombstone_list :Array[TombStone] = []
## 当前植物种植的信息[植物种类:植物数量]
var curr_plant_num:Dictionary[Global.PlantType, int]


func _ready() -> void:
	## 火爆辣椒爆炸特效
	EventBus.subscribe("jalapeno_bomb_effect", jalapeno_bomb_effect)
	## 火爆辣椒销毁道具[冰道和梯子]
	EventBus.subscribe("jalapeno_bomb_item_lane", jalapeno_bomb_item_lane)

	## 植物种植区域信号，更新植物位置列号,更新墓碑信息
	for plant_cells_row_i in plant_cells_root.get_child_count():
		## 某一行all_plant_cells
		var plant_cells_row:CanvasItem = plant_cells_root.get_child(plant_cells_row_i)
		plant_cells_row.z_index = plant_cells_row_i * 50 + 10
		var plant_cells_row_node := []
		## plant_cell是从右向左的顺序，这里从左到右
		for plant_cells_col_j in range(plant_cells_row.get_child_count() - 1, -1, -1):
			var plant_cell:PlantCell = plant_cells_row.get_child(plant_cells_col_j)
			plant_cell.row_col = Vector2(plant_cells_row_i, plant_cells_col_j)
			plant_cells_row_node.append(plant_cell)
			plant_cell.signal_plant_create.connect(update_plant_info_create)
			plant_cell.signal_plant_free.connect(update_plant_info_free)

		all_plant_cells.append(plant_cells_row_node)

	row_col = Vector2i(all_plant_cells.size(), all_plant_cells[0].size())

## plant_cell与hand_manager信号连接
func signal_connect_plant_cell_with_hand_manager(hand_manager:HandManager):
	## 植物种植区域信号
	for plant_cells_row in all_plant_cells:
		for plant_cell in plant_cells_row:
			plant_cell = plant_cell as PlantCell
			plant_cell.click_cell.connect(hand_manager._on_click_cell)
			plant_cell.cell_mouse_enter.connect(hand_manager._on_cell_mouse_enter)
			plant_cell.cell_mouse_exit.connect(hand_manager._on_cell_mouse_exit)

#region 植物信息
## 更新植物信息(创建新植物)
func update_plant_info_create(_plant_cell:PlantCell, plant_type:Global.PlantType):
	curr_plant_num[plant_type] = curr_plant_num.get(plant_type, 0) + 1
	EventBus.push_event("update_card_purple_sun_cost")

## 更新植物信息(植物死亡)
func update_plant_info_free(_plant_cell:PlantCell, plant_type:Global.PlantType):
	curr_plant_num[plant_type] -= 1
	EventBus.push_event("update_card_purple_sun_cost")
	if curr_plant_num[plant_type] < 0:
		printerr(plant_type, ":该植物类型数量小于0")
#endregion

func init_plant_cell_manager(game_para:ResourceLevelData):
	tomb_stone_manager.init_tomb_stone_manager(game_para)
	## 预种植植物数据
	var all_pre_plant_data = game_para.all_pre_plant_data
	for pre_plant_data in all_pre_plant_data:
		if pre_plant_data == null:
			printerr("关卡数据中预种植植物有空值")
			continue
		## 行或列大于当前最大值\小于0,跳过
		if pre_plant_data.plant_cell_pos.x > row_col.x or\
		pre_plant_data.plant_cell_pos.y > row_col.y or\
		pre_plant_data.plant_cell_pos.x < 0 or pre_plant_data.plant_cell_pos.y < 0:
			continue
		## 满屏铺满
		elif pre_plant_data.plant_cell_pos.x == 0 and pre_plant_data.plant_cell_pos.y == 0:
			for plant_cell_row in all_plant_cells:
				for plant_cell:PlantCell in plant_cell_row:
					plant_cell_pre_plant(plant_cell, pre_plant_data.plant_type, pre_plant_data.is_imitater_plant)
		## 某一列
		elif pre_plant_data.plant_cell_pos.x == 0 and pre_plant_data.plant_cell_pos.y != 0:
			for plant_cell_row in all_plant_cells:
				var plant_cell:PlantCell = plant_cell_row[pre_plant_data.plant_cell_pos.y-1]
				plant_cell_pre_plant(plant_cell, pre_plant_data.plant_type, pre_plant_data.is_imitater_plant)
		## 某一行
		elif pre_plant_data.plant_cell_pos.x != 0 and pre_plant_data.plant_cell_pos.y == 0:
			var plant_cell_row = all_plant_cells[pre_plant_data.plant_cell_pos.x-1]
			for plant_cell:PlantCell in plant_cell_row:
				plant_cell_pre_plant(plant_cell, pre_plant_data.plant_type, pre_plant_data.is_imitater_plant)

		## 某一个
		else:
			var plant_cell:PlantCell = all_plant_cells[pre_plant_data.plant_cell_pos.x-1][pre_plant_data.plant_cell_pos.y-1]
			plant_cell_pre_plant(plant_cell, pre_plant_data.plant_type, pre_plant_data.is_imitater_plant)

func plant_cell_pre_plant(plant_cell:PlantCell, plant_type:Global.PlantType, is_imitater:bool):
	if is_imitater:
		plant_cell.imitater_create_plant(plant_type, false)
	else:
		plant_cell.create_plant(plant_type, false, false)

func create_tombstone(new_num:int):
	tomb_stone_manager.create_tombstone(new_num)

## 火爆辣椒爆炸特效
## [lane:int]:行
func jalapeno_bomb_effect(lane:int):
	for plant_cell:PlantCell in all_plant_cells[lane]:
		var fire_new:BombEffectFire = SceneRegistry.FIRE.instantiate()
		## 修改其图层
		fire_new.z_index = lane * 50 + 40
		fire_new.z_as_relative = false

		plant_cell.add_child(fire_new)
		fire_new.global_position = plant_cell.global_position + Vector2(plant_cell.size.x / 2, plant_cell.size.y)
		fire_new.activate_bomb_effect()

func jalapeno_bomb_item_lane(lane:int):
	## 梯子
	for p_c :PlantCell in all_plant_cells[lane]:
		if is_instance_valid(p_c.ladder):
			p_c.ladder.queue_free()


## 获取有植物的植物格子 (蹦极)
func get_cell_have_plant()->Array[PlantCell]:
	var all_cell_have_plant:Array[PlantCell]
	for plant_cell_lane in all_plant_cells:
		for plant_cell:PlantCell in plant_cell_lane:
			if plant_cell.get_curr_plant_num()>0:
				all_cell_have_plant.append(plant_cell)
	return all_cell_have_plant

#region 存档
## 植物格子管理器存档
func get_save_game_data_plant_cell_manager() -> ResourceSaveGamePlantCellManager:
	var save_game_data_plant_cell_manager:ResourceSaveGamePlantCellManager = ResourceSaveGamePlantCellManager.new()

	for plant_cell_lane in all_plant_cells:
		for plant_cell:PlantCell in plant_cell_lane:
			save_game_data_plant_cell_manager.all_plant_cells_datas.append(plant_cell.get_save_game_data_plant_cell())

	save_game_data_plant_cell_manager.tomb_stone_manager_data = tomb_stone_manager.get_save_game_data_tomb_stone_manager()

	return save_game_data_plant_cell_manager

### 清除所有植物数据
#func clear_all_plant_cell_data():
	#for plant_cell_lane in all_plant_cells:
		#for plant_cell:PlantCell in plant_cell_lane:
			#plant_cell.clear_data_plant_cell()

## 植物格子管理器读档
func load_game_data_plant_cell_manager(save_game_data_plant_cell_manager:ResourceSaveGamePlantCellManager):
	#clear_all_plant_cell_data()
	### INFO: 等待两帧,queue_free()删除后
	### 若是等待一帧,一局游戏多次读档测试时稳定触发某次植物未删除,不知道为什么
	#await get_tree().process_frame
	#await get_tree().process_frame

	for save_game_data_plant_cell:ResourceSaveGamePlantCell in save_game_data_plant_cell_manager.all_plant_cells_datas:
		var plant_cell:PlantCell = all_plant_cells[save_game_data_plant_cell.row_col.x][save_game_data_plant_cell.row_col.y]
		plant_cell.load_game_data_plant_cell(save_game_data_plant_cell)

	tomb_stone_manager.load_game_data_tomb_stone_manager(save_game_data_plant_cell_manager.tomb_stone_manager_data )

#endregion
