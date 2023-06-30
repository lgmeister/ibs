extends Resource

class_name CHARACTER


export(String) var char_name
export(SpriteFrames) var char_image


func get_Name() -> String:
	return char_name
	
func get_Image() -> SpriteFrames:
	return char_image
