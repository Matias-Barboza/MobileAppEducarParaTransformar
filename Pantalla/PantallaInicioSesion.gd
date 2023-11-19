extends Control


# Variables export
export var escenaDocente : PackedScene

# Variables
var endpoint : String = Globals.URL + "/auth/login"
var endpointrole: String = Globals.URL + "/api/role/"
var endpointFullname : String = Globals.URL + "/api/fullname/"
var headers : = ["Content-Type: application/json"]
var rol : String = ""
var viene_de_error : bool
var mensaje : Array = ["Correo electrónico o contraseña inválido",
						"Datos faltantes o correo electrónico inválido", 
						"Sesión iniciada",
						"Rol inválido"]
var posicion_inicial_datos : int = 841
var posicion_error : int = 885


# Variables onready
onready var request : HTTPRequest = $LoginRequest
onready var box_datos : = $BoxInicioSesion/IngresoDatos/ParteCentral/Datos
onready var correo : LineEdit = $BoxInicioSesion/IngresoDatos/ParteCentral/Datos/LineEdit
onready var line_contrasenha : LineEdit = $BoxInicioSesion/IngresoDatos/ParteCentral/Datos/LineEditContrasenha
onready var label_mensaje : Label = $BoxInicioSesion/IngresoDatos/ParteCentral/LabelMensaje
onready var animation_player : AnimationPlayer = $BoxInicioSesion/IngresoDatos/Animacion/AnimationPlayer



# Metodos
func _ready() -> void:
	correo.grab_focus()
	viene_de_error = false


func loginRequest() -> void:
	
	var body : = {
		"username" : correo.text,
		"password" : Globals.password
		}
	request.request(endpoint, headers, true, HTTPClient.METHOD_POST, to_json(body))
	Globals.password = ""


func decodeJWT(jwt : String) -> void:
	
	#Se decodifica vaya a saber uno como y
	var jwt_decoder: JWTDecoder = JWT.decode(jwt)
	var decodedPayload : = JWTUtils.base64URL_decode(jwt_decoder.get_payload())
	var playload = JSON.parse(decodedPayload.get_string_from_utf8()).result
	
	#Asigno el userId, username y el JWT en las variables globales
	Globals.jwt = jwt
	Globals.userId = playload.jti
	Globals.username = playload.sub


func mail_valido(correo) -> bool:
	
	var expresion_regular : String = Globals.expresion_regular_mail
	var regex : = RegEx.new()
	
	regex.compile(expresion_regular)
	
	return regex.search(correo, 0, correo.length() - 1) != null


func getRole() -> void:
	
	endpointrole += "%s" % Globals.userId
	$GetRole.request(endpointrole)
	endpointFullname += str(Globals.userId)
	$GetFullName.request(endpointFullname)


func cambiarEscena() -> void:
	
	if rol == "Docente":
		# Agregar animacion de sesion iniciada
		label_mensaje = mensaje[2]
		animation_player.play("sesion_iniciada")
		yield(get_tree().create_timer(0.5), "timeout")
		get_tree().change_scene_to(escenaDocente)
	else:
		label_mensaje = mensaje[3]
		animation_player.play("error_rol")
		print("Error en la obtencion del rol")


# Señales internas
func _on_LoginRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code == 200:
		if box_datos.rect_position.y == posicion_error and viene_de_error:
			animation_player.play("repliegue_desplazamiento_error")
		var json : = JSON.parse(body.get_string_from_utf8())
		decodeJWT(json.result.token)
		getRole()
	else:
		
		label_mensaje.text = mensaje[0]
		
		if box_datos.rect_position.y == posicion_inicial_datos and not viene_de_error:
			animation_player.play("desplazamiento_error")
			viene_de_error = true
		elif box_datos.rect_position.y == posicion_error and viene_de_error:
			animation_player.play("parpadeo_invalido")


func _on_GetRoleRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		rol = json.result
		yield(get_tree().create_timer(0.5), "timeout")
		cambiarEscena()
	else:
		print("Error en la obtencion del rol")


func _on_GetFullNameRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		Globals.nombreCompleto = json.result.firstname + ", " + json.result.lastname
	else:
		print("Error en la obtencion del nombre")


func _on_ButtonIS_pressed() -> void:
	print("Presionaste el boton")
	
	if(mail_valido(correo.text)):
		animation_player.play("girar")
		if box_datos.rect_position.y == posicion_error and not viene_de_error:
			animation_player.play("repliegue_desplazamiento_error")
		loginRequest()
	else:
		
		label_mensaje.text = mensaje[1]
		
		if box_datos.rect_position.y == posicion_inicial_datos:
			animation_player.play("desplazamiento_error")
		elif box_datos.rect_position.y == posicion_error:
			animation_player.play("parpadeo_invalido")
