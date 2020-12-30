/// @description Insert description here
// You can write your code in this editor

#macro PUZZLE_BURGER_COLOR_NONE (c_black)

// tile type.
enum ePuzzleBurgerTile {
	None = 0,
	Red,
	Green,
	Blue,
};

// line type
enum ePuzzleBurgerLine {
	None          = 0x00,
	Horizontal    = 0x01,
	Vertical      = 0x02,
	Cross         = 0x04,
	CrossLeft     = 0x04,
	CrossTop      = 0x08,
	CrossRight    = 0x10,
	CrossBottom   = 0x20,
};


// answer type.
enum ePuzzleBurgerAnswer {
	None,
	Open,
	Incorrect,
	Correct,
};

enum ePuzzleBurgerDir {
	None   = -1,
	
	Left   = 0,
	Top    = 1,
	Right  = 2,
	Bottom = 3,
	
	Max,
};

enum ePuzzleBurgerTapState {
	None,
	Tapping,
};

enum ePuzzleBurgerState {
	Main,
	Completed,
	End,
};

// user events.
enum ePuzzleBurgerUser {
	CalculateCorrect = 0,
	Main             = 1,
	Completed        = 2,
};

// properties.
_ofs_x = 256;
_ofs_y = 96;
_size  = 96;
_grid_w = 10;
_grid_h = 6;

_color_red       = c_red;
_color_green     = c_green;
_color_blue      = c_blue;
_color_selected  = c_yellow;
_color_correct   = c_aqua;
_color_incoreect = c_red;

_cnt = 0;
_state = ePuzzleBurgerState.Main;
_completed = false;

// grid.
_grid        = ds_grid_create(_grid_w, _grid_h);
_grid_line   = ds_grid_create(_grid_w, _grid_h);
_grid_answer = ds_grid_create(_grid_w, _grid_h);
_line_list = new MyList();

_tap = ePuzzleBurgerTapState.None;
_start_idx_x = noone;
_start_idx_y = noone;

