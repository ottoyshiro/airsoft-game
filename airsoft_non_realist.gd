extends RigidBody3D

@export var massa_gramas: float = 0.20
var raio_mm: float = 3.0
var backspin_drag: float = 0.03

@export var ENERGIA_MOLA: float = 1.49  
const GRAVIDADE: float = 9.81         
const DENSIDADE_AR: float = 1.2       
const CD_ESFERA: float = 0.47         

var massa_kg: float
var raio_metros: float
var area_transversal: float
var ja_colidiu: bool = false
var backspin_axis: Vector3
var direcao_inicial: Vector3

func _ready() -> void:

	massa_kg = massa_gramas / 1000.0
	raio_metros = raio_mm / 1000.0
	
	area_transversal = PI * pow(raio_metros, 2)
	
	mass = massa_kg
	
	# velocidade inicial (v = sqrt(2 * E / m))
	var vel_inicial_ms = sqrt((2.0 * ENERGIA_MOLA) / massa_kg)
	var vel_inicial_fps = vel_inicial_ms * 3.28084
	
	print("NOVO DISPARO (RIGIDBODY3D)")
	print("Massa da BB: ", massa_gramas, "g")
	print("Velocidade Inicial: ", snapped(vel_inicial_ms, 0.01), " m/s | ", snapped(vel_inicial_fps, 0.01), " FPS")
	
	if direcao_inicial == Vector3.ZERO:
		direcao_inicial = -global_transform.basis.z.normalized()

	linear_velocity = direcao_inicial * vel_inicial_ms
	
	print("Frente: ", -global_transform.basis.z)
	print("Direita: ", global_transform.basis.x)
	print("Cima: ", global_transform.basis.y)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var velocidade_atual = state.linear_velocity
	var vel_escalar = velocidade_atual.length()
	
	if vel_escalar < 0.1:
		return
		
	var direcao_movimento = velocidade_atual.normalized()
	
	# FORÇA DE ARRASTO (DRAG)
	var forca_arrasto_modulo = 0.5 * DENSIDADE_AR * pow(vel_escalar, 2) * CD_ESFERA * area_transversal
	var forca_arrasto_vetor = -direcao_movimento * forca_arrasto_modulo
	
	# FORÇA DE SUSTENTAÇÃO (MAGNUS / BACKSPIN)

	var direcao_sustentacao = backspin_axis.cross(direcao_movimento).normalized()
	#var direcao_sustentacao = global_transform.basis.y.normalized()
	var forca_magnus_modulo = (
	0.5
	* DENSIDADE_AR
	* pow(vel_escalar, 2)
	* area_transversal
	* backspin_drag
	)
	var forca_magnus_vetor = direcao_sustentacao * forca_magnus_modulo
	
	
	# FORÇA DA GRAVIDADE
	var forca_gravidade_vetor = Vector3.DOWN * GRAVIDADE * massa_kg
	
	# SOMA DAS FORÇAS
	var forca_total = forca_arrasto_vetor + forca_magnus_vetor + forca_gravidade_vetor
	
	state.apply_central_force(forca_total)
	

func _on_body_entered(body: Node) -> void:
	if ja_colidiu:
		return
	if body.is_in_group("bullet"):
		return
	# Se bater em algo que recebe dano (como o seu inimigo)
	print(body)
	if body.has_method("take_damage"):
		body.take_damage(1) # Aplica 1 de dano (mude o valor se quiser)
		queue_free()        # Some com a bala imediatamente
		return

	# Se bater em qualquer outra coisa (chão, parede, etc.)
	ja_colidiu = true
	gravity_scale = 1.0 
	print("BB colidiu com o cenário: ", body.name, " | Forças de voo desligadas.")
