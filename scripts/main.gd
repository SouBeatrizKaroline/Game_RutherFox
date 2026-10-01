extends Node2D
## Orquestra sessões, troca de salas e interface. A geometria fica em data/rooms.json.

const Player = preload("res://scripts/player.gd")
const Guard = preload("res://scripts/guard.gd")
const Navigation = preload("res://scripts/navigation.gd")
const Pulse = preload("res://scripts/pulse.gd")
const Interactable = preload("res://scripts/interactable.gd")
const SAVE_PATH := "user://progress.json"
const PARTS := ["coil", "cell", "chip"]
const INK := Color("0b1521")
const MINT := Color("68e8e1")
enum State { MENU, PLAY, PAUSE, CAPTURED, WON }

var state := State.MENU
var rooms: Dictionary = {}
var room_id := "lab1"
var collected: Array[String] = []
var suspicion := 0.0
var room: Node2D
var player: CharacterBody2D
var guards: Array[Node2D] = []
var items: Array[Node2D] = []
var nearest: Node2D
var hud: Control
var overlay: Control
var prompt: Label
var progress: Label
var alert_label: Label
var alert_bar: ProgressBar
var message := ""
var message_time := 0.0
var overlay_buttons: Array[Button] = []
var save_enabled := true
var save_path := SAVE_PATH

func _ready() -> void:
	rooms = JSON.parse_string(FileAccess.get_file_as_string("res://data/rooms.json"))
	_bind_inputs()
	load_room("lab1", Vector2(285,510))
	_show_menu()

