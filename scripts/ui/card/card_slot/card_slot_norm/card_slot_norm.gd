extends Control
## 正常卡槽
class_name CardSlotNorm

## 临时卡片存放节点，避免卡片被挡住
@onready var temporary_card: Control = $TemporaryCard
## 待选卡槽
@onready var card_slot_candidate: CardSlotCandidate = $CardSlotCandidate
## 出战卡槽节点
@onready var card_slot_battle: CardSlotBattle = $CardSlotBattle


## 初始化出战卡槽，管理器调用
func init_card_slot_norm(game_para:ResourceLevelData):
	card_slot_battle.init_card_slot_battle(game_para.max_choosed_card_num, game_para.start_sun)

	for i in card_slot_candidate.all_card_candidate_containers_plant:
		var card:Card = card_slot_candidate.all_card_candidate_containers_plant[i].card
		card.signal_card_click.connect(_on_card_click.bind(card))
	for i in card_slot_candidate.all_card_candidate_containers_zombie:
		var card:Card = card_slot_candidate.all_card_candidate_containers_zombie[i].card
		card.signal_card_click.connect(_on_card_click.bind(card))
	for i in card_slot_candidate.all_card_candidate_containers_plant_imitater:
		var card:Card = card_slot_candidate.all_card_candidate_containers_plant_imitater[i].card
		card.signal_card_click.connect(_on_imitater_card_click.bind(card))

	## 初始化预选卡
	if game_para.pre_choosed_card_list_plant or game_para.pre_choosed_card_list_zombie:
		init_pre_choosed_card(game_para.pre_choosed_card_list_plant, game_para.pre_choosed_card_list_zombie)

## 重选上次卡片
func _on_re_card_button_pressed() -> void:
	Global.load_selected_cards()
	var plant_type_selected = Global.selected_cards.get("Plant", [])
	var zombie_type_selected = Global.selected_cards.get("Zombie", [])
	for plant_type:Global.PlantType in plant_type_selected:
		if card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card.is_choosed_pre_card:
			#card_slot_candidate.all_card_candidate_containers_plant_imitater[AllCards.plant_card_ids[plant_type]].card._on_button_pressed()
			continue
		card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card._on_button_pressed()
	for zombie_type:Global.ZombieType in zombie_type_selected:
		if card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card.is_choosed_pre_card:
			continue
		card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card._on_button_pressed()

## 取消所有已选卡片
func _on_cancal_card_button_pressed() -> void:
	for i in range(card_slot_battle.curr_cards.size()-1, -1, -1):
		card_slot_battle.curr_cards[i]._on_button_pressed()

## 开始游戏按钮
func _on_texture_button_pressed() -> void:
	## 卡槽正常选卡结束开始游戏
	EventBus.push_event("card_slot_norm_start_game")
	#card_disconnect_click_in_choose()
	## 保存上次选卡
	Global.selected_cards.clear()
	Global.selected_cards["Plant"] = []
	Global.selected_cards["Zombie"] = []
	for card:Card in card_slot_battle.curr_cards:
		if card.card_plant_type == 0:
			Global.selected_cards["Zombie"].append(card.card_zombie_type)
		else:
			Global.selected_cards["Plant"].append(card.card_plant_type)
	Global.save_selected_cards()

## 初始化系统预选卡
## 从AllCards中复制一张新卡,隐藏card_slot_candidate的卡片
func init_pre_choosed_card(card_type_list:Array[Global.PlantType], card_type_list_zombie:Array[Global.ZombieType]):
	for i in card_type_list.size():
		var card:Card
		var plant_type:Global.PlantType = card_type_list[i]
		var zombie_type:Global.ZombieType = card_type_list_zombie[i]
		var character_type:Global.CharacterType = GlobalUtils.get_character_type(plant_type, zombie_type)
		match character_type:
			Global.CharacterType.Plant:
				card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card.visible = false
				card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card.is_choosed_pre_card = true
				card = AllCards.all_plant_card_prefabs[plant_type].duplicate()
			Global.CharacterType.Zombie:
				card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card.visible = false
				card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card.is_choosed_pre_card = true
				card = AllCards.all_zombie_card_prefabs[zombie_type].duplicate()
			Global.CharacterType.Null:
				continue

		card_slot_battle.curr_cards.append(card)
		pre_choosed_card(card, card_slot_battle.cards_placeholder[len(card_slot_battle.curr_cards)-1])
	## 预选卡断开鼠标点击信号
	card_disconnect_click_in_choose()

