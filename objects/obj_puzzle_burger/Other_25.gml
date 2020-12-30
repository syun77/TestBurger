/// @description Create Question.

enum ePuzzleBurgerTest {
	None,
	Open,
	Corner,
	Red,
	Green,
	Blue,
};

// initialize.
event_user(ePuzzleBurgerUser.Init);


var get_count = function() {
	if(_stage < 3) {
		return _stage;
	}
	else {
		return _stage * 2;
	}
};

var check_walk = function(grid, i, j, dx, dy) {
	var sx = i;
	var sy = j;
	var ex = i + dx;
	var ey = j + dy;
	
	if(grid[# i, j] != ePuzzleBurgerTest.None) {
		return false;
	}
	if(ex < 0 or _grid_w <= ex or ey < 0 or _grid_h <= ey) {
		return false;
	}
	
	while(sx != ex) {
		sx = lerp_abs(sx, ex, 1);
		if(grid[# sx, j] != ePuzzleBurgerTest.None) {
			return false;
		}
	}
	while(sy != ey) {
		sy = lerp_abs(sy, ey, 1);
		if(grid[# i, sy] != ePuzzleBurgerTest.None) {
			return false;
		}
	}
	
	return true;
};

var search = function(check_walk, grid, i, j, p_list, distance) {
	var rnd_dir = function(v) {
		if(v < 0) { v = 1; }
	
		var dx = 0;
		var dy = 0;
		if(irandom_range(0, 1)) {
			if(irandom_range(0, 1)) {
				dx = irandom_range(1,  v);
			}
			else {
				dx = -irandom_range(1,  v);
			}
		}
		else {
			if(irandom_range(0, 1)) {
				dy = irandom_range(1,  v);
			}
			else {
				dy = -irandom_range(1,  v);
			}
		}
	
		return [dx, dy];
	};
	
	var p_list_exists = function(p_list, i, j) {
		for(var idx = 0; idx < p_list.size(); idx++) {
			var p = p_list.get(idx);
			if(p[0] == i and p[1] == j) {
				return true;
			}
		}
		return false;
	}
	
	var limit = 30;
	
	for(var idx = 0; idx < 2; idx++) {
		var cnt_loop = 0;
		while(cnt_loop < limit) {
			var p  = rnd_dir(distance);
			var dx = p[0];
			var dy = p[1];
			if(p_list_exists(p_list, i+dx, j+dy) == false) {
				// not exists.
				if(check_walk(grid, i, j, dx, dy)) {
					// can put.
					p_list.add([i+dx, j+dy]);
					break;
				}
			}
			cnt_loop++;
		}
		if(cnt_loop >= limit) {
			return false;
		}
	}
	
	return true;
};

var put_tile = function(grid, i, j, ex, ey, tile) {
	var sx = i;
	var sy = j;
	while(sx != ex) {
		sx = lerp_abs(sx, ex, 1);
		if(grid[# sx, ey] == ePuzzleBurgerTest.None) {
			grid[# sx, ey] = ePuzzleBurgerTest.Open;
		}
	}
	while(sy != ey) {
		sy = lerp_abs(sy, ey, 1);
		if(grid[# ex, sy] == ePuzzleBurgerTest.None) {
			grid[# ex, sy] = ePuzzleBurgerTest.Open;
		}
	}
	
	grid[# ex, ey] = tile;
}

var grid = ds_grid_create(_grid_w, _grid_h);
var p_list = new MyList();
var cnt = get_count();
var distance = cnt;
if(distance > 4) {
	distance = 4;
}

for(var idx = 0; idx < cnt; idx++) {
	p_list.clear();
	var cnt_loop = 0;
	while(cnt_loop < 100) {
		var i = irandom_range(0, _grid_w-1);
		var j = irandom_range(0, _grid_h-1);
		if(grid[# i, j] == ePuzzleBurgerTest.None) {
			p_list.add([i, j]);
			if(search(check_walk, grid, i, j, p_list, distance)) {
				// can put tile.
				grid[# i, j] = ePuzzleBurgerTest.Red;
				var p1 = p_list.get(0);
				var p2 = p_list.get(1);
				var p3 = p_list.get(2);
				show_debug_message(string(p1) + " " + string(p2) + " " + string(p3));
				put_tile(grid, p1[0], p1[1], p2[0], p2[1], ePuzzleBurgerTest.Green);
				put_tile(grid, p2[0], p2[1], p3[0], p3[1], ePuzzleBurgerTest.Blue);
			}
			break;
		}
		cnt_loop++;
	}
}

for(var j = 0; j < _grid_h; j++) {
	for(var i = 0; i < _grid_w; i++) {
		switch(grid[# i, j]) {
		case ePuzzleBurgerTest.Red:
			_grid[# i, j] = ePuzzleBurgerTile.Red;
			break;
		case ePuzzleBurgerTest.Green:
			_grid[# i, j] = ePuzzleBurgerTile.Green;
			break;
		case ePuzzleBurgerTest.Blue:
			_grid[# i, j] = ePuzzleBurgerTile.Blue;
			break;
		}
	}
}

delete p_list;
ds_grid_destroy(grid);


/*
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
*/
