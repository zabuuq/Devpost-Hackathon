extends Control

const HOW_TO_PLAY_PAGES: Array[Dictionary] = [
	{
		"title": "Welcome, Commander",
		"screenshot": "",
		"body": "One minute you're cruising through hyperspace, halfway through a reconstituted turkey sandwich, and a mediocre opinion of the Oort Cloud. Next, a cosmic sledgehammer drops your fleet into an unmapped nebula.\n\nChaos. Your sensors flicker off like a bored god just hit the breaker. In that half-second of useful existence, your navigator, who once got lost in a parking lot, spots an enemy fleet. They've got live warheads, the ethics of a space whale with a hangover, and the same lost-puppy look you're sporting. Welcome to the soup.\n\nDid those dollar-store fudgesicles pull this cosmic prank, or are they just as bamboozled as you? Maybe the nebula just hates commuters. Doesn't matter. You're both stuck in the same interstellar meat grinder, and only one of you gets to crawl out. The other gets a ghost marker and a footnote in the nebula's unofficial idiot census.\n\nTwo commanders. One computer. Zero chance you'll agree on snack breaks.\n\nYour job: Find the enemy fleet and turn it into space confetti before they do the same to you. First to run out of ships loses. Don't take it personally. The nebula's just cleaning house, and you're the dust bunnies.\n\nBattlestations: Nebula is a hot-seat game. You and your nemesis share a screen, taking turns to hunt each other's ships like two raccoons fighting over a single trash can. When it's not your turn, avert your eyes like the decent human being your mom claims you are. Then swap.\n\nNo peeking. The nebula sees all, judges all, and has nothing better to do. If you cheat, you'll have to declare, with all the dignity of a soggy sandwich, \"I have invoked the wrath of the nebula!\" and lose your turn. That's just cosmic justice.",
	},
	{
		"title": "Place Your Fleet",
		"screenshot": "res://assets/screenshots/04_fleet_placement_full.png",
		"body": "Step one of not dying: hide your fleet. Click a ship from the list on the left, hover over the grid, and click again to lock it in place. Q and E rotate. Red ghost means overlap or out of bounds. Green ghost means the nebula hasn't decided to ruin your afternoon yet, but give it time. Right-click cancels, for when your commitment issues flare up, or you just remembered you left a sandwich in the microwave.\n\nYou get five ships and zero refunds: a Battleship, a Probe Ship, two Destroyers, and a Cruiser. Place all five to wake up the Done button. Then your nemesis takes the same keyboard, hides their own fleet, and swears on an Oort Cloud bible they didn't peek. They definitely didn't peek. Probably.\n\nYour ships will be able to move after placement, but don't clump them like anxious penguins at a pool party. Spread out like someone is coming for you, because someone is, and they're doing the same math on the other side of this laptop, probably while eating your chips.",
	},
	{
		"title": "Two Grids, One Nebula",
		"images": [
			{"path": "res://assets/screenshots/05a_grid_tabs.png",        "side": "right", "y_offset": 0.0,   "width": 400.0, "height": 150.0},
			{"path": "res://assets/screenshots/05b_command_ships.png",    "side": "left",  "y_offset": 206.0, "width": 400.0, "height": 170.0},
			{"path": "res://assets/screenshots/05c_target_grid_mixed.png","side": "right", "y_offset": 384.0, "width": 400.0, "height": 170.0},
		],
		"body": "Two tabs at the top of the screen. Same nebula, two different problems.\n\nThe Command Grid is your side of the story. Your ships in full color, each with a little yellow triangle pointing wherever its captain thinks is a good idea. Nothing is hidden from you here. Savor it, because the other tab is about to kick that feeling in the teeth, steal your lunch money, and leave you with a participation trophy.\n\nThe Target Grid is where the enemy lives. Mostly fog, the kind of fog that hides warheads, grudges, and at least one destroyer already rehearsing what it's going to do to your afternoon. You only see what you pay for: a probe caught someone mid-sneak, or one of your shots hit something solid enough to pin on the map. Everything else, the nebula keeps to itself for fun, profit, and the sheer joy of watching you flail.\n\nScroll to zoom. Middle-mouse drag to pan across the 80-by-20 battlefield. Click one of your ships on the Command Grid and the Ship Panel opens on the left, full of sliders, buttons, and one polite reminder that you are, in fact, in a war, not a sandwich assembly line.",
	},
	{
		"title": "The Ship Panel",
		"images": [
			{"path": "res://assets/screenshots/08a_ship_panel_tight.png", "side": "left", "y_offset": 0.0, "width": 200.0, "height": 500.0},
		],
		"body": "Click any ship on the Command Grid, and the Ship Panel lights up like an overcaffeinated ensign on their first day. This is the command deck for that specific hull.\n\nAt the top, you get the ship's name and a parade of numbers nobody cares about until they're all in the red: shields, armor, energy, probes left, missiles left, and whatever's left of your will to live after three turns in this cosmic meat grinder.\n\nUnder the stats, you get two sliders. **Shield Regen** eats energy to regrow your shields. Shields come back. Armor? Sorry, not sorry. **Laser Power** loads the gun. Drag the sliders, argue with yourself, and try to remember you're working with a finite pile of energy, and both sliders are hungry. Spoiler: you'll allocate wrong. Everyone does. The ones who say they don't are either lying or already a smear on the nebula.\n\nBelow the sliders: four big shiny buttons. **Launch Probe** lights up a chunk of nebula, like poking a haunted closet with a flashlight. **Shoot Laser** picks a cell and burns a hole in it, assuming your target isn't just a figment of your imagination. **Launch Missile** hurls a chunk of angry metal into someone's otherwise peaceful lunch break. **Move Ship** does what it says. Don't act surprised.\n\nOne action per ship per turn. Pick the wrong one and, three turns later, a ghost marker with your lunch money and your dignity in its crosshairs will punt both out the nearest airlock. Don't say I didn't warn you.",
	},
	{
		"title": "Probes Are Flashlights",
		"images": [
			{"path": "res://assets/screenshots/05c_target_grid_mixed.png", "side": "right", "y_offset": 0.0, "width": 452.0, "height": 192.0},
		],
		"body": "A probe is a flashlight in a haunted house, except the ghosts have plasma cannons and a grudge. Smash that Launch Probe button, pick a cell, and you light up a 4-by-4 chunk of nebula. Every enemy ship in the box pops up on your Target Grid, all their embarrassing stats exposed: type, facing, shields, armor, and the creeping suspicion you just ruined someone's airtight alibi. The Probe Ship gets a 6-by-6 box, because it spent its formative years at flashlight camp, won a badge, and now won't shut up about it. Typical.\n\nYou get two turns of that sweet, fleeting clarity. Three if a Probe Ship did the honors. That's your window to do the math: count shields, eyeball armor, check which way they're pointing, and decide if you can vaporize them before they catch a whiff of the discount cologne you panic-bought at the last waystation. Then the lights die, and the nebula hands you a consolation prize: a ghost marker, stuck to the map like a passive-aggressive sticky note that says, \"A ship was here once. Good luck, genius.\"\n\nGhost markers are permanent. So is regret. Usually, they're both wrong. You can fire on a ghost if you like wasting ammo and dignity. The enemy moved three turns ago. Your shot hits empty space, your log says miss, and somewhere in the nebula, something laughs at you, personally, like it got your yearbook photo and your home address.\n\nProbes cost energy, and energy ain't cheap, so turn off the lights when you leave the room! Spend them like a divorced dad on a weekend: with purpose, a little too late, and aimed directly at whatever makes you want to move to a moon colony. Sight is temporary. Memory is a trap. Missing is free, and you will absolutely overdraw that account.",
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
@onready var page_screenshot: TextureRect = $HowToPlayOverlay/Panel/ContentArea/PageScreenshot
@onready var page_screenshot2: TextureRect = $HowToPlayOverlay/Panel/ContentArea/PageScreenshot2
@onready var page_screenshot3: TextureRect = $HowToPlayOverlay/Panel/ContentArea/PageScreenshot3
@onready var page_body: TextWrap = $HowToPlayOverlay/Panel/ContentArea/PageBody
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
	var body: String = page["body"]
	# Reset all three TextureRects before applying the active schema.
	var slots: Array[TextureRect] = [page_screenshot, page_screenshot2, page_screenshot3]
	for slot in slots:
		slot.visible = false
		slot.texture = null
	page_body.regions = []
	page_body.image_width = 0.0
	page_body.image_height = 0.0
	if page.has("images"):
		var images: Array = page["images"]
		var content_w: float = page_body.size.x
		if content_w <= 0.0:
			content_w = 920.0  # ContentArea custom_minimum_size.x, matches tscn
		var regions: Array = []
		for i in range(min(images.size(), slots.size())):
			var img: Dictionary = images[i]
			var slot: TextureRect = slots[i]
			var w: float = float(img.get("width", 400.0))
			var h: float = float(img.get("height", 170.0))
			var y: float = float(img.get("y_offset", 0.0))
			var side: String = String(img.get("side", "right"))
			var x: float = content_w - w if side == "right" else 0.0
			slot.anchor_left = 0.0
			slot.anchor_top = 0.0
			slot.anchor_right = 0.0
			slot.anchor_bottom = 0.0
			slot.offset_left = x
			slot.offset_top = y
			slot.offset_right = x + w
			slot.offset_bottom = y + h
			slot.visible = true
			var path: String = String(img.get("path", ""))
			if not path.is_empty() and ResourceLoader.exists(path):
				slot.texture = load(path)
			regions.append({
				"side": side,
				"y_offset": y,
				"width": w,
				"height": h,
			})
		page_body.regions = regions
	elif page.has("screenshot"):
		var screenshot_path: String = page["screenshot"]
		if screenshot_path.is_empty():
			page_screenshot.visible = false
		else:
			# Restore the legacy top-right 560x315 anchors. The multi-image
			# branch above overwrites these to (0,0,0,0) with pixel offsets, so
			# without this reset, returning to a single-screenshot page leaves
			# the TextureRect collapsed at the top-left corner.
			page_screenshot.anchor_left = 1.0
			page_screenshot.anchor_top = 0.0
			page_screenshot.anchor_right = 1.0
			page_screenshot.anchor_bottom = 0.0
			page_screenshot.offset_left = -560.0
			page_screenshot.offset_top = 0.0
			page_screenshot.offset_right = 0.0
			page_screenshot.offset_bottom = 315.0
			page_screenshot.visible = true
			if ResourceLoader.exists(screenshot_path):
				page_screenshot.texture = load(screenshot_path)
			page_body.image_width = 560.0
			page_body.image_height = 315.0
	page_body.text = body
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