func _bind_inputs() -> void:
	var keys := {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"up":[KEY_W,KEY_UP],"down":[KEY_S,KEY_DOWN],"sneak":[KEY_SHIFT],"interact":[KEY_E],"pause":[KEY_ESCAPE],"restart":[KEY_R],"distract":[KEY_F]}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in keys[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action,event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if state == State.PLAY:
			_pause()
		elif state == State.PAUSE:
			_resume()
		get_viewport().set_input_as_handled()
	if state != State.PLAY:
		return
	if event.is_action_pressed("distract"):
		distract()
	elif event.is_action_pressed("interact") and is_instance_valid(nearest):
		interact(nearest)
	elif event.is_action_pressed("restart"):
		load_room(room_id,Vector2(285,510) if room_id == "lab1" else Vector2(150,480))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for item in items:
			if item.available and item.global_position.distance_to(get_global_mouse_position()) < 35:
				interact(item)
				break

func _process(delta: float) -> void:
	if state != State.PLAY:
		return
	nearest = null
	var shortest := 72.0
	for item in items:
		item.nearby = false
		var distance: float = item.position.distance_to(player.position)
		if item.available and distance <= shortest and _can_reach(item):
			shortest = distance
			nearest = item
	if is_instance_valid(nearest):
		nearest.nearby = true
	var seen := false
	for guard in guards:
		seen = seen or guard.sees_player
	suspicion = clampf(suspicion + delta * (0.62 if seen else -0.38), 0, 1)
	alert_bar.value = suspicion * 100
	alert_label.text = "! SENDO VISTA" if seen else ("ATENÇÃO" if suspicion > 0.1 else "OCULTA")
	message_time = maxf(0,message_time-delta)
	prompt.text = message if message_time > 0 else (("[E]  " + nearest.title) if is_instance_valid(nearest) else "Encontre as peças. Use os móveis para sair do campo de visão.")
	if suspicion >= 1:
		_capture()

func load_room(id: String, spawn: Vector2) -> void:
	var cooldown: float = player.distraction_cooldown if is_instance_valid(player) else 0.0
	if is_instance_valid(room):
		remove_child(room)
		room.queue_free()
	guards.clear()
	items.clear()
	nearest = null
	suspicion = 0
	message = ""
	message_time = 0.0
	room_id = id
	room = Node2D.new()
	room.position = Vector2(40,102)
	add_child(room)
	var data: Dictionary = rooms[id]
	var navigation := Navigation.new()
	navigation.build(data.props)
	_sprite(data.background,Rect2(0,0,1200,600),Color("a6b7ce"))
	_solid(Rect2(0,0,1200,65))
	_solid(Rect2(0,0,30,600))
	_solid(Rect2(1170,0,30,600))
	_solid(Rect2(0,580,1200,20))
	for prop in data.props:
		_sprite(prop.asset,_rect(prop.rect))
		_solid(_rect(prop.solid))
	player = Player.new()
	player.distraction_cooldown = cooldown
	player.position = spawn
	room.add_child(player)
	for route_data in data.guards:
		var guard := Guard.new()
		for point in route_data:
			guard.route.append(Vector2(point[0],point[1]))
		guard.position = guard.route[0]
		guard.player = player
		guard.navigation = navigation
		guard.role = "scientist" if id == "lab2" else "guard"
		room.add_child(guard)
		guards.append(guard)
	for item_data in data.items:
		var item := Interactable.new()
		item.id = item_data.id
		item.title = item_data.title
		item.kind = item_data.kind
		item.destination = item_data.get("destination", "")
		item.position = Vector2(item_data.at[0],item_data.at[1])
		item.available = not collected.has(item.id)
		room.add_child(item)
		items.append(item)
	_build_hud()
	_enable_world(state == State.PLAY)

func _rect(values: Array) -> Rect2:
	return Rect2(values[0],values[1],values[2],values[3])

func _sprite(path: String, rect: Rect2, tint: Color = Color.WHITE) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/runtime/" + path)
	sprite.centered = false
	sprite.position = rect.position
	sprite.scale = rect.size / sprite.texture.get_size()
	sprite.modulate = tint
	room.add_child(sprite)

func _solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	room.add_child(body)

func _can_reach(item: Node2D) -> bool:
	var ray := PhysicsRayQueryParameters2D.create(player.global_position, item.global_position, 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func interact(item: Node2D) -> void:
	if state != State.PLAY or not is_instance_valid(item) or not items.has(item) or not item.available:
		return
	if player.position.distance_to(item.position) > 72:
		_notify("Aproxime-se do objeto para interagir.")
		return
	if not _can_reach(item):
		_notify("Contorne o obstáculo para alcançar o objeto.")
		return
	if item.kind == "part":
		collected.append(item.id)
		item.available = false
		progress.text = "PEÇAS  %d / 3" % collected.size()
		_tone(660.0)
		player.art.flash = 1.0
		var saved := save_progress()
		var notice := "Peça recuperada."
		if save_enabled:
			notice += " Progresso salvo." if saved else " Não foi possível salvar o progresso."
		_notify(notice)
	elif item.kind == "door":
		var destination: String = item.destination
		var moving_right: bool = item.position.x > 600
		load_room(destination,Vector2(150 if moving_right else 1040,480))
		if save_enabled and not save_progress():
			_notify("Não foi possível salvar o progresso deste setor.")
	elif item.kind == "terminal":
		if collected.size() < 3:
			_notify("Faltam %d peça(s). Explore os três setores." % (3-collected.size()))
		else:
			_win()

func _notify(text: String) -> void:
	message = text
	message_time = 3.0

func start_new() -> void:
	collected.clear()
	if is_instance_valid(player):
		player.distraction_cooldown = 0.0
	state = State.PLAY
	_clear_overlay()
	load_room("lab1",Vector2(285,510))
	if save_enabled and not save_progress():
		_notify("Não foi possível salvar a nova missão.")

func _enable_world(value: bool) -> void:
	room.process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
	player.enabled = value
	player.art.active = value
	for guard in guards:
		guard.enabled = value
		guard.art.active = value

func _pause() -> void:
	state = State.PAUSE
	_enable_world(false)
	_panel("PAUSA", "Respire. Observe. Espere.", "A patrulha está parada. Seu progresso continua aqui.")
	_button(overlay,"Continuar",Vector2(420,454),Vector2(440,54),_resume)
	_button(overlay,"Voltar ao início",Vector2(420,521),Vector2(440,48),_show_menu,false)

func _resume() -> void:
	state = State.PLAY
	_clear_overlay()
	_enable_world(true)

func _capture() -> void:
	state = State.CAPTURED
	_enable_world(false)
	_panel("DETECTADA", "Eles encontraram Gânia.", "As peças recuperadas continuam com você.\nTente outra rota e use os móveis como cobertura.")
	_button(overlay,"Tentar novamente",Vector2(420,469),Vector2(440,54),func():
		state = State.PLAY
		_clear_overlay()
		load_room(room_id,Vector2(285,510) if room_id == "lab1" else Vector2(150,480)))

func distract() -> void:
	if state != State.PLAY: return
	if player.distraction_cooldown > 0:
		_notify("Distração recarregando: %.0f s" % ceilf(player.distraction_cooldown))
		return
	var offset := get_global_mouse_position() - player.global_position
	if offset.length() < 10: offset = player.art.direction * 170
	offset = offset.limit_length(180)
	var end: Vector2 = player.global_position + offset
	var ray := PhysicsRayQueryParameters2D.create(player.global_position,end,1)
	var hit := get_world_2d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty(): end = hit.position - offset.normalized() * 16
	var point := room.to_local(end)
	var pulse := Pulse.new()
	pulse.position = point
	pulse.color = Color("ffcf7b")
	room.add_child(pulse)
	for guard in guards:
		if guard.position.distance_to(point) < 330: guard.investigate(point)
	player.distraction_cooldown = 5.0
	_tone(240.0)
	_notify("Ruído lançado. Mova-se com Shift enquanto investigam.")

func _tone(frequency: float) -> void:
	var stream := AudioStreamWAV.new()
	stream.mix_rate = 22050
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	var bytes := PackedByteArray()
	bytes.resize(4410 * 2)
	for i in range(4410):
		var sample := int(sin(TAU * frequency * i / 22050.0) * 5000 * (1.0-float(i)/4410))
		bytes.encode_s16(i*2,sample)
	stream.data = bytes
	var audio := AudioStreamPlayer.new()
	audio.stream = stream
	add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()

func _win() -> void:
	state = State.WON
	_enable_world(false)
	# O desfecho continua animado, sem movimento ou percepção dos personagens.
	room.process_mode = Node.PROCESS_MODE_INHERIT
	_clear_overlay()
	var pulse := Pulse.new()
	pulse.position = player.position
	pulse.radius = 1300
	room.add_child(pulse)
	_tone(880.0)
	for guard in guards:
		guard.transform_to_fox()
	_notify("O Protocolo Azul foi ativado.")
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 2.0
	add_child(timer)
	timer.timeout.connect(_show_ending)
	timer.timeout.connect(timer.queue_free)
	timer.start()

func _show_ending() -> void:
	if state != State.WON: return
	_panel("PROTOCOLO AZUL ATIVADO", "A escolha de Gânia.", "O pulso transforma os responsáveis deste setor em raposas.\nGânia encara o resultado. A vingança devolverá o que perdeu?")
	_button(overlay,"Jogar novamente",Vector2(420,469),Vector2(440,54),start_new)
	_button(overlay,"Voltar ao início",Vector2(420,535),Vector2(440,48),_show_menu,false)

func _show_menu() -> void:
	state = State.MENU
	_enable_world(false)
	_panel("ARCADE AGE  /  NOVA BASE JOGÁVEL", "RUTHERFOX", "Ajude Gânia a escapar do laboratório.\nRecupere três peças sem ser vista e monte o dispositivo.")
	_label(overlay,"P R O T O C O L O   A Z U L",Vector2(420,302),22,MINT)
	_button(overlay,"Iniciar missão  →",Vector2(420,451),Vector2(440,54),start_new)
	if not _read_save().is_empty():
		_button(overlay,"Continuar progresso",Vector2(420,518),Vector2(440,46),continue_game,false)
	_label(overlay,"WASD / SETAS  mover     SHIFT  andar devagar\nE / CLIQUE  interagir     F  distrair     ESC  pausar",Vector2(420,584),16,Color("a3b3c6"))
	_label(overlay,"Protótipo 0.2  •  Animações e busca ativa",Vector2(420,661),14,Color("7f93ac"))

func _build_hud() -> void:
	if is_instance_valid(hud):
		remove_child(hud)
		hud.queue_free()
	hud = Control.new()
	hud.z_index = 50
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hud)
	_label(hud,"RUTHERFOX",Vector2(40,16),24,MINT)
	_label(hud,rooms[room_id].subtitle,Vector2(41,49),12,Color("8da2b9"))
	_label(hud,rooms[room_id].title,Vector2(350,26),22,Color("e3edf5"))
	progress = _label(hud,"PEÇAS  %d / 3" % collected.size(),Vector2(805,25),19,MINT)
	alert_label = _label(hud,"OCULTA",Vector2(995,14),13,Color("edcc8c"))
	alert_bar = ProgressBar.new()
	alert_bar.position = Vector2(995,43)
	alert_bar.size = Vector2(120,7)
	alert_bar.show_percentage = false
	hud.add_child(alert_bar)
	_button(hud,"II",Vector2(1178,18),Vector2(60,46),func():
		if state == State.PLAY: _pause(),false)
	prompt = _label(hud,"",Vector2(40,720),18,Color("d6e8ef"))
	_label(hud,"WASD / SETAS   mover     SHIFT   furtividade     E / CLIQUE   interagir     F   distrair     ESC   pausa     R   reposicionar",Vector2(40,762),13,Color("8da2b9"))

func _panel(eyebrow: String, title: String, description: String) -> void:
	_clear_overlay()
	overlay = Control.new()
	overlay.z_index = 100
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02,0.04,0.07,0.90)
	shade.size = Vector2(1280,800)
	overlay.add_child(shade)
	var card := Panel.new()
	card.position = Vector2(370,150)
	card.size = Vector2(540,570)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("10212f")
	style.border_color = Color("30505e")
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	card.add_theme_stylebox_override("panel",style)
	overlay.add_child(card)
	_label(overlay,eyebrow,Vector2(420,195),13,MINT)
	_label(overlay,title,Vector2(420,245),30,Color("eef8ff"))
	var description_label := Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.position = Vector2(420,350)
	description_label.size = Vector2(440,90)
	description_label.add_theme_font_size_override("font_size",17)
	description_label.add_theme_color_override("font_color",Color("b8cbd9"))
	description_label.text = description
	overlay.add_child(description_label)

