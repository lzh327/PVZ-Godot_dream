extends Control
class_name ChooseLevel

## 用于生成关卡 ID 的计数
var next_level_number: int = 1

@onready var all_page: Control = $AllPage
@onready var label_page: Label = get_node_or_null("LabelPage")
## 游戏模式,用于管理关卡存档
@export var game_mode:String

var all_pages : Array[GridContainer]
@export var curr_page := 0

func _ready() -> void:
	for page in all_page.get_children():
		all_pages.append(page)
		page.visible = false
		for node in page.get_children():
			## 如果是选关按钮
			if node is ChooseLevelButton:
				node.signal_choose_level_button.connect(_on_choose_level_button)
				node.level_id = generate_level_id()
				node.update_curr_level_button_state(Global.curr_all_level_state_data.get(game_mode + "_" + node.level_id, {}))

	print("当前页面关卡数量:", next_level_number - 1)
	if curr_page > all_pages.size():
		curr_page = 0
	all_pages[curr_page].visible = true
	if is_instance_valid(label_page):
		_update_page(curr_page)

## 获取关卡id
func generate_level_id() -> String:
	# 用格式化字符串，让数字变成 4 位，前面补 0
	# GDScript 支持类似 C 风格字符串格式化
	var id_str = "%04d" % next_level_number  # 例如 0 -> "0000", 12 -> "0012"
	next_level_number += 1
	return id_str

func _on_choose_level_button(choose_level_button:ChooseLevelButton):
	Global.game_para = choose_level_button.curr_level_data_game_para
	## 初始化游戏数据的选关数据
	Global.game_para.init_choose_level(game_mode, choose_level_button.level_id)
	choose_level_start_game(Global.game_para.game_sences)

## 进入游戏关卡
func choose_level_start_game(game_scense:Global.MainScenes):
	get_tree().change_scene_to_file(Global.MainScenesMap[game_scense])

## 返回开始菜单
func back_start_menu():
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.StartMenu])


func _on_last_pressed() -> void:
	_update_page(curr_page - 1)

func _on_next_pressed() -> void:
	_update_page(curr_page + 1)


func _update_page(new_page:int):
	new_page = posmod(new_page, all_pages.size())
	all_pages[curr_page].visible = false
	curr_page = new_page
	all_pages[curr_page].visible = true
	label_page.text = "当前页数:" + str(curr_page + 1) + "/" + str(all_pages.size())
