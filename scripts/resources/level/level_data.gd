extends Resource
class_name ResourceLevelData

#region 游戏参数枚举以及对应map
#region 游戏背景
## 游戏场景
enum GameBg{
	FrontDay,
	FrontNight,
	Pool,
	Fog,
	Roof,
}

## 背景图
var GameBgTextureMap = {
	GameBg.FrontDay: preload("res://assets/image/background/background1.jpg"),
	GameBg.FrontNight: preload("res://assets/image/background/background2.jpg"),
	GameBg.Pool: preload("res://assets/image/background/background3.jpg"),
	GameBg.Fog: preload("res://assets/image/background/background4.jpg"),
	GameBg.Roof: preload("res://assets/image/background/background5.jpg"),
}
#endregion

#region 游戏模式
enum GameMode{
	Adventure,	# 主游戏冒险模式
	MiniGame,	# 小游戏
}

## 游戏关卡枚举值
enum AdventureLevel{
	FrontDay,
	FrontNight,
	Pool,
	Fog,
	Roof,
}

## 小游戏模式
enum MiniGameLevel{
	Bowling,		# 保龄球
	HammerZombie,	# 锤僵尸
}

enum GameBGM {
	FrontDay,
	FrontNight,
	Pool,
	Fog,
	Roof,

	MiniGame,
	Boss,
}

## 出怪模式
enum E_MonsterMode{
	Null,	## 不出怪，测试使用
	Norm,	## 正常出怪模式
	HammerZombie,	## 锤僵尸出怪模式
}

## bgm
const GameBGMMap = {
	GameBGM.FrontDay: "res://assets/audio/BGM/front_day.mp3",
	GameBGM.FrontNight: "res://assets/audio/BGM/front_night.mp3",
	GameBGM.Pool: "res://assets/audio/BGM/pool.mp3",
	GameBGM.Fog: "res://assets/audio/BGM/fog.mp3",
	GameBGM.Roof: "res://assets/audio/BGM/roof.mp3",

	GameBGM.MiniGame: "res://assets/audio/BGM/mini_game.mp3",
	GameBGM.Boss: "res://assets/audio/BGM/boss.mp3",

}

#endregion

#region 卡槽
## 卡槽模式
enum E_CardMode{
	Null,
	Norm,
	ConveyorBelt,
	Coin,		## 金币卡槽(雪人du狗小游戏)
}

#endregion

#endregion

#region 选关数据,管理关卡存档
## 游戏模式
var game_mode:String = "test"
## 当前关卡标识符
var level_id:String = "test"

## 初始化选关数据
func init_choose_level(curr_game_mode:String, curr_level_id:String):
	game_mode = curr_game_mode
	level_id = curr_level_id
#endregion

#region 关卡背景
#@export var level_name:String
## 游戏场景
@export var game_sences:Global.MainScenes = Global.MainScenes.MainGameFront
## 游戏轮次:多轮游戏且自然出怪 自动更新自然出怪列表
@export var game_round:int = 1


@export_group("关卡背景参数")
## 游戏背景
@export var game_BG:GameBg = GameBg.FrontDay
## 游戏背景音乐
@export var game_BGM:GameBGM = GameBGM.FrontDay
## 是否有雾
@export var is_fog:bool = false
## 是否有雨
@export var is_rain:bool = false
## 是否为白天,控制蘑菇睡觉
@export var is_day:bool = true
## 是否天降阳光,传送带没有
@export var is_day_sun:bool = true
## 是否有小推车
@export var is_lawn_mover:bool = true
##INFO:存档更新
## 每个小推车是否存在
var is_has_all_lawn_mover:Array = []
@export_subgroup("预种植植物(从1开始,0为整行或整列)")
@export var all_pre_plant_data:Array[PrePlantResource] = []

#endregion

#region 关卡流程
@export_group("关卡流程参数")
## 开局查看展示僵尸
@export var look_show_zombie:bool = true
## 是否可以选择卡片,传送带不可选择
@export var can_choosed_card :bool = true
## 戴夫对话资源
@export var crazy_dave_dialog:CrazyDaveDialogResource
#endregion


