extends Control

const HOW_TO_PLAY_PAGES: Array[Dictionary] = [
	{
		"title": "Welcome, Commander",
		"screenshot": "res://assets/screenshots/01_welcome.png",
		"body": "You were pulled out of hyperspace into an unmapped nebula. So was the other commander. Neither of you asked for this. Somewhere up the chain, a bored god flipped a circuit breaker and dropped you both into the same cloud of gas and dust and static.\n\nYou have five ships. They have five ships. The nebula is watching, and the nebula does not care which of you walks out.\n\nDestroy every enemy ship. That's the whole job.",
	},
	{
		"title": "Place Your Fleet",
		"screenshot": "res://assets/screenshots/04_fleet_placement_full.png",
		"body": "Before anything else, you hide your fleet. Pick a ship from the list on the left, hover the grid, and click to lock it in place. Press Q or E to rotate. A red ghost means overlap or out-of-bounds; a green ghost means the cell is clean.\n\nYou command five ships: a Battleship, a Probe Ship, two Destroyers, and a Cruiser. Place all five to unlock the Done button. Then it's the other commander's turn at the same keyboard, and they never see your grid.\n\nPlacement is permanent. Spread your fleet like someone is coming for you, because someone is.",
	},
	{
		"title": "Two Grids, One Nebula",
		"screenshot": "res://assets/screenshots/05_command_grid.png",
		"body": "The top row has two tabs: Command Grid and Target Grid. Same 80 by 20 battlefield, two views.\n\nCommand Grid shows your fleet in full color. Yellow triangles mark which way each ship is facing. This is your board.\n\nTarget Grid shows what your probes and your incoming damage have told you about the enemy. Mostly fog. The enemy lives here, but you only see what you've paid to see.\n\nScroll to zoom. Middle-mouse drag to pan. Click a ship on the Command Grid to open its Ship Panel on the left.",
	},
	{
		"title": "Probes Are Flashlights",
		"screenshot": "res://assets/screenshots/07_probe_revealed.png",
		"body": "A probe lights up a 4 by 4 box of nebula. Probe Ship probes light up 6 by 6. Any enemy ship caught inside the box appears on your Target Grid in full detail: type, facing, shields, armor.\n\nYou get two turns of that detail. Three if a Probe Ship fired it. Then the lights go out and a ghost marker stays pinned to the map: a ship was here, once.\n\nYou can fire on a ghost. The enemy moved three turns ago. Your shot hits empty space and your log says miss. Probes are expensive. Sight is temporary. Memory is a trap.",
	},
	{
		"title": "Strip Shields. Break Armor.",
		"screenshot": "res://assets/screenshots/08_ship_panel_sliders.png",
		"body": "Every ship carries two weapons that do two different jobs.\n\nLasers deal full strength to shields and 75% to armor. Spend energy on the Laser Power slider first, then click Shoot Laser and pick a cell on the Target Grid. Lasers strip a ship's shields.\n\nMissiles deal 250 to armor and 125 to shields. Missiles cost no energy to fire; you get a fixed number per ship. Missiles kill a ship that has no shields left.\n\nFire on a cell with no active probe and you get a blind hit marker: you know something is there, you don't know what. Fire on a probed ship and the battle log tells you exactly how much damage landed.",
	},
	{
		"title": "Move In Preview",
		"screenshot": "res://assets/screenshots/09_move_preview.png",
		"body": "Click Move Ship in the Ship Panel. A ghost copy of your ship appears. Use WASD to slide it around the grid: W up, S down, A left, D right. Screen-relative, not ship-relative. Q and E rotate the ghost, one net rotation per move.\n\nThe bottom of the grid shows Move Points and Energy cost, updating live as you drag. Moving forward along your facing direction costs half a move point; every other direction costs a full point. Your move budget is capped by the energy you have left.\n\nPress Enter to commit, Escape to cancel. Nothing happens until you confirm. The Cruiser gets a bigger move budget than the rest of the fleet because the Cruiser is fast.",
	},
	{
		"title": "Spend Your Energy",
		"screenshot": "res://assets/screenshots/08_ship_panel_sliders.png",
		"body": "Every ship regenerates 50 energy at the start of your turn. You split that energy between two sliders in the Ship Panel: Shield Regen and Laser Power.\n\nShield Regen fires at the end of your turn. Drag it up and your shields heal; energy drains as they fill. Drag Laser Power up and your next laser shot hits harder.\n\nShields take priority when energy is tight. If you set both sliders higher than your available energy, shields fill first and the laser drops to whatever is left. Plan your turn around that: probe early, allocate energy second, fire last.",
	},
	{
		"title": "Kill Everything",
		"screenshot": "res://assets/screenshots/10_active_probe_enemy_panel.png",
		"body": "A ship dies when its armor hits zero. Shields are a buffer; they don't protect the hull once they're gone. Destroyed ships leave wreckage on the grid, passable and inert.\n\nThe first commander to destroy all five enemy ships wins. The Victory screen shows probes launched, hits scored, and the player who walked out of the nebula.\n\nBetween turns, a handoff screen reports the hit count to the incoming commander. No coordinates. No ship names. No damage numbers. If someone tries to peek at the screen, slide the laptop back at them. This is a two-player game.",
	},
]

