extends Node3D

signal carregador_selecionado(carregador)

@export var tipo_arma: WeaponTypes.MagazineType
@export_range(0, 100, 1) var capacity: int 
@export_range(0.2, 0.5, 0.05) var massa_gramas: float = 0.2

var current_capacity: int

func _ready() -> void:
	current_capacity = capacity

func clicar():
	carregador_selecionado.emit(self)

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	print(body)
	clicar()

func get_tipo_carregador():
	return tipo_arma