## 游戏选卡阶段时，卡片被点击
func _on_card_click(card:Card):
	## 非选卡阶段直接返回
	if Global.main_game.main_game_progress != MainGameManager.E_MainGameProgress.CHOOSE_CARD\
		and Global.main_game.main_game_progress != MainGameManager.E_MainGameProgress.RE_CHOOSE_CARD:
		return
	SoundManager.play_other_SFX("tap")
	# 如果card被选择，取消选取，后面的card向前移动
	if card.is_choosed_pre_card:
		card.is_choosed_pre_card = false
		var card_idx = card_slot_battle.curr_cards.find(card)
		card_slot_battle.curr_cards.erase(card)
		for i in range(card_idx, card_slot_battle.curr_cards.size()):
			move_card_to(card_slot_battle.curr_cards[i], card_slot_battle.cards_placeholder[i])
		move_card_to(card, card.card_candidate_container)

	## 如果没被选取，放在最后一位
	else:
		if card_slot_battle.curr_cards.size() >= card_slot_battle.cards_placeholder.size():
			SoundManager.play_other_SFX("buzzer")
			return
		else:
			card.is_choosed_pre_card = true
			card_slot_battle.curr_cards.append(card)
			move_card_to(card, card_slot_battle.cards_placeholder[card_slot_battle.curr_cards.size()-1])

## 游戏选卡阶段时，模仿者卡片被点击
func _on_imitater_card_click(card:Card):
	## 非选卡阶段直接返回
	if Global.main_game.main_game_progress != MainGameManager.E_MainGameProgress.CHOOSE_CARD\
		and Global.main_game.main_game_progress != MainGameManager.E_MainGameProgress.RE_CHOOSE_CARD:
		return
	SoundManager.play_other_SFX("tap")
	# 如果card被选择，取消选取，后面的card向前移动
	if card.is_choosed_pre_card:
		card.is_choosed_pre_card = false
		var card_idx = card_slot_battle.curr_cards.find(card)
		card_slot_battle.curr_cards.erase(card)
		for i in range(card_idx, card_slot_battle.curr_cards.size()):
			move_card_to(card_slot_battle.curr_cards[i], card_slot_battle.cards_placeholder[i])
		await move_card_to(card, card_slot_candidate.card_imitater)
		card.reparent(card.card_candidate_container, false)
		card_slot_candidate.imitater_be_choosed_cancel()

	## 如果没被选取，放在最后一位
	else:
		if card_slot_battle.curr_cards.size() >= card_slot_battle.cards_placeholder.size():
			SoundManager.play_other_SFX("buzzer")
			card_slot_candidate.imitater_card_slot_disappear()
			return
		else:
			card.is_choosed_pre_card = true
			card_slot_battle.curr_cards.append(card)
			card.reparent(card_slot_candidate.card_imitater, false)
			move_card_to(card, card_slot_battle.cards_placeholder[card_slot_battle.curr_cards.size()-1])
			card_slot_candidate.imitater_be_choosed()


## 移动card到目标点位置
func move_card_to(card:Card, target_parent):
	card.button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.reparent(temporary_card)

	var tween = create_tween()
	tween.tween_property(card, "global_position", target_parent.global_position, 0.2) # 时间可以改短点

	await tween.finished
	card.reparent(target_parent)

	card.button.mouse_filter = Control.MOUSE_FILTER_PASS

## 选卡结束后，卡片断开连接，游戏开始后修改点击信号连接
func card_disconnect_click_in_choose():
	for card in card_slot_battle.curr_cards:
		if card.signal_card_click.is_connected(_on_card_click.bind(card)):
			card.signal_card_click.disconnect(_on_card_click.bind(card))

## 系统预选卡
func pre_choosed_card(card:Card, target_parent):
	target_parent.add_child(card)
	card.position = Vector2.ZERO
	card.card_change_cool_time(0)

### 预选卡隐藏对应待选卡槽的卡片(植物)
#func disappear_card_slot_candidate_plant(plant_type):
	#card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card.visible = false
	#
### 预选卡隐藏对应待选卡槽的卡片(僵尸)
#func disappear_card_slot_candidate_zombie(zombie_type):
	#card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card.visible = false

## 移动卡槽（出现或隐藏）
func move_card_slot_candidate(is_appeal:bool):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(card_slot_candidate, "position",Vector2(0, 89.0), 0.2) # 时间可以改短点
	else:
		tween.tween_property(card_slot_candidate, "position",Vector2(0, 615.0), 0.2) # 时间可以改短点

	await tween.finished

## 移动待选卡槽（出现或隐藏）
func move_card_slot_battle(is_appeal:bool, appeal_time:= 0.2):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(card_slot_battle, "position",Vector2(0, 0), appeal_time)
	else:
		tween.tween_property(card_slot_battle, "position",Vector2(0, -100.0), appeal_time)
	await tween.finished

