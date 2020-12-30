/// @description 生成.

#macro PUZZLE_BURGER_COLOR_NONE (c_black)

// タイル種別.
enum ePuzzleBurgerTile {
	None = 0, // なし.
	Red,      // 赤タイル.
	Green,    // 緑タイル.
	Blue,     // 青タイル.
};

// ライン種別
enum ePuzzleBurgerLine {
	None          = 0x00, // なし.
	Horizontal    = 0x01, // 横方向へ接続する線.
	Vertical      = 0x02, // 縦方向に接続する線.
	Cross         = 0x04, // 十字IDの開始.
	CrossLeft     = 0x04, // 十字 (左に接続).
	CrossTop      = 0x08, // 十字 (上に接続).
	CrossRight    = 0x10, // 十字 (右に接続).
	CrossBottom   = 0x20, // 十字 (下に接続).
};


// 答え種.
enum ePuzzleBurgerAnswer {
	None,      // なし.
	Open,      // 判定中.
	Incorrect, // 不正解.
	Correct,   // 正解.
};

// 方向.
enum ePuzzleBurgerDir {
	None   = -1, // なし.
	
	Left   = 0,  // 左.
	Top    = 1,  // 上.
	Right  = 2,  // 右.
	Bottom = 3,  // 下.
	
	Max,
};

// タップ状態.
enum ePuzzleBurgerTapState {
	None,    // 操作なし.
	Tapping, // スワイプ中.
};

// 状態.
enum ePuzzleBurgerState {
	Main,      // メインゲーム中.
	Completed, // ゲームクリア.
	End,       // 終了.
};

// ユーザー定義イベント.
enum ePuzzleBurgerUser {
	CalculateCorrect = 0,  // 正解判定.
	
	Main             = 1,  // メインゲーム.
	Completed        = 2,  // ゲームクリア.
	
	Init             = 14, // 初期化.
	CreateQuestion   = 15, // 問題作成.
};

// プロパティ.
#region
_ofs_x  = 256; // ゲームエリアの左上座標(X).
_ofs_y  = 64;  // ゲームエリアの左上座標(Y).
_size   = 96;  // 1つあたりのタイルのサイズ.
_grid_w = 10;  // フィールドの幅.
_grid_h = 6;   // フィールドの高さ.

// 色定数.
_color_red       = c_red;    // 赤タイルの色.
_color_green     = c_green;  // 緑タイルの色.
_color_blue      = c_blue;   // 青タイルの色.
_color_selected  = c_yellow; // ラインを引く場所を選択しているときの色.
_color_correct   = c_aqua;   // 正解時のラインの色.
_color_incoreect = c_red;    // 不正解時のラインの色.
#endregion

_stage = 1; // ステージ数.
_state = ePuzzleBurgerState.Main;
_cnt = 0;
_completed = false; // ゲームクリアしたかどうか.

// グリッド.
_grid        = ds_grid_create(_grid_w, _grid_h); // タイル.
_grid_line   = ds_grid_create(_grid_w, _grid_h); // タイル接続情報.
_grid_answer = ds_grid_create(_grid_w, _grid_h); // 正解判定情報.
_line_list   = new MyList(); // 接続先選択中 (ePuzzleBurgerTapState.Tap) のライン情報.

_tap = ePuzzleBurgerTapState.None;
_start_idx_x = noone; // 接続開始座標(X).
_start_idx_y = noone; // 接続開始座標(Y)
_can_put     = false; // ラインを設定できるかどうか (タップ中に使用する)

// create question.
event_user(ePuzzleBurgerUser.CreateQuestion);

// functions.

