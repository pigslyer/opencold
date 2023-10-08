class_name PlayerHUD
extends MarginContainer

const DEFAULT_INFO_TEXTURE = preload("res://src/assets/icon.svg") # TODO: change



# Called when the node enters the scene tree for the first time.
func _ready():
	pass; # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;

## [param percent] The player's health, set to interval [0,1].
func set_health(percent: float) -> void:
	%HealthProgressBar.visible = true;
	%HealthProgressBar.value = percent;

## [param percent] The player's heat, set to interval [0,1].
func set_heat(percent: float) -> void:
	%PlayerHeatProgressBar.visible = true;
	%PlayerHeatProgressBar.value = percent;

## [param percent] The reactor's power level, set to interval [0,1].
func set_reactor_power(percent: float) -> void:
	%ReactorPowerProgressBar.visible = true;
	%ReactorPowerProgressBar.value = percent;
	
## [param celsius] The environment's temperature, set to interval [-237 C, 50 C]
func set_env_temperature(celsius: float) -> void:
	%EnvTemperatureProgressBar.visible = true;
	%EnvTemperatureProgressBar.value = celsius;

## [param text] Text to be displayed in info text (required)
## [param texture] Texture that will be displayed in info text, if not provided, use default
func push_info_text(text: String, texture: Texture2D = null) -> void:
	%InfoText.visible = true;
	%InfoText.text = text;
	if (texture == null):
		%InfoTexture.texture = DEFAULT_INFO_TEXTURE;
	else:
		%InfoTexture.texture = texture;

## [param item] Equipped item, from which we get its icon
func set_equipped(item: ItemDisplayData) -> void:
	%EquippedTexture.visible = true;
	%EquippedTexture.texture = item.data.icon;
	
	# Guns also have text to show ammo
	if item is ItemDisplayDataGun:
		%EquippedText.text = "%s / %s" % [item.ammo_left, item.mag_size]; 
	else:
		pass;

func hide_info() -> void:
	%Info.visible = false;

func hide_reactor_power() -> void:
	%ReactorPowerProgressBar.visible = false;

func hide_env_temperature() -> void:
	%EnvTemperatureProgressBar.visible = false;
	
func hide_player_health() -> void:
	%HealthProgressBar.visible = false;
	
func hide_player_heat() -> void:
	%PlayerHeatProgressBar.visible = false;
	
func hide_equipped() -> void:
	%Equipped.visible = false;

func hide_hotbar() -> void:
	%Hotbar.visible = false;

