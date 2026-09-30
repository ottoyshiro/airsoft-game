extends Node3D

enum ModoDisparo {
	SEMI,
	AUTO
}

@export var modo_disparo: ModoDisparo = ModoDisparo.SEMI
@export var motor_rpm: float = 600.0

var pode_disparar: bool = true
var gatilho_pressionado: bool = false

@onready var muzzle = self.get_node("muzzle_ref")
@onready var animation_player: AnimationPlayer = %AnimationPlayer


@export var bullet_ref : PackedScene
@export var tipo_carregador: WeaponTypes.MagazineType
@export var hop_up_level: int = 0
@export var hop_up_step: float = 0.06
@export var min_hop_up_level: int = -10
@export var max_hop_up_level: int = 10
@export var energia_base: float = 1.49
@export var ajuste_mola: float = 0.0

var massa_municao_atual: float = 0.0
var capacidade_arma = 15
var municao_atual = 0
var hop_up: float = 0.3
var carregador_equipado = null
var balas_disparadas = 0
var player

func _process(_delta) -> void:
	if modo_disparo == ModoDisparo.AUTO and gatilho_pressionado:
		disparar_se_possivel()

func calcular_energia() -> float:
	return energia_base + ajuste_mola

func _input(event):
	if event is InputEventMouseButton and event.pressed:

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			hop_up_level = min(
				hop_up_level + 1,
				max_hop_up_level
			)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			hop_up_level = max(
				hop_up_level - 1,
				min_hop_up_level
			)

		hop_up = hop_up_level * hop_up_step

		print(
			"Hop-up nível: ",
			hop_up_level,
			" | Força: ",
			hop_up
		)
func _unhandled_input(event) -> void:

	if event.is_action_pressed("left_click"):
		gatilho_pressionado = true

		if modo_disparo == ModoDisparo.SEMI:
			disparar_se_possivel()

	elif event.is_action_released("left_click"):
		gatilho_pressionado = false

	if event.is_action_pressed("toggle_fire_mode"):
		trocar_modo_disparo()

	if event.is_action_pressed("reload"):
		recarregar()

func recarregar():

	if carregador_equipado == null:
		print("Nenhum carregador equipado!")
		return

	var espaco_disponivel = capacidade_arma - municao_atual

	if espaco_disponivel <= 0:
		print("Arma já está cheia!")
		return

	var quantidade_recarregar = min(
		espaco_disponivel,
		carregador_equipado.current_capacity
	)

	if quantidade_recarregar <= 0:
		print("Carregador vazio!")
		return

	# Se a arma já possui munição, o peso precisa ser igual
	if municao_atual > 0:
		if massa_municao_atual != carregador_equipado.massa_gramas:
			print("Peso da BB incompatível com a munição atual!")
			return

	# Se estava vazia, define o peso da nova munição
	else:
		massa_municao_atual = carregador_equipado.massa_gramas

	municao_atual += quantidade_recarregar
	carregador_equipado.current_capacity -= quantidade_recarregar
	

	print("Recarregou: ", quantidade_recarregar)
	print("Munição da arma: ", municao_atual, "/", capacidade_arma)
	print("Peso da BB na arma: ", massa_municao_atual, " g")
	print("Munição no carregador: ", carregador_equipado.current_capacity)
	player.remover_carregadores_vazios()
	player.atualizar_ui_inventario()

func shoot() -> void:
	
	var massa_bb = massa_municao_atual
	var energia = calcular_energia()

	var new_bullet = bullet_ref.instantiate()
	
	new_bullet.backspin_axis = muzzle.global_transform.basis.x.normalized()
	new_bullet.massa_gramas = massa_bb
	new_bullet.ENERGIA_MOLA = energia
	new_bullet.backspin_drag = hop_up
	animation_player.play("shoot")

	new_bullet.global_transform = muzzle.global_transform

	get_tree().current_scene.add_child(new_bullet)


func conectar_carregador(carregador) -> void:
	carregador.carregador_selecionado.connect(tentar_equipar_carregador)


func tentar_equipar_carregador(carregador):
	if carregador.tipo_arma != tipo_carregador:
		print("Carregador incompatível!")
		return

	carregador_equipado = carregador
	print("Carregador equipado!")

func calcular_intervalo_tiro() -> float:
	return 60.0 / motor_rpm

func disparar_se_possivel() -> void:

	if not pode_disparar:
		return

	if municao_atual <= 0:
		print("Sem munição!")
		return

	shoot()

	municao_atual -= 1
	balas_disparadas += 1

	player.atualizar_ui_inventario()

	pode_disparar = false

	await get_tree().create_timer(calcular_intervalo_tiro()).timeout

	pode_disparar = true

func trocar_modo_disparo() -> void:

	if modo_disparo == ModoDisparo.SEMI:
		modo_disparo = ModoDisparo.AUTO
	else:
		modo_disparo = ModoDisparo.SEMI

	print("Modo de disparo: ", 
		"SEMI" if modo_disparo == ModoDisparo.SEMI else "AUTO"
	)