#region 出怪参数
@export_group("出怪参数")
## 出怪模式
@export var monster_mode :E_MonsterMode = E_MonsterMode.Norm
## 是否为小僵尸模式
@export var is_mini_zombie := false
@export_subgroup("正常出怪模式")
## 出怪倍率
@export var zombie_multy := 1
## 每轮游戏出怪波次，每10波生成1旗帜
@export var max_wave := 30
##INFO:存档更新
## 当前波次,存档更新该值
var curr_wave:=-1
##INFO:存档更新
## 当前最大轮次,默认与max_wave相同, 多轮游戏存档时更新该值
var curr_max_wave := 30
## 僵尸种类刷新列表 多轮游戏且自然出怪 自动更新自然出怪列表
@export var zombie_refresh_types : Array[Global.ZombieType] = [
	Global.ZombieType.Z001Norm,			# 普通僵尸
	#Global.ZombieType.Z002Flag,			# 旗帜僵尸
	Global.ZombieType.Z003Cone,			# 路障僵尸
	Global.ZombieType.Z004PoleVaulter,	# 撑杆僵尸
	Global.ZombieType.Z005Bucket,			# 铁桶僵尸
]
## 是否有蹦极僵尸
@export var is_bungi := false
## 大波时生成的蹦极僵尸数量范围
@export var range_num_bungi:Vector2i = Vector2i(3,5)
@export_subgroup("锤僵尸出怪模式（需调整对应墓碑参数）")
## 墓碑出怪倍率
@export var zombie_multy_hammer := 1
## 锤僵尸出怪波数
@export var max_wave_hammer_zombie := 10
## 初始化僵尸速度
@export var speed_zombie_init := 1.0
## 每波僵尸速度提升
@export var speed_zombie_add := 0.15
## 僵尸速度提升最大值
@export var speed_zombie_max := 2.0

@export_subgroup("墓碑参数")
## 是否有墓碑,即墓碑是否生成僵尸
@export var is_have_tombston:= false
## 初始生成的墓碑数量
@export var init_tombstone_num := 0

#endregion

#region 卡片参数
## 当前已有的植物卡片在Global文件中
@export_group("卡片参数")
## 卡槽模式，只有Norm可以选卡
@export var card_mode : E_CardMode = E_CardMode.Norm
## 是否有种子雨
@export var is_seed_rain := false
@export_subgroup("正常卡槽参数")
## 最大卡槽数量
@export_range(1,10) var max_choosed_card_num :int = 10
## 开始阳光数量
@export var start_sun : int = 50
## 预选卡片列表、预选卡片不能在选卡时取消
@export var pre_choosed_card_list_plant:Array[Global.PlantType] = []
@export var pre_choosed_card_list_zombie:Array[Global.ZombieType] = []

#var card_type_list:Array[Global.PlantType] = [Global.PlantType.P005PotatoMine, Global.PlantType.P012GraveBuster, Global.PlantType.P015IceShroom]
@export_subgroup("传送带卡片参数")
## 可能出现的卡片和概率
@export var all_card_plant_type_probability :Dictionary[Global.PlantType, int]
@export var all_card_zombie_type_probability :Dictionary[Global.ZombieType, int]
## 按顺序出现的卡片植物
@export var card_order_plant:Dictionary[int, Global.PlantType] = {}
## 按顺序出现的卡片僵尸(若重复,则使用植物的卡片)
@export var card_order_zombie:Dictionary[int, Global.ZombieType] = {}
## 创建卡片的倍率
@export var create_new_card_speed:float = 1

@export_subgroup("种子雨卡片参数")
## 可能出现的卡片和概率
@export var all_card_plant_type_probability_seed_rain :Dictionary[Global.PlantType, int]
@export var all_card_zombie_type_probability_seed_rain :Dictionary[Global.ZombieType, int]
## 按顺序出现的卡片植物
@export var card_order_plant_seed_rain:Dictionary[int, Global.PlantType] = {}
## 按顺序出现的卡片僵尸(若重复,则使用植物的卡片)
@export var card_order_zombie_seed_rain:Dictionary[int, Global.ZombieType] = {}



@export_subgroup("种植参数")
## 柱子模式
@export var is_mode_column := false
## 是否有铲子
@export var is_shovel := true
#endregion

#region 迷你游戏物品参数
@export_group("游戏物品参数")
@export_subgroup("保龄球红线")
@export var is_bowling_stripe := false
## 第几列植物格子之后(0开始)
@export var plant_cell_col_j:int = 2
@export var plant_cell_can_use :Dictionary[String, bool] = {
	"left_can_plant": true,
	"right_can_plant": true,
	"left_can_zombie": true,
	"right_can_zombie": true,
}

@export_subgroup("锤子")
@export var is_hammer := false
#endregion

