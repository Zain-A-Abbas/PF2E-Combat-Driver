extends Node

var traits_tooltips_list: Array[String] = [
	"aura",
	"emotion",
	"fear",
	"mental",
	"arcane"
]

# [Name|] at the start is for the header in the tooltip menu
var traits_tooltips := {
	"aura": "Aura|An aura is an emanation that continually ebbs out from you, affecting creatures within a certain radius. Aura can also refer to the magical signature of an item or a creature with a strong alignment.",
	"emotion": "Emotion|This effect alters a creature's emotions. Effects with this trait always have the mental trait as well. Creatures with special training or that have mechanical or artificial intelligence are immune to emotion effects.",
	"fear": "Fear|Fear effects evoke the emotion of fear. Effects with this trait always have the mental and emotion traits as well.",
	"mental": "Mental|A mental effect can alter the target's mind. It has no effect on an object or a mindless creature.",
	"arcane": "Arcane|This magic comes from the arcane tradition, which is built on logic and rationality. Anything with this trait is magical."
}

var senses_tooltips_list: Array[String] = [
	"darkvision",
	"scent",
]

# [Name|] at the start is for the header in the tooltip menu
var senses_tooltips := {
	"darkvision": "Darkvision|A monster with darkvision can see perfectly well in areas of darkness and dim light, though such vision is in black and white only. Some forms of magical darkness, such as a 4th-level darkness spell, block normal darkvision. A monster with greater darkvision, however, can see through even these forms of magical darkness.",
	"scent": "Scent|Scent involves sensing creatures or objects by smell, and is usually a vague sense. The range is listed in the ability, and it functions only if the creature or object being detected emits an aroma (for instance, incorporeal creatures usually do not exude an aroma).\n\nIf a creature emits a heavy aroma or is upwind, the GM can double or even triple the range of scent abilities used to detect that creature, and the GM can reduce the range if a creature is downwind."
}