/// @description 座標指定でタイル情報を取得.
/// @param i,j position.
/// @return タイル種別 (ePuzzleBurgerTile).
_get_tile_type = function(i, j) {
	if(i < 0 || _grid_w <= i || j < 0 || _grid_h <= j) {
		return ePuzzleBurgerTile.None;
	}
	
	return _grid[# i, j];
}

/// @description 座標指定でタイルの色を取得
/// @param i,j position
/// @return タイルの色.
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

/// @description 方向を十字定数に変換
/// @param idx 方向 (ePuzzleBurgerDir)
/// @return 十字定数 (ePuzzleBurgerLine.Cross[Left/Top/Right/Bottom])
_dir_to_line_cross = function(dir) {
	switch(dir) {
	case ePuzzleBurgerDir.Left:   return ePuzzleBurgerLine.CrossLeft;
	case ePuzzleBurgerDir.Top:    return ePuzzleBurgerLine.CrossTop;
	case ePuzzleBurgerDir.Right:  return ePuzzleBurgerLine.CrossRight;
	case ePuzzleBurgerDir.Bottom: return ePuzzleBurgerLine.CrossBottom;
	default: return ePuzzleBurgerLine.None;
	}
};

/// @description 指定の座標が十字ラインかどうか.
/// @param i,j position
/// @return いずれかの十字ラインであれば true.
_is_line_cross = function(i, j) {
	var t = _get_line_type(i, j);
	return t >= ePuzzleBurgerLine.Cross;
};
	
/// @description 指定の座標にラインを接続できるかどうか.
/// @param i,j position
/// @return 接続できれば true.
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

/// @description 指定の方向に対応する十字の方向を追加する
/// @param i,j position
/// @param idx 方向 (ePuzzleBurgerDir)
/// @param t   Horizontal or Vertical
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

/// @description タイル種別と方向に基づいてラインを設定する
/// @param i,j       position
/// @param tile_type タイル種別 (ePuzzleBurgerTile)
/// @param dir       方向 (ePuzzleBurgerDir)
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
			// 左右に接続する.
			_set_line_cross_from_around(i-1, j, ePuzzleBurgerDir.Right, tile_type);
			_set_line_cross_from_around(i+1, j, ePuzzleBurgerDir.Left,  tile_type);
			break;
			
		case ePuzzleBurgerLine.Vertical:
			// 上下に接続する.
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

/// @description インデックス座標系をワールド座標系に変換(X). 
_get_x = function(i) {
	return _ofs_x + (_size * i);
};
/// @description インデックス座標系をワールド座標系に変換(Y). 
_get_y = function(j) {
	return _ofs_y + (_size * j);
};
/// @description インデックス座標系をワールド座標系中心座標に変換(X).
_get_cx = function(i) {
	return _get_x(i) + _size/2;
};
/// @description インデックス座標系をワールド座標系中心座標に変換(Y).
_get_cy = function(j) {
	return _get_y(j) + _size/2;
};
/// @description ワールド座標をインデックス座標系に変換(X).
_to_idx_x = function(px) {
	var idx = floor((px - _ofs_x) / _size);
	return (idx < _grid_w) ? idx : -1;
};
/// @description ワールド座標をインデックス座標系に変換(Y).
_to_idx_y = function(py) {
	var idx = floor((py - _ofs_y) / _size);
	return (idx < _grid_h) ? idx : -1;
};

/// @description ラインを引ける開始座標と終了座標かどうか.
/// @param sx,sy 開始座標.
/// @param ex,ey 終了座標.
/// @return 引くことができれば true
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

/// @description ラインを配置 (MyPoint構造体を使用)
/// @param p1 開始座標(MyPoint).
/// @param p2 終了座標(MyPoint).
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

/// @description 指定の座標がラインリスト(仮置のライン)に接触するかどうか
/// @param i,j position
/// @return 接触していたら(配置できないなら) true
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

/// @description 指定座標の十字を消去できるかどうか.
/// @param i,j position.
/// @return 去できる場合 true
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

/// @description 指定座標のラインを消去する.
/// @param i,j       position.
/// @param tile_type タイル種別 (ePuzzleBurgerTile)
/// @param dir       方向 (ePuzzleBurgerDir)
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