## 存档之前的原始数据,如果因为存档改变, 删除存档后重新修复回来
var ori_data_on_save_data_update :Dictionary = {}
## 存档数据
var save_game_data_main_game:ResourceSaveGameMainGame
## 游戏开始会根据参数初始化一些硬性的参数
"""
卡槽模式:
	正常模式:
		无
	传送带模式:
		禁止选卡,禁止天降阳光
预选卡:
	使用 0 补全预选卡,方便后续操作
出怪参数:
	正常模式:
		出怪列表禁止: 011鸭子僵尸 021蹦极僵尸 025小鬼僵尸
"""
func init_para():
	curr_max_wave = max_wave
	match card_mode:
		E_CardMode.Norm:
			pass
		E_CardMode.ConveyorBelt:
			can_choosed_card = false
			is_day_sun = false

	## 补全预选卡
	if pre_choosed_card_list_plant.size() < max_choosed_card_num:
		GlobalUtils.pad_array(pre_choosed_card_list_plant, max_choosed_card_num, 0)
	if pre_choosed_card_list_zombie.size() < max_choosed_card_num:
		GlobalUtils.pad_array(pre_choosed_card_list_zombie, max_choosed_card_num, 0)
	print("预选卡植物:", pre_choosed_card_list_plant)
	print("预选卡僵尸:", pre_choosed_card_list_zombie)

	## 出怪参数判断是否正确
	if monster_mode == E_MonsterMode.Norm:
		## 更新当前场景可以自然刷新的列表
		can_refresh_zombie_types = get_can_refresh_zombie_types(game_sences)
		if game_round != 1:
			## 多轮游戏获取第一轮出怪列表
			update_multi_round_zombie_refresh_types(1)
		zombie_refresh_types = filter_invalid_zombie_refresh_types(zombie_refresh_types, can_refresh_zombie_types)

	## 多轮游戏 存档
	if game_round != 1:
		print("更新多轮游戏存档数据")
		update_data_with_save_game_data()

## 更新数据 (存档相关)
func update_data_with_save_game_data():
	var path = get_save_game_path()
	if ResourceLoader.exists(path):
		var res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if res is ResourceSaveGameMainGame:
			save_game_data_main_game = res
			print("加载关卡数据存档成功：", path)
		else:
			push_error("加载的资源类型不对: “%s” 不是 ResourceSaveGameMainGame" % path)
			save_game_data_main_game = null
	else:
		print("关卡数据存档不存在：", path)
		save_game_data_main_game = null

	## 存在存档文件
	if save_game_data_main_game != null:
		## 保存原始数据
		ori_data_on_save_data_update["all_pre_plant_data"] = all_pre_plant_data
		ori_data_on_save_data_update["curr_max_wave"] = curr_max_wave
		ori_data_on_save_data_update["curr_wave"] = curr_wave
		ori_data_on_save_data_update["is_has_all_lawn_mover"] = is_has_all_lawn_mover

		## 清空预种植植物
		all_pre_plant_data = []
		curr_max_wave = save_game_data_main_game.curr_max_wave
		curr_wave = save_game_data_main_game.curr_wave
		is_has_all_lawn_mover = save_game_data_main_game.lawn_mover_manager_data.get("is_has_all_lawn_mover", [])

	## 没有存档文件,有原始数据,将原始数据覆盖当前值
	else:
		if not ori_data_on_save_data_update.is_empty():
			## 清空预种植植物
			all_pre_plant_data = ori_data_on_save_data_update["all_pre_plant_data"]
			curr_max_wave = ori_data_on_save_data_update["curr_max_wave"]
			curr_wave = ori_data_on_save_data_update["curr_wave"]
			is_has_all_lawn_mover = ori_data_on_save_data_update["is_has_all_lawn_mover"]

			ori_data_on_save_data_update.clear()

## 删除存档
func delete_game_data():
	save_game_data_main_game = null
	var path = get_save_game_path()

	if ResourceLoader.exists(path):
		var err = DirAccess.remove_absolute(path)
		if err == OK:
			print("删除存档成功：", path)
			return true
		else:
			push_error("删除存档失败: %s 错误码 %d" % [path, err])
			return false

#region 自然刷怪过滤
## 当前场景可以刷新的僵尸
var can_refresh_zombie_types:Array[Global.ZombieType] = []

## 蹦极僵尸可以选择,选择后自动更新删除,修改is_bungi值
## 不能自然刷怪出现的僵尸类型(null, 旗帜, 鸭子, 伴舞, 小鬼, 滑雪单人)
var no_can_refresh_zombie_types:Array[Global.ZombieType] = [
	Global.ZombieType.Null,
	Global.ZombieType.Z002Flag,
	Global.ZombieType.Z011Duckytube,
	Global.ZombieType.Z010Dancer,
	Global.ZombieType.Z025Imp,
	Global.ZombieType.Z1001BobsledSingle,
]