// test data.
_grid[# 6, 3] = ePuzzleBurgerTile.Red;
_grid[# 4, 4] = ePuzzleBurgerTile.Green;
_grid[# 2, 0] = ePuzzleBurgerTile.Blue;
_grid[# 2, 3] = ePuzzleBurgerTile.Red;
_grid[# 5, 3] = ePuzzleBurgerTile.Green;
_grid[# 6, 4] = ePuzzleBurgerTile.Blue;
_grid[# 0, 0] = ePuzzleBurgerTile.Red;
_grid[# 5, 5] = ePuzzleBurgerTile.Green;
_grid[# 0, 5] = ePuzzleBurgerTile.Blue;

_grid[# 3, 5] = ePuzzleBurgerTile.Red;
_grid[# 4, 2] = ePuzzleBurgerTile.Green;
_grid[# 1, 4] = ePuzzleBurgerTile.Blue;

// functions.

_get_tile_type = function(i, j) {
	if(i < 0 || _grid_w <= i || j < 0 || _grid_h <= j) {
		return ePuzzleBurgerTile.None;
	}
	
	return _grid[# i, j];
}
// 
_get_tile_color = function(i, j) {
	var v = _get_tile_type(i, j);
	switch(v) {
	case ePuzzleBurgerTile.Red:   return _color_red;
	case ePuzzleBurgerTile.Green: return _color_green;
	case ePuzzleBurgerTile.Blue:  return _color_blue;
	default:                      return PUZZLE_BURGER_COLOR_NONE;
	}
};

_to_dir = function(dx, dy) {
	if(dx < 0) return ePuzzleBurgerDir.Left;
	if(dx > 0) return ePuzzleBurgerDir.Right;
	if(dy < 0) return ePuzzleBurgerDir.Top;
	if(dy > 0) return ePuzzleBurgerDir.Bottom;
	
	return ePuzzleBurgerDir.None;
};

_invert_dir = function(dir) {
	switch(dir) {
	case ePuzzleBurgerDir.Left:   return ePuzzleBurgerDir.Right;
	case ePuzzleBurgerDir.Top:    return ePuzzleBurgerDir.Bottom;
	case ePuzzleBurgerDir.Right:  return ePuzzleBurgerDir.Left;
	case ePuzzleBurgerDir.Bottom: return ePuzzleBurgerDir.Top;
	default: return ePuzzleBurgerDir.None;
	}
};

_dir_to_line_cross = function(dir) {
	switch(dir) {
	case ePuzzleBurgerDir.Left:   return ePuzzleBurgerLine.CrossLeft;
	case ePuzzleBurgerDir.Top:    return ePuzzleBurgerLine.CrossTop;
	case ePuzzleBurgerDir.Right:  return ePuzzleBurgerLine.CrossRight;
	case ePuzzleBurgerDir.Bottom: return ePuzzleBurgerLine.CrossBottom;
	default: return ePuzzleBurgerLine.None;
	}
};

_is_line_cross = function(i, j) {
	var t = _get_line_type(i, j);
	return t >= ePuzzleBurgerLine.Cross;
};
_can_connect_line = function(i, j) {
	var t = _get_line_type(i, j);
	switch(t) {
	case ePuzzleBurgerLine.Horizontal:
	case ePuzzleBurgerLine.Vertical:
		return false;
	default:
		return true;
	}
}
_is_line_left = function(i, j) {
	var t = _get_line_type(i, j);
	return t & ePuzzleBurgerLine.CrossLeft;
};
_is_line_top = function(i, j) {
	var t = _get_line_type(i, j);
	return t & ePuzzleBurgerLine.CrossTop;
};
_is_line_right = function(i, j) {
	var t = _get_line_type(i, j);
	return t & ePuzzleBurgerLine.CrossRight;
};
_is_line_bottom = function(i, j) {
	var t = _get_line_type(i, j);
	return t & ePuzzleBurgerLine.CrossBottom;
};
_has_line_dir = function(i, j, dir) {
	switch(dir) {
	case ePuzzleBurgerDir.Left:   return _is_line_left(i, j);
	case ePuzzleBurgerDir.Top:    return _is_line_top(i, j);
	case ePuzzleBurgerDir.Right:  return _is_line_right(i, j);
	case ePuzzleBurgerDir.Bottom: return _is_line_bottom(i, j);
	default: return false;
	}
}

_for_each_line_around = function(i, j, func) {
	var x_tbl = [-1,  0, 1, 0];
	var y_tbl = [ 0, -1, 0, 1];
	for(var idx = 0; idx < 4; idx++) {
		var t = _get_line_type(i + x_tbl[idx], j + y_tbl[idx]);
		func(i, j, idx, t);
	}
};

_set_line_cross_from_around = function(i, j, idx, t) {
	var v = _get_tile_color(i, j);
	if(v == PUZZLE_BURGER_COLOR_NONE) {
		return;
	}
	
	switch(idx) {
	case ePuzzleBurgerDir.Left: // left
		if(t == ePuzzleBurgerLine.Horizontal) {
			_grid_line[# i, j] |= ePuzzleBurgerLine.CrossLeft;
		}
		break;
	case ePuzzleBurgerDir.Top: // top.
		if(t == ePuzzleBurgerLine.Vertical) {
			_grid_line[# i, j] |= ePuzzleBurgerLine.CrossTop;
		}
		break;
	case ePuzzleBurgerDir.Right: // right
		if(t == ePuzzleBurgerLine.Horizontal) {
			_grid_line[# i, j] |= ePuzzleBurgerLine.CrossRight;
		}
		break;
	case ePuzzleBurgerDir.Bottom: // bottom.
		if(t == ePuzzleBurgerLine.Vertical) {
			_grid_line[# i, j] |= ePuzzleBurgerLine.CrossBottom;
		}
		break;
	}
};

_set_line = function(i, j, tile_type, dir) {
	var v = _get_tile_color(i, j);
	if(v != PUZZLE_BURGER_COLOR_NONE) {
		// cross
		_grid_line[# i, j] |= _dir_to_line_cross(dir);
		_for_each_line_around(i, j, _set_line_cross_from_around);
	}
	else {
		_grid_line[# i, j] = tile_type;
		switch(tile_type) {
		case ePuzzleBurgerLine.Horizontal:
			_set_line_cross_from_around(i-1, j, ePuzzleBurgerDir.Right, tile_type);
			_set_line_cross_from_around(i+1, j, ePuzzleBurgerDir.Left,  tile_type);
			break;
			
		case ePuzzleBurgerLine.Vertical:
			_set_line_cross_from_around(i, j-1, ePuzzleBurgerDir.Bottom, tile_type);
			_set_line_cross_from_around(i, j+1, ePuzzleBurgerDir.Top,    tile_type);
			break;
		}
	}
};

_get_line_type = function(i, j) {
	if(i < 0 || _grid_w <= i || j < 0 || _grid_h <= j) {
		return ePuzzleBurgerLine.None;
	}
	return _grid_line[# i, j];
};

_get_line_color = function(i, j) {
	switch(_get_answer_type(i, j)) {
	case ePuzzleBurgerAnswer.Correct:
		return _color_correct;
		
	case ePuzzleBurgerAnswer.Incorrect:
		return _color_incoreect;
	
	default:
		return PUZZLE_BURGER_COLOR_NONE;
	}
};

_get_answer_type = function(i, j) {
	if(i < 0 || _grid_w <= i || j < 0 || _grid_h <= j) {
		return ePuzzleBurgerAnswer.None;
	}
	return _grid_answer[# i, j];
};

_get_x = function(i) {
	return _ofs_x + (_size * i);
};
_get_y = function(j) {
	return _ofs_y + (_size * j);
};
_get_cx = function(i) {
	return _get_x(i) + _size/2;
};
_get_cy = function(j) {
	return _get_y(j) + _size/2;
};
_to_idx_x = function(px) {
	var idx = floor((px - _ofs_x) / _size);
	return (idx < _grid_w) ? idx : -1;
};
_to_idx_y = function(py) {
	var idx = floor((py - _ofs_y) / _size);
	return (idx < _grid_h) ? idx : -1;
};
_can_put = false;
_can_put_idx = function(sx, sy, ex, ey) {
	if(sx < 0 or sy < 0 or ex < 0 or ey < 0) {
		return false;
	}
	
	var dx = abs(ex - sx);
	var dy = abs(ey - sy);
	if(dx == 0 and dy == 0) {
		return false;
	}
	if(dx > 0 and dy > 0) {
		return false;
	}
	
	return true;
};

_put_line = function(p1, p2) {
	var px = p1._x;
	var py = p1._y;
	var dx = p2._x - px;
	var dy = p2._y - py;
	var tile_type = (abs(dx) > 0) ? ePuzzleBurgerLine.Horizontal : ePuzzleBurgerLine.Vertical;
	var dir = _to_dir(dx, dy);
	_set_line(px, py, tile_type, dir);
	
	dir = _invert_dir(dir);
	while(px != p2._x or py != p2._y) {
		px = lerp_abs(px, p2._x, 1);
		py = lerp_abs(py, p2._y, 1);
		_set_line(px, py, tile_type, dir);
	}
};

_is_hit_line_list = function(i, j) {
	if(_line_list.size() < 2) {
		return false;
	}
	var cx = _get_cx(i);
	var cy = _get_cy(j);
	var p1 = _line_list.get(0);
	for(var idx = 1; idx < _line_list.size(); idx++) {
		var p2 = _line_list.get(idx);
		if(p1.eq(i, j) == false) {
			var x1 = _get_cx(p1._x) - 1;
			var y1 = _get_cy(p1._y) - 1;
			var x2 = _get_cx(p2._x) + 1;
			var y2 = _get_cy(p2._y) + 1;
			if(point_in_rectangle(cx, cy, x1, y1, x2, y2)) {
				return true;
			}
		}
		p1 = p2;
	}
	
	return false;
};

_can_erase_cross = function(i, j) {
	var x_tbl = [-1,  0, 1, 0];
	var y_tbl = [ 0, -1, 0, 1];
	for(var idx = 0; idx < 4; idx++) {
		var dx = x_tbl[idx];
		var dy = y_tbl[idx];
		var i2 = i + dx;
		var j2 = j + dy;
		var dir = _to_dir(dx, dy);
		var t   = _get_line_type(i2, j2);
		switch(t) {
		case ePuzzleBurgerLine.Horizontal:
			if(abs(dx) > 0) {
				return false; // can't erase.
			}
			break;
		
		case ePuzzleBurgerLine.Vertical:
			if(abs(dy) > 0) {
				return false; // can't erase.
			}
			break;
			
		default:
			switch(dir) {
			case ePuzzleBurgerDir.Left:
				if(_is_line_right(i2, j2)) {
					return false;
				}
				break;
			case ePuzzleBurgerDir.Top:
				if(_is_line_bottom(i2, j2)) {
					return false;
				}
				break;
			case ePuzzleBurgerDir.Right:
				if(_is_line_left(i2, j2)) {
					return false;
				}
				break;
			case ePuzzleBurgerDir.Bottom:
				if(_is_line_top(i2, j2)) {
					return false;
				}
				break;
			}
			break;
		}
	}
	
	// can erase.
	return  true;
};

_erase_line = function(i, j, line_type, dir) {
	var v = _get_line_type(i, j);
	if(v == ePuzzleBurgerLine.None) {
		return; // stop to erase.
	}
	
	switch(v) {
	case ePuzzleBurgerLine.Horizontal:
	case ePuzzleBurgerLine.Vertical:
		switch(line_type) {
		case ePuzzleBurgerLine.Horizontal:
		case ePuzzleBurgerLine.Vertical:
			if(v != line_type) {
				return; // don't match direction.
			}
			break;
		default:
			break;
		}
		break;
	default:
		break;
	}
	
	if(line_type != ePuzzleBurgerLine.None and _is_line_cross(i, j)) {
		if(_can_erase_cross(i, j)) {
			_grid_line[# i, j] = ePuzzleBurgerLine.None;
		}
		else {
			var get_erase_dir = function(dir) {
				switch(dir) {
				case ePuzzleBurgerDir.Left:   return ePuzzleBurgerLine.CrossRight;
				case ePuzzleBurgerDir.Top:    return ePuzzleBurgerLine.CrossBottom;
				case ePuzzleBurgerDir.Right:  return ePuzzleBurgerLine.CrossLeft;
				case ePuzzleBurgerDir.Bottom: return ePuzzleBurgerLine.CrossTop;
				default: return ePuzzleBurgerLine.None;
				}
			};
			var t = get_erase_dir(dir);
			_grid_line[# i, j] &= ~t;
		}
		return; // stop to erase.
	}
	
	_grid_line[# i, j] = ePuzzleBurgerLine.None;
	var x_tbl = [-1,  0, 1, 0];
	var y_tbl = [ 0, -1, 0, 1];
	for(var idx = 0; idx < 4; idx++) {
		var dx = x_tbl[idx];
		var dy = y_tbl[idx];
		var dir2 = _to_dir(dx, dy);
		var t = abs(dx) > 0 ? ePuzzleBurgerLine.Horizontal : ePuzzleBurgerLine.Vertical;
		_erase_line(i + dx, j + dy, t, dir2);
	}
};
