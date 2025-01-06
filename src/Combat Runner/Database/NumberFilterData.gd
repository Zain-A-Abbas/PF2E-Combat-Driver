extends RefCounted
class_name NumberFilterData
var text : String
var lower_bound : int
var upper_bound : int

func _init(t, l=0, u=9999):
	text = t
	lower_bound = l
	upper_bound = u
