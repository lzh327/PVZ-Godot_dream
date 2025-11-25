extends Zombie000Base
class_name Zombie017Balloon

@export_group("动画状态")
@export var is_pop:=false

func ready_norm():
	super()
	hurt_box_component.position.y -= 20

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	hp_component.signal_armor1_death.connect(balloon_pop)
	attack_component.disable_component(ComponentNormBase.E_IsEnableFactor.Balloon)

## 气球破裂
func balloon_pop():
	if not is_death:
		is_pop = true
		hurt_box_component.position.y += 20
		move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAnimGap)
		move_component.update_move_mode(MoveComponent.E_MoveMode.Ground)
		curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
		SoundManager.play_character_SFX(&"balloon_pop")
		if curr_zombie_row_type == Global.ZombieRowType.Pool:
			character_death_disappear()

## 动画调用 气球破裂结束落地,可以移动
func balloon_pop_end():
	move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsAnimGap)
	attack_component.enable_component(ComponentNormBase.E_IsEnableFactor.Balloon)

## 被三叶草吹走
func be_blow_away():
	move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsBlover)

	var tween:Tween = create_tween()
	tween.tween_property(self, ^"position:x", position.x+1000, 1)
	tween.tween_callback(character_death_disappear)
