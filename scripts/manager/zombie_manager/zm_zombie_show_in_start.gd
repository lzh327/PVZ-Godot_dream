extends Node
## 暂时僵尸节点
class_name ZombieShowInStart

@export_group("准备阶段展示僵尸")
## 按y轴顺序渲染
@onready var show_zombie_panel: Panel = %ShowZombiePanel
## 不按y轴顺序渲染
@onready var show_zombie_panel_2: Panel = %ShowZombiePanel2

## #关卡前展示僵尸生成默认数量范围
@export var default_show_zombie_num_range:Vector2i = Vector2i(1,4)
## 关卡前展示僵尸生成数量范围(默认不生成旗帜僵尸)
@export var special_show_zombie_num_range: Dictionary[Global.ZombieType, Vector2i] = {
	Global.ZombieType.Z002Flag : Vector2i(0,0)
}
var show_zombies_array :Array[Zombie000Base]
var show_zombie_refresh_types:Array[Global.ZombieType]

## 是否有蹦极
var is_bungi := false
## 是否为小僵尸大麻烦
var is_mini_zombie

## 初始化
func init_zombie_show_in_start(game_para:ResourceLevelData):
	self.is_mini_zombie = game_para.is_mini_zombie
	update_show_zombies_type(game_para.zombie_refresh_types, game_para.is_bungi)

func update_show_zombies_type(new_zombie_refresh_types:Array[Global.ZombieType], new_is_bungi:=false):
	self.show_zombie_refresh_types = new_zombie_refresh_types
	self.is_bungi = new_is_bungi

#region 生成关卡前展示僵尸
## 生成一个展示僵尸
func create_show_zombie(zombie_type:Global.ZombieType, parent_node:Panel) -> Zombie000Base:
	var zombie_pos :=Vector2(randf_range(0, parent_node.size.x), randf_range(0, parent_node.size.y))
	var zombie:Zombie000Base = Global.get_zombie_info(zombie_type, Global.ZombieInfoAttribute.ZombieScenes).instantiate()
	var zombie_init_para:Dictionary = {
		Zombie000Base.E_ZInitAttr.CharacterInitType:Character000Base.E_CharacterInitType.IsShow,
		Zombie000Base.E_ZInitAttr.CurrZombieRowType:Global.ZombieRowType.Land,
		Zombie000Base.E_ZInitAttr.IsMiniZombie: is_mini_zombie
	}
	zombie.init_zombie(zombie_init_para)
	parent_node.add_child(zombie)
	zombie.position = zombie_pos
	return zombie

## 生成关卡前展示僵尸
func create_prepare_show_zombies():
	for zombie_type in show_zombie_refresh_types:
		var zombie_num_range :Vector2i= special_show_zombie_num_range.get(zombie_type, default_show_zombie_num_range)
		var zombie_num = randi_range(zombie_num_range.x, zombie_num_range.y)
		for i in range(zombie_num):
			var z = create_show_zombie(zombie_type, show_zombie_panel)
			show_zombies_array.append(z)
	if is_bungi:
		var z = create_show_zombie(Global.ZombieType.Z021Bungi, show_zombie_panel_2)
		show_zombies_array.append(z)

## 删除关卡前展示僵尸
func delete_prepare_show_zombies() -> void:
	for z in show_zombies_array:
		z.queue_free()
	show_zombies_array.clear()  # 清空数组
#endregion
