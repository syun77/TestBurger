/// @description Insert description here
// You can write your code in this editor
/// -------------------------------------------------------
/// @description draw outline
/// @param i
/// @param j
/// @param is_horizontal
/// @param dir
/// @param color
/// @param alpha
/// -------------------------------------------------------
_draw_outline_idx = function(i, j, is_horizontal, dir, color, alpha) {
	var thin = 4;
	var is_cross = _get_tile_color(i, j) != ePuzzleBurgerTile.None;
	var px     = _get_x(i);
	var py     = _get_y(j);
	var cx     = _get_cx(i);
	var cy     = _get_cy(j);
	var width  = _size;
	var height = _size;
	if(is_cross) {
		// cross.
		fill_rect2(px, py, width, thin, color, alpha);
		fill_rect2(px, py, thin, height, color, alpha);
		fill_rect2(px, py+height-thin, width, thin, color, alpha);
		fill_rect2(px+width-thin, py, thin, height, color, alpha);
		var dir_rate = 4;
		if(_is_line_left(i, j) or dir == ePuzzleBurgerDir.Left) {
			fill_rect2(px, cy-thin, thin*dir_rate, thin*2, color, alpha);
		}
		if(_is_line_top(i, j) or dir == ePuzzleBurgerDir.Top) {
			fill_rect2(cx-thin, py, thin*2, thin*dir_rate, color, alpha);
		}
		if(_is_line_right(i, j) or dir == ePuzzleBurgerDir.Right) {
			fill_rect2(px+width-thin*dir_rate, cy-thin, thin*dir_rate, thin*2, color, alpha);
		}
		if(_is_line_bottom(i, j) or dir == ePuzzleBurgerDir.Bottom) {
			fill_rect2(cx-thin, py+height-thin*dir_rate, thin*2, thin*dir_rate, color, alpha);
		}
	}
	else if(is_horizontal) {
		// horizontal.
		fill_rect2(px, cy-thin, width, thin*2, color, alpha);
	}
	else {
		// vertical.
		fill_rect2(cx-thin, py, thin*2, height, color, alpha);
	}
};

// draw bg.
fill_rect2(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, 0.5);

// draw grid.
#region
for(var i = 0; i < _grid_w + 1; i++) {
	var px = _get_x(i);
	var y1 = _get_y(0);
	var y2 = _get_y(_grid_h);
	draw_line(px, y1, px, y2);
}
for(var j = 0; j < _grid_h + 1; j++) {
	var py = _get_y(j);
	var x1 = _get_x(0);
	var x2 = _get_x(_grid_w);
	draw_line(x1, py, x2, py);
}
#endregion

// draw burger.
for(var j = 0; j < _grid_h; j++) {
	for(var i = 0; i < _grid_w; i++) {
		var tile_color = _get_tile_color(i, j);
		if(tile_color != PUZZLE_BURGER_COLOR_NONE) {
			var cx = _get_cx(i);
			var cy = _get_cy(j);
			fill_circle(cx, cy, _size*0.4, tile_color, 1);
		}
		
		var line_type  = _get_line_type(i, j);
		var line_color = _get_line_color(i, j);
		if(line_color != PUZZLE_BURGER_COLOR_NONE) {
			var is_horizontal = (line_type == ePuzzleBurgerLine.Horizontal);
			_draw_outline_idx(i, j, is_horizontal, ePuzzleBurgerDir.None, line_color, 1);
		}
	}
}

var idx_x = _to_idx_x(mouse_x);
var idx_y = _to_idx_y(mouse_y);
var is_valid_idx = _can_put_idx(_start_idx_x, _start_idx_y, idx_x, idx_y);

/// -------------------------------------------------------
/// @description draw line.
/// @param sx
/// @param sy
/// @param idx_x
/// @param color
/// @param dont_line_check
/// -------------------------------------------------------
var draw_connect_line = function(sx, sy, idx_x, idx_y, color, dont_line_check) {
	
	var dir = _to_dir(idx_x - sx, idx_y - sy);
	
	// start point.
	_draw_outline_idx(sx, sy, false, dir, color, 1);
	
	// horizontal.
	while(sx != idx_x) {
		var dx = idx_x - sx;
		var dir = _to_dir(dx, 0);
		sx = lerp_abs(sx, idx_x, 1);
		if(_has_line_dir(_invert_dir(dir))) {
			return false;
		}
		if(_can_connect_line(sx, idx_y) == false) {
			return false; // can't connect.
		}
		if(dont_line_check == false) {
			if(_is_hit_line_list(sx, idx_y)) {
				return false;
			}
		}
		_draw_outline_idx(sx, idx_y, true, _invert_dir(dir), color, 1);
	}
	
	// vertical.
	while(sy != idx_y) {
		var dy = idx_y - sy;
		var dir = _to_dir(0, dy);
		sy = lerp_abs(sy, idx_y, 1);
		if(_has_line_dir(_invert_dir(dir))) {
			return false;
		}
		if(_can_connect_line(idx_x, sy) == false) {
			return false; // can't connect.
		}
		if(dont_line_check == false) {
			if(_is_hit_line_list(idx_x, sy)) {
				return false;
			}
		}
		_draw_outline_idx(idx_x, sy, false, _invert_dir(dir), color, 1);
	}
	
	return true;
};

// draw fixed line.
if(_line_list.size() >= 2) {
	var p1 = _line_list.get(0);
	for(var i = 1; i < _line_list.size(); i++) {
		var p2 = _line_list.get(i);
		draw_connect_line(p1._x, p1._y, p2._x, p2._y, _color_selected, true);
		p1 = p2;
	}
}
else if(_line_list.size() == 1) {
	var p = _line_list.get(0);
	var dir = _to_dir(idx_x - p._x, idx_y - p._y);
	_draw_outline_idx(p._x, p._y, false, dir, _color_selected, 1);
}

_can_put = false;
if(_tap == ePuzzleBurgerTapState.Tapping) {
	if(is_valid_idx) {
		_can_put = draw_connect_line(_start_idx_x, _start_idx_y, idx_x, idx_y, _color_selected, false);
	}
}

// draw cursor.
if(idx_x >= 0 and idx_y >= 0) {
	var px = _get_x(idx_x);
	var py = _get_y(idx_y);
	var alpha = 0.2 + 0.3 * abs(dsin(_cnt * 2));
	fill_rect2(px, py, _size, _size, c_white, alpha);
}

