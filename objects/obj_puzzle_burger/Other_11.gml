/// @description Main.
switch(_tap) {
case ePuzzleBurgerTapState.None:
	if(mouse_check_button_pressed(mb_left)) {
		var i = _to_idx_x(mouse_x);
		var j = _to_idx_y(mouse_y);
		var v = _get_tile_color(i, j);
		if(v != PUZZLE_BURGER_COLOR_NONE) {
			_start_idx_x = i;
			_start_idx_y = j;
			var p = new MyPoint(i, j);
			_line_list.add(p);
			_tap = ePuzzleBurgerTapState.Tapping;
		}
	}
	break;
	
case ePuzzleBurgerTapState.Tapping:
	var i = _to_idx_x(mouse_x);
	var j = _to_idx_y(mouse_y);
	if(_can_put_idx(_start_idx_x, _start_idx_y, i, j) and _can_put) {
		if(_get_tile_color(i, j) != PUZZLE_BURGER_COLOR_NONE) {
			if(_line_list.for_each_exists(function(p) {
				var i = _to_idx_x(mouse_x);
				var j = _to_idx_y(mouse_y);
				return p.eq(i, j);
			}) == false) {
				// next.
				var p = new MyPoint(i, j);
				_line_list.add(p);
				_start_idx_x = i;
				_start_idx_y = j;
			}
		}
	}

	if(mouse_check_button_released(mb_left)) {
		if(_line_list.size() >= 2) {
			var p1 = _line_list.get(0);
			for(var i = 1; i < _line_list.size(); i++) {
				var p2 = _line_list.get(i);
				_put_line(p1, p2);
				p1 = p2;
			}
		}
		else if(i == _start_idx_x and j == _start_idx_y) {
			// erase line.
			_erase_line(i, j, ePuzzleBurgerLine.None, ePuzzleBurgerDir.None);
		}
		
		_line_list.for_each(function(p) {
			delete p;
		});
		_line_list.clear();
		
		// check completed.
		event_user(ePuzzleBurgerUser.CalculateCorrect);
		
		_start_idx_x = noone;
		_start_idx_y = noone;
		_tap = ePuzzleBurgerTapState.None;
		
		if(_completed) {
			_cnt   = 0;
			_state = ePuzzleBurgerState.Completed;
		}
	}
	break;
}
