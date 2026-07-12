extends Resource
class_name ItemData

@export var id : String = ""
@export var display_name : String = ""

@export_multiline
var description : String = ""

@export var category : String

@export var weight : float = 0.0

@export var stack_size : int = 99

@export var icon : Texture2D

@export var tags : Array[String] = []
