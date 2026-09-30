extends Node

@onready var unlocked : bool
@onready var terminal_password : bool
@onready var has_energy : bool
@onready var has_prototype : bool
@onready var has_cabinet_key : bool
@onready var has_gloves : bool
@onready var has_cube : bool
@onready var has_fuse : bool
@onready var has_secret_key : bool
@onready var documents : Array = [false, false, false]
@onready var documents_text : Array = ["", "", ""]

var total_enemies = 7
var enemies_defeated = 0
var levels : Array = [
	{
		"unlocked" : false,
		"terminal_password": false,
		"has_prototype": false,
		"has_cabinet_key" : false,
		"has_gloves": false,
		"has_cube": false,
		"has_fuse": false,
		"has_energy": false,
		"has_secret_key": false
	}
]
var is_on_past : bool = false

func _ready() -> void:
	enemies_defeated = 0
	for level in levels:
		#var level : Dictionary = levels[0]
		for chave in level.keys():
			self.set(chave, level[chave])

func _change():
	is_on_past = !is_on_past
