class_name TextWrap
extends Control
## Word-wraps text around rectangular avoid regions. Used by the How to Play
## overlay to get float-right/float-left image behavior that Godot's
## RichTextLabel does not support natively.
##
## Two schemas:
##   1. Legacy single-image: set `image_width` / `image_height` for a top-right
##      avoid region. Text fills the full width once it drops below the image.
##   2. Multi-region: set `regions` to an array of dictionaries, each with keys
##      `side` ("right" or "left"), `y_offset` (float), `width` (float),
##      `height` (float). Any number of regions supported; they should not
##      overlap horizontally at the same y range (text needs a path through).
##
## Single newlines are hard line breaks; double newlines produce a paragraph gap.
##
## Inline bold: wrap a phrase in `**` to render it faux-bold. The control draws
## each bold word twice with a 1px horizontal offset, so the effect works with
## the default theme font without requiring a separate bold font asset.

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

# Array[Dictionary]. Each entry: {side, y_offset, width, height}. When non-empty,
# this takes precedence over image_width/image_height.
var regions: Array = []:
	set(value):
		regions = value
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
			var tokens: Array = _tokenize_line(sl)
			cursor_y = _layout_tokens(font, tokens, cursor_y, line_h, space_w, ascent)
		if p_idx < paragraphs.size() - 1:
			cursor_y += para_gap


# Split a line on `**` bold markers and further on spaces into word tokens.
# Returns Array of {text: String, bold: bool}. Even-indexed segments (outside
# `**`) are non-bold; odd-indexed segments (between pairs of `**`) are bold.
func _tokenize_line(s: String) -> Array:
	var tokens: Array = []
	var parts: PackedStringArray = s.split("**")
	for i in range(parts.size()):
		var is_bold: bool = (i % 2) == 1
		var segment: String = parts[i]
		if segment.is_empty():
			continue
		var words: PackedStringArray = segment.split(" ")
		for w in words:
			if w.is_empty():
				continue
			tokens.append({"text": w, "bold": is_bold})
	return tokens


func _layout_tokens(
		font: Font,
		tokens: Array,
		start_y: float,
		line_h: float,
		space_w: float,
		ascent: float) -> float:
	var cursor_y: float = start_y
	var line: Array = []
	var line_w: float = 0.0
	var x_range: Vector2 = _line_x_range(cursor_y, line_h)
	var line_start_x: float = x_range.x
	var available_w: float = x_range.y - x_range.x
	for token in tokens:
		var word_w: float = _token_width(font, token)
		var trial_w: float = line_w + word_w
		if not line.is_empty():
			trial_w += space_w
		if line.is_empty() or trial_w <= available_w:
			line.append(token)
			line_w = trial_w
		else:
			_draw_line_tokens(font, line, line_start_x, cursor_y, ascent, space_w)
			cursor_y += line_h
			x_range = _line_x_range(cursor_y, line_h)
			line_start_x = x_range.x
			available_w = x_range.y - x_range.x
			line = [token]
			line_w = word_w
	if not line.is_empty():
		_draw_line_tokens(font, line, line_start_x, cursor_y, ascent, space_w)
		cursor_y += line_h
	return cursor_y


func _token_width(font: Font, token: Dictionary) -> float:
	var w: float = font.get_string_size(
		token["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	# Faux-bold draws twice with 1px horizontal offset, so the effective glyph
	# advance grows by 1px.
	if token["bold"]:
		w += 1.0
	return w


func _line_x_range(line_top: float, line_h: float) -> Vector2:
	var start_x: float = 0.0
	var end_x: float = size.x
	var line_bottom: float = line_top + line_h
	if not regions.is_empty():
		for r in regions:
			var r_top: float = float(r.get("y_offset", 0.0))
			var r_bottom: float = r_top + float(r.get("height", 0.0)) + image_padding
			if line_top >= r_bottom or line_bottom <= r_top:
				continue
			var w: float = float(r.get("width", 0.0))
			var side: String = String(r.get("side", "right"))
			if side == "right":
				end_x = minf(end_x, size.x - w - image_padding)
			elif side == "left":
				start_x = maxf(start_x, w + image_padding)
	elif image_width > 0.0 and image_height > 0.0:
		var r_bottom: float = image_height + image_padding
		if not (line_top >= r_bottom or line_bottom <= 0.0):
			end_x = size.x - image_width - image_padding
	if end_x < start_x:
		end_x = start_x
	return Vector2(start_x, end_x)


func _draw_line_tokens(
		font: Font,
		tokens: Array,
		x: float,
		y: float,
		ascent: float,
		space_w: float) -> void:
	var cur_x: float = x
	var baseline_y: float = y + ascent
	for i in range(tokens.size()):
		var token: Dictionary = tokens[i]
		var word_text: String = token["text"]
		var is_bold: bool = token["bold"]
		draw_string(
			font,
			Vector2(cur_x, baseline_y),
			word_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			font_color)
		if is_bold:
			# Second pass, offset 1px, to fake a heavier weight.
			draw_string(
				font,
				Vector2(cur_x + 1.0, baseline_y),
				word_text,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				font_size,
				font_color)
		cur_x += _token_width(font, token)
		if i < tokens.size() - 1:
			cur_x += space_w