func _clear_overlay() -> void:
	overlay_buttons.clear()
	if is_instance_valid(overlay):
		remove_child(overlay)
		overlay.queue_free()
		overlay = null

func _label(parent: Node, text: String, position_value: Vector2, size_value: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position_value
	label.add_theme_font_size_override("font_size",size_value)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, at: Vector2, dimensions: Vector2, callback: Callable, primary: bool = true) -> void:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = dimensions
	button.add_theme_font_size_override("font_size",18)
	button.add_theme_color_override("font_color",INK if primary else Color("d9eef6"))
	button.add_theme_color_override("font_hover_color",INK)
	button.add_theme_color_override("font_focus_color",INK)
	var style := StyleBoxFlat.new()
	style.bg_color = MINT if primary else Color("233b4b")
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal",style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color("b3fff4")
	button.add_theme_stylebox_override("hover",hover)
	button.add_theme_stylebox_override("focus",hover)
	button.pressed.connect(callback)
	parent.add_child(button)
	if parent == hud:
		button.focus_mode = Control.FOCUS_NONE
	if parent == overlay:
		overlay_buttons.append(button)
		if overlay_buttons.size() == 1:
			button.grab_focus()

func save_progress() -> bool:
	if not save_enabled:
		return false
	# Escreve ao lado do save antes de substituí-lo, preservando o anterior em falhas.
	var temporary_path := save_path + ".tmp"
	var file := FileAccess.open(temporary_path,FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify({"version":1,"room":room_id,"parts":collected}))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		DirAccess.remove_absolute(temporary_path)
		return false
	if DirAccess.rename_absolute(temporary_path, save_path) != OK:
		DirAccess.remove_absolute(temporary_path)
		return false
	return true

func _read_save() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	var value: Variant = json.data
	if not value is Dictionary or value.get("version") != 1 or not rooms.has(value.get("room", "")) or not value.get("parts") is Array:
		return {}
	for part in value.parts:
		if not part is String or not PARTS.has(part):
			return {}
	return value

func continue_game() -> void:
	var data := _read_save()
	if data.is_empty():
		start_new()
		return
	collected.clear()
	for part in data.parts:
		if not collected.has(part):
			collected.append(part)
	state = State.PLAY
	_clear_overlay()
	load_room(data.room,Vector2(285,510) if data.room == "lab1" else Vector2(150,480))
