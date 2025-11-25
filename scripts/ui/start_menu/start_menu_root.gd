extends Control
class_name StartMenuRoot

@onready var dialog: Dialog = $Dialog
@export var bgm:AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cloud/AnimationPlayer.play("Idle")
	$BG_Right/Leaf/AnimationPlayer.play("Idle")
	$AnimationPlayer.play("Idle")

	SoundManager.setup_ui_start_menu_sound(self)
	SoundManager.play_bgm(bgm)

	Global.time_scale = 1.0
	Engine.time_scale = Global.time_scale


## 花园需要浇水
var garden_need_water:=true



## 功能未实现
func _unrealized():
	dialog.appear_dialog()

## 开始游戏
func _on_menu_button_1_pressed() -> void:
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.ChooseLevel])

## 迷你游戏
func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.ChooseLevelMiniGame])


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.ChooseLevelSurvival])

#region 选项
func _on_option_button_1_pressed() -> void:
	$StartMenuOptionDialog.appear_menu()


func _on_option_button_2_pressed() -> void:
	$Dialog_Help.appear_dialog()

## 退出游戏
func _on_option_button_3_pressed() -> void:
	get_tree().quit()


func _on_full_screen_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#endregion


## 花园
func _on_item_button_1_pressed() -> void:
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.Garden])

## 图鉴
func _on_item_button_2_pressed() -> void:
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.Almanac])

