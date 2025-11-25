extends TextureRect
## 待选卡槽
class_name CardSlotCandidate

@onready var grid_container_plant: GridContainer = $GridContainerPlant
@onready var grid_container_zombie: GridContainer = $GridContainerZombie

## 所有的备选卡片
var all_card_candidate_containers_plant:Dictionary[int, CardCandidateContainer] = {}
var all_card_candidate_containers_zombie:Dictionary[int, CardCandidateContainer] = {}

## 模仿者对应的卡槽父节点
@onready var all_imitater_card: Control = %AllImitaterCard
## 模仿者卡片Grid
@onready var grid_container_plant_imitater: GridContainer = $AllImitaterCard/Panel/GridContainerPlantImitater
## 所有的模仿者备选卡片
var all_card_candidate_containers_plant_imitater:Dictionary[int, CardCandidateContainer] = {}
## 模仿者卡槽背景
@onready var imitater_bg: TextureRect = $ImitaterBG
## 模仿者卡片
@onready var card_imitater: CardImitater = $ImitaterBG/CardImitater


## 每一页容量
@export var capacity_per_page := 48
## 当前页
var curr_page := 0
## 最大页植物
var max_page_plant :int
## 最大页僵尸
var max_page_zombie :int

func _ready() -> void:
	_init_card_slot_candidate_plant()
	_init_card_slot_candidate_zombie()
	_init_card_slot_candidate_imitater()
	card_imitater.signal_card_click.connect(imitater_card_slot_appear)


## 初始化生成植物待选卡槽
func _init_card_slot_candidate_plant():
	var card_selected_placeholder = grid_container_plant.get_children()
	for i:int in Global.curr_plant.size():
		## 当前植物类型对应的card
		var curr_plant_card = AllCards.all_plant_card_prefabs[Global.curr_plant[i]]
		var new_card = curr_plant_card.duplicate()
		var card_candidate_container: CardCandidateContainer = SceneRegistry.CARD_CANDIDATE_CONTAINER.instantiate()

		card_candidate_container.init_card_in_seed_chooser(new_card)
		card_selected_placeholder[curr_plant_card.card_id].add_child(card_candidate_container)
		all_card_candidate_containers_plant[curr_plant_card.card_id] = card_candidate_container

	max_page_plant = ceil(Global.curr_plant.size() / 48.0)
## 初始化生成模仿者待选卡槽
func _init_card_slot_candidate_imitater():
	var card_selected_placeholder = grid_container_plant_imitater.get_children()
	for i:int in Global.curr_plant.size():
		## 当前植物类型对应的card
		var curr_plant_card = AllCards.all_plant_card_prefabs[Global.curr_plant[i]]
		var new_card = curr_plant_card.duplicate()
		new_card.is_initater = true
		var card_candidate_container: CardCandidateContainer = SceneRegistry.CARD_CANDIDATE_CONTAINER.instantiate()

		card_candidate_container.init_card_in_seed_chooser(new_card)
		card_selected_placeholder[curr_plant_card.card_id].add_child(card_candidate_container)
		all_card_candidate_containers_plant_imitater[curr_plant_card.card_id] = card_candidate_container


## 初始化生成僵尸待选卡槽
func _init_card_slot_candidate_zombie():
	var card_selected_placeholder = grid_container_zombie.get_children()
	for i:int in Global.curr_zombie.size():
		## 当前植物类型对应的card
		var curr_zombie_card = AllCards.all_zombie_card_prefabs[Global.curr_zombie[i]]
		var new_card = curr_zombie_card.duplicate()
		var card_candidate_container: CardCandidateContainer = SceneRegistry.CARD_CANDIDATE_CONTAINER.instantiate()

		card_candidate_container.init_card_in_seed_chooser(new_card)
		card_selected_placeholder[curr_zombie_card.card_id].add_child(card_candidate_container)
		all_card_candidate_containers_zombie[curr_zombie_card.card_id] = card_candidate_container

	max_page_zombie = ceil(Global.curr_zombie.size() / 48.0)

## 上一页
func _on_last_page_button_pressed() -> void:
	change_page(-1)

## 下一页
func _on_next_page_button_pressed() -> void:
	change_page(1)

#TODO: 卡片数量多于原本卡片时
func change_page(change_num:int= 1):
	curr_page += change_num
	curr_page = posmod(curr_page, max_page_plant + max_page_zombie)

	if curr_page < max_page_plant:
		grid_container_plant.visible = true
		grid_container_zombie.visible = false
	else:
		grid_container_plant.visible = false
		grid_container_zombie.visible = true

## 模仿者卡槽出现
func imitater_card_slot_appear():
	all_imitater_card.visible = true

## 模仿者卡槽隐藏
func imitater_card_slot_disappear():
	all_imitater_card.visible = false

## 模仿者卡片被选中时
func imitater_be_choosed() -> void:
	imitater_card_slot_disappear()
	card_imitater.imitater_card_be_choosed()

## 模仿者卡片被选中取消时
func imitater_be_choosed_cancel() -> void:
	card_imitater.imitater_card_be_choosed_cancal()


