class_name TextWrap
extends Control
## Word-wraps text around a rectangular avoid region in the top-right corner
## of its own rect. Used by the How to Play overlay to get float-right image
## behavior that Godot's RichTextLabel does not support natively.
##
## Set `image_width` / `image_height` to zero to disable avoidance (text fills
## the full width). Single newlines are treated as hard line breaks; double
## newlines produce a paragraph gap.

@export_multiline var text: String = "":
	set(value):
		text = value
		queue_redraw()

@export var image_width: float = 0.0:
	set(value):
		image_width = value
		queue_redraw()

@export var image_height: float = 0.0:
	set(value):
		image_height = value
		queue_redraw()

@export var image_padding: float = 16.0:
	set(value):
		image_padding = value
		queue_redraw()

@export var font_size: int = 15:
	set(value):
		font_size = value
		queue_redraw()

@export var font_color: Color = Color(0.85, 0.9, 1.0, 1.0):
	set(value):
		font_color = value
		queue_redraw()

@export var line_height_scale: float = 1.35
@export var paragraph_gap_scale: float = 0.6


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	if text.is_empty() or size.x <= 0.0:
		return
	var font: Font = get_theme_default_font()
	if font == null:
		return
	var line_h: float = font.get_height(font_size) * line_height_scale
	var ascent: float = font.get_ascent(font_size)
	var space_w: float = font.get_string_size(
		" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var para_gap: float = font.get_height(font_size) * paragraph_gap_scale
	var cursor_y: float = 0.0
	var paragraphs: PackedStringArray = text.split("\n\n")
	for p_idx in range(paragraphs.size()):
		var para: String = paragraphs[p_idx]
		if para.is_empty():
			cursor_y += para_gap
			continue
		# Within a paragraph, single \n forces a hard line break.
		var sub_lines: PackedStringArray = para.split("\n")
		for s_idx in range(sub_lines.size()):
			var sl: String = sub_lines[s_idx]
			cursor_y = _layout_segment(font, sl, cursor_y, line_h, space_w, ascent)
		if p_idx < paragraphs.size() - 1:
			cursor_y += para_gap


func _layout_segment(
		font: Font,
		segment: String,
		start_y: float,
		line_h: float,
		space_w: float,
		ascent: float) -> float:
	var cursor_y: float = start_y
	var words: PackedStringArray = segment.split(" ", false)
	var line: Array[String] = []
	var line_w: float = 0.0
	var available_w: float = _width_at(cursor_y, line_h)
	for word in words:
		if word.is_empty():
			continue
		var word_w: float = font.get_string_size(
			word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var trial_w: float = line_w + word_w
		if not line.is_empty():
			trial_w += space_w
		if line.is_empty() or trial_w <= available_w:
			line.append(word)
			line_w = trial_w
		else:
			_draw_line(font, line, cursor_y, ascent)
			cursor_y += line_h
			available_w = _width_at(cursor_y, line_h)
			line = [word]
			line_w = word_w
	if not line.is_empty():
		_draw_line(font, line, cursor_y, ascent)
		cursor_y += line_h
	return cursor_y


func _width_at(line_top: float, line_h: float) -> float:
	var total: float = size.x
	if image_width <= 0.0 or image_height <= 0.0:
		return total
	var line_bottom: float = line_top + line_h
	var r_bottom: float = image_height + image_padding
	if line_top >= r_bottom or line_bottom <= 0.0:
		return total
	var r_left: float = total - image_width - image_padding
	return maxf(0.0, r_left)


func _draw_line(
		font: Font,
		words: Array[String],
		y: float,
		ascent: float) -> void:
	var line_str: String = " ".join(words)
	draw_string(
		font,
		Vector2(0, y + ascent),
		line_str,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		font_color)
