function MyPoint(px, py) constructor {
	// members.
	_x = int64(px);
	_y = int64(py);

	// functions.
	static set = function(px, py) {
		_x = int64(px);
		_y = int64(py);
	};
	
	static add = function(p) {
		_x += int64(p._x);
		_y += int64(p._y);
	};
	
	static sub = function(p) {
		_x -= int64(p._x);
		_y -= int64(p._y);
	};
	
	static eq = function(px, py) {
		if(int64(_x) == int64(px) and int64(_y) == int64(py)) {
			return true;
		}
		return false;
	}
};