## 获取当前场景可以刷新的僵尸
func get_can_refresh_zombie_types(curr_game_sences:Global.MainScenes) -> Array[Global.ZombieType]:
	## 场景的僵尸行类型
	var zombie_row_type_with_scene:Global.ZombieRowType = Global.ZombieRowTypewithMainScenesMap[curr_game_sences]
	var curr_can_refresh_zombie_types:Array[Global.ZombieType] = []
	for zombie_type in Global.ZombieType.values():
		## 僵尸类型不能刷新
		if no_can_refresh_zombie_types.has(zombie_type):
			continue

		## 满足当前场景的僵尸行类型
		if zombie_row_type_with_scene == Global.ZombieRowType.Both:
			curr_can_refresh_zombie_types.append(zombie_type)
		else:
			var zombie_row_type:Global.ZombieRowType = Global.get_zombie_info(zombie_type, Global.ZombieInfoAttribute.ZombieRowType)
			if zombie_row_type == Global.ZombieRowType.Both:
				curr_can_refresh_zombie_types.append(zombie_type)
			elif zombie_row_type == zombie_row_type_with_scene:
				curr_can_refresh_zombie_types.append(zombie_type)

	return curr_can_refresh_zombie_types


## 过滤错误出怪僵尸
func filter_invalid_zombie_refresh_types(zombie_types:Array[Global.ZombieType], curr_can_refresh_zombie_types:Array[Global.ZombieType] ):
	var is_err:=false
	for i in range(zombie_types.size()-1, -1, -1):
		if not curr_can_refresh_zombie_types.has(zombie_types[i]):
			print("warning: 出怪刷新列表中", \
				Global.get_zombie_info(zombie_types[i], Global.ZombieInfoAttribute.ZombieName), \
				"不在当前场景可以自然刷怪列表"
			)
			zombie_types.remove_at(i)
			is_err = true
			continue
		if zombie_types[i] == Global.ZombieType.Z021Bungi:
			print("warning: 出怪刷新列表禁止使用 Z021Bungi ,已修改为选择 is_bungi 参数")
			is_bungi = true
			zombie_types.remove_at(i)
			is_err = true
			continue

	if is_err:
		print("将上述出怪刷新列表错误僵尸删除")

	return zombie_types

#endregion

#region 多轮(无尽)出怪
## 多轮出怪获取出怪列表
func update_multi_round_zombie_refresh_types(curr_round:int=1) -> void:
	is_bungi = false
	zombie_refresh_types = []
	# 第一次选卡 (curr_round == 1) 的 “固定三种”：普僵 + 路障 + 铁桶
	if curr_round == 1:
		zombie_refresh_types.append(Global.ZombieType.Z001Norm)
		zombie_refresh_types.append(Global.ZombieType.Z003Cone)
		zombie_refresh_types.append(Global.ZombieType.Z005Bucket)
	else:
		var can_refresh_zombie_types_copy = can_refresh_zombie_types.duplicate(true)
		zombie_refresh_types.append(Global.ZombieType.Z001Norm)
		can_refresh_zombie_types_copy.erase(Global.ZombieType.Z001Norm)
		# 第二种：80% 路障 (Cone)，20% 报纸 (Paper)
		var prob = randf()
		if prob < 0.8:
			zombie_refresh_types.append(Global.ZombieType.Z003Cone)
			can_refresh_zombie_types_copy.erase(Global.ZombieType.Z003Cone)
		else:
			zombie_refresh_types.append(Global.ZombieType.Z006Paper)
			can_refresh_zombie_types_copy.erase(Global.ZombieType.Z006Paper)
		## 第二轮之后可能刷新僵尸(min(轮次*2,8)+2)个
		for i in range(min(curr_round * 2, 8)):
			var zombie_type_choose = can_refresh_zombie_types_copy.pick_random()
			zombie_refresh_types.append(zombie_type_choose)
			can_refresh_zombie_types_copy.erase(zombie_type_choose)

			if zombie_type_choose == Global.ZombieType.Z021Bungi:
				print("warning: 出怪刷新列表禁止使用 Z021Bungi ,已修改为选择 is_bungi 参数")
				is_bungi = true
				zombie_refresh_types.erase(zombie_type_choose)

			if can_refresh_zombie_types_copy.is_empty():
				break

	print("当前轮次", curr_round,"可能刷新的僵尸类型有:")
	for zombie_type in zombie_refresh_types:
		print(Global.get_zombie_info(zombie_type, Global.ZombieInfoAttribute.ZombieName))


#endregion

#region 存档
## 读档系统只能从空白场景读档
const MainGameSaveDirName := "main_game_saves_data"

## 获取存档路径
func get_save_game_path()->String:
	## 确保存档文件存在
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(MainGameSaveDirName):
		dir.make_dir(MainGameSaveDirName)

	var save_game_file_name = game_mode + "_" + level_id
	return "user://" + MainGameSaveDirName + "/" + save_game_file_name + ".tres"



#endregion
