extends RigidBody3D

# PROPRIEDADES FÍSICAS DA BB
@export var massa_gramas: float = 0.20 
@export var raio_mm: float = 3.0       

# CONFIGURAÇÃO DO HOP-UP (FÓRMULAS REAIS)
# Rotação inicial em RPM (valores comuns na vida real: 60000 a 120000 RPM)
@export var backspin_rpm: float = 15000.0 
# Constante de decaimento do spin (viscosidade do ar/rugosidade). Valores entre 0.00001 e 0.00005 são realistas
@export var k_spin_decay: float = 0.00002 

# CONSTANTES DA SIMULAÇÃO
const ENERGIA_MOLA: float = 1.49     
const GRAVIDADE: float = 9.81         
const DENSIDADE_AR: float = 1.2       
const CD_ESFERA: float = 0.47         

# VARIÁVEIS DE CONTROLE INTERNO
var massa_kg: float
var raio_metros: float
var area_transversal: float

var omega_inicial_rad: float
var omega_atual_rad: float
var tempo_de_voo: float = 0.0

func _ready() -> void:
	# Desativa a gravidade nativa do Godot para controle total manual
	gravity_scale = 0.0

	# Conversões de unidades básicas
	massa_kg = massa_gramas / 1000.0
	raio_metros = raio_mm / 1000.0
	area_transversal = PI * pow(raio_metros, 2)
	
	mass = massa_kg
	
	# Conversão do Backspin de RPM para Radianos por Segundo (w = RPM * 2 * PI / 60)
	omega_inicial_rad = (backspin_rpm * 2.0 * PI) / 60.0
	omega_atual_rad = omega_inicial_rad
	
	# Velocidade inicial com base na energia da mola (v = sqrt(2 * E / m))
	var vel_inicial_ms = sqrt((2.0 * ENERGIA_MOLA) / massa_kg)
	var vel_inicial_fps = vel_inicial_ms * 3.28084
	
	print("--- NOVO DISPARO (FÍSICA COMPLETA) ---")
	print("Velocidade Inicial: ", snapped(vel_inicial_ms, 0.01), " m/s | ", snapped(vel_inicial_fps, 0.01), " FPS")
	print("Omega Inicial: ", snapped(omega_inicial_rad, 0.1), " rad/s (~", backspin_rpm, " RPM)")
	
	# Disparo na direção frontal do cano da arma
	var direcao_inicial = -global_transform.basis.z.normalized()
	linear_velocity = direcao_inicial * vel_inicial_ms

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var velocidade_atual = state.linear_velocity
	var vel_escalar = velocidade_atual.length()
	
	if vel_escalar < 0.5:
		return
		
	var direcao_movimento = velocidade_atual.normalized()
	
	# Acumula o tempo de voo
	tempo_de_voo += state.step
	
	# --- FÓRMULA 3: SPIN DECAY ---
	omega_atual_rad = omega_inicial_rad * exp(-(k_spin_decay * tempo_de_voo) / massa_kg)
	
	# --- FÓRMULA 1: STANDARD DRAG FORCE (Arrasto contra o movimento) ---
	var forca_arrasto_modulo = 0.5 * DENSIDADE_AR * pow(vel_escalar, 2) * area_transversal * CD_ESFERA
	var forca_arrasto_vetor = -direcao_movimento * forca_arrasto_modulo
	
	# --- FÓRMULA 2: MAGNUS LIFT FORCE (Sustentação) ---
	var spin_factor_s = (omega_atual_rad * raio_metros) / vel_escalar
	var coeficiente_cl = 0.45 * spin_factor_s
	var forca_magnus_modulo = 0.5 * DENSIDADE_AR * pow(vel_escalar, 2) * area_transversal * coeficiente_cl
	
	# SEGURANÇA ABSOLUTA: Forçamos a sustentação do Magnus a empurrar puramente para cima (Vector3.UP)
	# Isso impede que erros de aproximação vetorial façam a bolinha acelerar para frente ou para os lados
	var forca_magnus_vetor = Vector3.UP * forca_magnus_modulo
	
	# --- FORÇA DA GRAVIDADE MANUAL (Sempre para baixo) ---
	var forca_gravidade_vetor = Vector3.DOWN * GRAVIDADE * massa_kg
	
	# SOMA DAS FORÇAS
	var forca_total = forca_arrasto_vetor + forca_magnus_vetor + forca_gravidade_vetor
	
	state.apply_central_force(forca_total)
