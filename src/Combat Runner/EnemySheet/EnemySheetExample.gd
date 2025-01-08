extends Node

# Some explanations
'

_id and img are not yet used.
"items" is an array of every ability. The default for this with examples is below.

["allsaves"]["value"] is if you want any extra saves text, just as dragons getting +1 on all magic saves.

"imunities" is an array of dictionaries, formatted like so:
	{
		"type": "fire"
	}

"resistances" and "weaknesses" are similar:
	resistance:
	{
		"type": "fire",
		"value": 5,
		"exceptions": [string array]
	}
	weakness:
	{
		"type": "fire",
		"value": 5,
	},

"senses" is all in a single string

"otherSpeeds" holds an array of dictionaries, each formatted like so:
	{
		"type": "fly",
		"value": 40
	}
'

const DEFAULT: Dictionary = {
	"_id": "some random alphanum string",
	"img": "x.svg",
	"items": [],
	"name": "Enemy Name",
	"system": {
		"abilities": {
			"cha": {
				"mod": 0
				},
			"con": {
				"mod": 0
			},
			"dex": {
				"mod": 0
			},
			"int": {
				"mod": 0
			},
			"str": {
				"mod": 0
			},
			"wis": {
				"mod": 0
			}
		},
		"attributes": {
			"ac": {
				"details": "",
				"value": 16
			},
			"allSaves": {
				"value": ""
			},
			"hp": {
				"details": "",
				"max": 22,
				"temp": 0,
				"value": 22
			},
			"weaknesses": [],
			"resistances": [],
			"immunities": [],
			"perception": {
				"value": 6
			},
			"speed": {
				"otherSpeeds": [
				],
				"value": 25
			},
		},
		"details": {
			"alignment": {
				"value": ""
			},
			"blurb": "",
			"creatureType": "Fiend",
			"level": {
				"value": 1
			},
			"source": {
				"value": "Custom Enemy"
			}
		},
		"resources": {
			"focus": {
				"max": 1,
				"value": 1
			}
		},
		"saves": {
			"fortitude": {
				"saveDetail": "",
				"value": 0
			},
			"reflex": {
				"saveDetail": "",
				"value": 0
			},
			"will": {
				"saveDetail": "",
				"value": 0
			}
		},
		"traits": {
			"languages": {
				"value": [
					
				]
			},
			"rarity": "common",
			"senses": {
				"value": ""
			},
			"size": {
				"value": "medium"
			},
			"value": []
		}
	},
	"type": "npc"
}

const ATTACK_TEMPLATE: Dictionary = {
	"name": "Attack Name",
	"type": "melee", # "melee" does not mean actually melee.
	"system": {
		"bonus": {
			"value": 10
		},
		"damageRolls": {},
		"oneLineDamageRoll": "",
		"traits": {
			"value": []
		},
		"attackEffects": {
			"value": []
		},
	}
}

# Used for both offensive and defensive special; abilities
const ABILITY_TEMPLATE: Dictionary = {
	"name": "Ability Name",
	"type": "action", 
	"system": {
		"category": "offensive",
		"actionType": {
			"value": ""
		},
		"actions": {
			"value": ""
		},
		"description": {
			"value": ""
		},
		"traits": {
			"value": []
		},
	}
}


const SPELLCASTING_TEMPLATE: Dictionary = {
	"name": "Arcane Prepared Spells",
	"type": "spellcastingEntry",
	"system": {
		"spelldc": {
			"dc": 0,
			"value": 0
		},
		"prepared": {
			"value": ""
		},
		"tradition": {
			"value": ""
		},
	}
}

const SPELL_TEMPLATE: Dictionary = {
	"name": "Spell Name",
	"type": "spell",
	"system": {
		"level": {
			"value": 0 # Fill this out with level
		},
		"location": {
			"value": ""
		},
		"category": {
			"value": "spell"
		},
		"damageRolls": {},
		"oneLineDamageRoll": "",
		"traits": {
			"value": [] # Fill this with cantrip if spell is in 0 tier
		}
	}
}
