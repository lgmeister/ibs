extends Resource

class_name BLOCK


export(String) var block_name
export(Texture) var block_image
export(int) var block_frame = 0

export(bool) var block_passthrough = false




func get_Name() -> String:
	return block_name
	
func get_Image() -> Texture:
	return block_image
	
func get_Frame() -> int:
	return block_frame
	
func get_Passthrough() -> bool:
	return block_passthrough
