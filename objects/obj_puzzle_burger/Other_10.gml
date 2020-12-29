/// @description Calculate Correct.
ds_grid_clear(_grid_answer, ePuzzleBurgerAnswer.None);

_cnt_red   = 0;
_cnt_green = 0;
_cnt_blue  = 0;
_tmp_list = new MyList();

var reset_search = function() {
	_cnt_red   = 0;
	_cnt_green = 0;
	_cnt_blue  = 0;
	_tmp_list.for_each(function(p) {
		delete p;
	});
	_tmp_list.clear();
}

_search_correct = function(i, j, line_type) {
	var v = _get_answer_type(i, j);
	if(v != ePuzzleBurgerAnswer.None) {
		return; // don't check.
	}
	
	var t = _get_line_type(i, j); 
	switch(t) {
	case ePuzzleBurgerLine.Horizontal:
	case ePuzzleBurgerLine.Vertical:
		if(t != line_type) {
			return; // don't match direction.
		}
		break;
		
	case ePuzzleBurgerLine.None:
		return;
		
	default:
		if(_is_line_cross(i, j)) {
			switch(_get_tile_type(i, j)) {
			case ePuzzleBurgerTile.Red:
				_cnt_red++;
				break;
			case ePuzzleBurgerTile.Green:
				_cnt_green++;
				break;
			case ePuzzleBurgerTile.Blue:
				_cnt_blue++;
				break;
			}
		}
		break;
	}
	
	_grid_answer[# i, j] = ePuzzleBurgerAnswer.Open;
	var p = new MyPoint(i, j);
	_tmp_list.add(p);
	
	var x_tbl = [-1,  0, 1, 0];
	var y_tbl = [ 0, -1, 0, 1];
	for(var idx = 0; idx < 4; idx++) {
		var dx = x_tbl[idx];
		var dy = y_tbl[idx];
		var i2 = i + dx;
		var j2 = j + dy;
		var dir = _to_dir(dx, dy);
		switch(t) {
		case ePuzzleBurgerLine.Horizontal:
			if(abs(dx) == 0) {
				continue; // don't check.
			}
			break;
		case ePuzzleBurgerLine.Vertical:
			if(abs(dy) == 0) {
				continue; // don't check.
			}
			break;
		default:
			if(_has_line_dir(i, j, dir) == false) {
				continue; // can't move.
			}
			break;
		}
		_type = abs(dx) > 0 ? ePuzzleBurgerLine.Horizontal : ePuzzleBurgerLine.Vertical;
		_search_correct(i2, j2, _type);
	}
};

for(var j = 0; j < _grid_h; j++) {
	for(var i = 0; i < _grid_w; i++) {
		if(_is_line_cross(i, j) == false) {
			continue;
		}
		if(_get_answer_type(i, j) != ePuzzleBurgerAnswer.None) {
			continue; // don't check (already checked).
		}

		reset_search();
		_search_correct(i, j, ePuzzleBurgerLine.None);
		
		if(_cnt_red == 1 and _cnt_green == 1 and _cnt_blue == 1) {
			// correct.
			_tmp_list.for_each(function(p) {
				_grid_answer[# p._x, p._y] = ePuzzleBurgerAnswer.Correct;
			});
		}
		else {
			// incorrect.
			_tmp_list.for_each(function(p) {
				_grid_answer[# p._x, p._y] = ePuzzleBurgerAnswer.Incorrect;
			});
		}
	}
}

reset_search();
delete _tmp_list;
