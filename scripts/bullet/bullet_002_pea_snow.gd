extends BulletLinear000Base
class_name Bullet002PeaSnow

@export var time_be_decelerated :float = 3.0

## 攻击一次
func attack_once(enemy:Character000Base):
	super(enemy)
	if enemy is Zombie000Base:
		var zombie = enemy as Zombie000Base
		if zombie.hp_component.curr_hp_armor2 <= 0:
			zombie.be_ice_decelerate(time_be_decelerated)
