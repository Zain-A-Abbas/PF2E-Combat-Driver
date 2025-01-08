extends Object
class_name EnemyCreatorStrike

enum StrikeType {
	MELEE,
	RANGED
}

var strike_type: StrikeType = StrikeType.MELEE
var strike_name: String = ""
var strike_bonus: int = 0
var strike_damage: String = ""
var traits: PackedStringArray = []