@onready var how_to_play_overlay: Control = $HowToPlayOverlay
@onready var sfx_button: Button = $MenuContainer/SFXToggle
@onready var music_button: Button = $MenuContainer/MusicToggle
@onready var page_title: Label = $HowToPlayOverlay/Panel/PageTitle
@onready var page_screenshot: TextureRect = $HowToPlayOverlay/Panel/PageScreenshot
@onready var page_body: RichTextLabel = $HowToPlayOverlay/Panel/PageBody
@onready var page_indicator: Label = $HowToPlayOverlay/Panel/NavRow/PageIndicator
@onready var previous_button: Button = $HowToPlayOverlay/Panel/NavRow/PreviousButton
@onready var next_button: Button = $HowToPlayOverlay/Panel/NavRow/NextButton

var current_page: int = 0

func _ready() -> void:
	GameState.phase = GameState.Phase.MENU
	AudioManager.play_music("ambient_space")
	_update_toggle_labels()
	_render_page()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("click")
	GameState.reset()
	GameState.current_player = 0
	GameState.phase = GameState.Phase.PLACEMENT
	get_tree().change_scene_to_file("res://scenes/fleet_placement.tscn")

func _on_how_to_play_pressed() -> void:
	AudioManager.play_sfx("click")
	current_page = 0
	_render_page()
	how_to_play_overlay.visible = true

func _on_close_overlay_pressed() -> void:
	AudioManager.play_sfx("click")
	how_to_play_overlay.visible = false

func _on_previous_page_pressed() -> void:
	AudioManager.play_sfx("click")
	if current_page > 0:
		current_page -= 1
		_render_page()

func _on_next_page_pressed() -> void:
	AudioManager.play_sfx("click")
	if current_page < HOW_TO_PLAY_PAGES.size() - 1:
		current_page += 1
		_render_page()

func _render_page() -> void:
	var page: Dictionary = HOW_TO_PLAY_PAGES[current_page]
	page_title.text = page["title"]
	var screenshot_path: String = page["screenshot"]
	if ResourceLoader.exists(screenshot_path):
		page_screenshot.texture = load(screenshot_path)
	else:
		page_screenshot.texture = null
	page_body.text = page["body"]
	page_indicator.text = "Page %d of %d" % [current_page + 1, HOW_TO_PLAY_PAGES.size()]
	previous_button.disabled = current_page == 0
	next_button.disabled = current_page == HOW_TO_PLAY_PAGES.size() - 1

func _on_sfx_toggle_pressed() -> void:
	AudioManager.set_sfx_enabled(not GameState.sfx_enabled)
	_update_toggle_labels()

func _on_music_toggle_pressed() -> void:
	AudioManager.set_music_enabled(not GameState.music_enabled)
	_update_toggle_labels()

func _update_toggle_labels() -> void:
	sfx_button.text = "SFX: ON" if GameState.sfx_enabled else "SFX: OFF"
	music_button.text = "Music: ON" if GameState.music_enabled else "Music: OFF"
