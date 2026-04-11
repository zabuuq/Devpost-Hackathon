extends Node

func _ready() -> void:
	if "--screenshot" in OS.get_cmdline_user_args():
		# Debug screenshot capture mode. Install the runner as a child of the
		# scene tree root so it survives change_scene_to_file calls, and skip
		# the normal splash flow. See scripts/debug/screenshot_runner.gd.
		# Uses load() (not preload) so the debug script is only parsed when
		# the flag is actually set — no impact on normal play.
		DisplayServer.window_set_size(Vector2i(1600, 900))
		var runner_script: Script = load("res://scripts/debug/screenshot_runner.gd")
		var runner: Node = Node.new()
		runner.set_script(runner_script)
		runner.name = "ScreenshotRunner"
		get_tree().root.add_child.call_deferred(runner)
		return
	get_tree().change_scene_to_file.call_deferred("res://scenes/splash.tscn")
