extends Node
class_name GlobalUtilsClass
## 全局工具脚本

#const RandomPicker = preload("random_picker.gd")
#region 工具方法

## 数字转str,每三位加逗号
func format_number_with_commas(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result

## 递归让子节点使用父节点shader材质
func node_use_parent_material(node: Node2D) -> void:
	node.use_parent_material = true
	## 遍历所有子节点
	for child in node.get_children():
		if child.is_class("Node2D"):
			node_use_parent_material(child)

## 求字典value乘积
func get_dic_product(my_dict:Dictionary) -> float:
	var product = 1.0
	for value in my_dict.values():
		product *= value
	return product

## 列表求和
func sum_arr(arr: Array[float]) -> float:
	var total = 0.0
	for n in arr:
		total += n
	return total

## 根据当前植物类型和僵尸类型获取当前是植物还是僵尸
func get_character_type(plant_type:Global.PlantType, zombie_type:Global.ZombieType):
	if plant_type == Global.PlantType.Null:
		if zombie_type == Global.ZombieType.Null:
			return Global.CharacterType.Null
		else:
			return Global.CharacterType.Zombie
	else:
		return Global.CharacterType.Plant

## 补全列表
func pad_array(arr: Array, target_size: int, pad_value = 0) -> Array:
	while arr.size() < target_size:
		arr.append(pad_value)
	return arr

## 世界坐标转屏幕坐标
func world_to_screen(global_pos : Vector2) -> Vector2:
	# pos 是 world / canvas 坐标，也就是某个 Node2D 的 global_position
	var viewport := get_viewport()
	# 获取视口变换 （画布 -> 屏幕）
	var vt : Transform2D = viewport.get_screen_transform()
	# 用 vt * pos 得到屏幕上的像素位置
	return vt * global_pos

## 创建计时器(触发一次)(角色buff[减速]使用)
func create_new_timer_once(need_node:Node, callable:Callable, wait_time:float=0):
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	if wait_time != 0:
		timer.wait_time = wait_time
	timer.timeout.connect(callable)
	need_node.add_child(timer)
	return timer
#endregion
