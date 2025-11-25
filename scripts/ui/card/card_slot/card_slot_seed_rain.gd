extends Control
class_name CardSlotSeedRain

@onready var card_random_pool: CardRandomPool = $CardRandomPool
@onready var create_new_card_timer: Timer = $CreateNewCardTimer

var curr_cards :Array[Card] = []

## 卡片范围
@export var card_area_x_range:Vector2 = Vector2(100,700)
@export var card_area_y_range:Vector2 = Vector2(100,500)
## 按顺序出现的卡片植物
@export var card_order_plant:Dictionary[int, Global.PlantType] = {}
## 按顺序出现的卡片僵尸(若重复,则使用植物的卡片)
@export var card_order_zombie:Dictionary[int, Global.ZombieType] = {}
## 创建卡片的时间
@export var card_create_cd_range:Vector2 = Vector2(3,5)
## 卡片正常存在时间
@export var card_exist_time_norm:float = 10.0
## 卡片闪烁存在时间
@export var card_exist_time_blink:float = 5.0
## 当前生成的卡片总数量
var all_num_card :int = 0

## 当前手持种子雨的卡片
var curr_seed_rain_card_in_hm:Card
## 手持管理器取消卡片
signal signal_hm_character_clear_card(card:Card)

func _ready():
	EventBus.subscribe("hm_character_clear_card", _on_hm_character_clear_card)
	EventBus.subscribe("hm_character_hand_card", _on_hm_character_hand_card)

## 管理器初始化调用
func init_card_slot_seed_rain(game_para:ResourceLevelData):
	var card_random_pool_init_para = {
		CardRandomPool.E_CardRandomPoolInitParaAttr.AllCardPlantProbability: game_para.all_card_plant_type_probability_seed_rain,
		CardRandomPool.E_CardRandomPoolInitParaAttr.AllCardZombieProbability: game_para.all_card_zombie_type_probability_seed_rain,
	}
	print("种子雨卡槽初始化随机卡片生成器")
	card_random_pool.init_card_random_pool(card_random_pool_init_para)

	self.card_order_plant = game_para.card_order_plant_seed_rain
	self.card_order_zombie = game_para.card_order_zombie_seed_rain

## 当手持管理器拿到新卡片时
func _on_hm_character_hand_card(curr_card:Card):
	curr_seed_rain_card_in_hm = curr_card

## 当手持管理器清除当前手持卡片数据时
func _on_hm_character_clear_card(curr_card:Card):
	signal_hm_character_clear_card.emit(curr_card)

func _on_create_new_card_timer_timeout() -> void:
	_create_new_card()
	create_new_card_timer.start(randf_range(card_create_cd_range.x, card_create_cd_range.y))


## 生成一张新卡片
func _create_new_card():
	var new_card_prefabs:Card
	if card_order_plant.has(all_num_card):
		new_card_prefabs = AllCards.all_plant_card_prefabs[card_order_plant[all_num_card]]
	elif card_order_zombie.has(all_num_card):
		new_card_prefabs = AllCards.all_zombie_card_prefabs[card_order_zombie[all_num_card]]
	else:
		new_card_prefabs = card_random_pool.get_random_card()
	var new_card = new_card_prefabs.duplicate()
	add_child(new_card)
	new_card.position = Vector2(randf_range(card_area_x_range.x, card_area_x_range.y),randf_range(card_area_y_range.x, card_area_y_range.y))

	seed_rain_card_update(new_card)

	curr_cards.append(new_card)
	new_card.signal_card_use_end.connect(card_use_end.bind(new_card))
	all_num_card += 1

## 种子雨卡片更新: 缓慢下落,时间限制
func seed_rain_card_update(seed_rain_card:Card):
	var tween:Tween = seed_rain_card.create_tween()
	tween.tween_property(seed_rain_card, ^"position:y", seed_rain_card.position.y+30, 1.0)

	var seed_rain_card_timer:Timer = Timer.new()
	seed_rain_card_timer.autostart = false
	seed_rain_card_timer.one_shot = true
	seed_rain_card_timer.timeout.connect(_on_seed_rain_card_timer_timeout.bind(seed_rain_card))
	seed_rain_card.add_child(seed_rain_card_timer)
	seed_rain_card_timer.start(card_exist_time_norm)

	seed_rain_card.is_seed_rain_card = true

func _on_seed_rain_card_timer_timeout(seed_rain_card:Card):
	seed_rain_card.card_blink_start()
	await get_tree().create_timer(card_exist_time_blink, false).timeout
	if curr_seed_rain_card_in_hm == seed_rain_card:
		await signal_hm_character_clear_card
	## 如果还未被上次
	if is_instance_valid(seed_rain_card):
		card_use_end(seed_rain_card)

func card_use_end(card:Card):
	if not card.is_queued_for_deletion():
		curr_cards.erase(card)
		card.queue_free()

## 开始种子雨
func start_seed_rain():
	if create_new_card_timer.paused:
		create_new_card_timer.paused = false
	else:
		create_new_card_timer.start(randf_range(card_create_cd_range.x, card_create_cd_range.y))

func pause_seed_rain():
	create_new_card_timer.paused = true

