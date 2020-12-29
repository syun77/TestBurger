// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function MyList() constructor {
	_pool = ds_list_create();
	
	static destroy = function() {
		ds_list_destroy(_pool);
		_pool = noone;
	};
	
	static get = function(pos) {
		if(pos < 0 or size() <= pos) {
			return noone;
		}
		return _pool[| pos];
	}
	
	static last = function() {
		var pos = size();
		if(pos == 0) {
			return noone;
		}
		return _pool[| pos-1];
	};
	
	static clear = function() {
		ds_list_clear(_pool);
	};
	
	static add = function(d) {
		ds_list_add(_pool, d);
	};
	
	static size = function() {
		return ds_list_size(_pool);
	};
	
	static sort = function(ascending) {
		ds_list_sort(_pool, ascending);
	};
	
	static for_each = function(func) {
		for(var i = 0; i < size(); i++) {
			func(_pool[| i]);
		}
	};
	
	static for_each_if = function(func, cond) {
		for(var i = 0; i < size(); i++) {
			var d = _pool[| i];
			if(cond(d)) {
				func(d);
			}
			func(_pool[| i]);
		}
	};
	
	static for_each_exists = function(cond) {
		for(var i = 0; i < size(); i++) {
			if(cond(_pool[| i])) {
				return true;
			}
		}
		
		return false;
	};
	
	static remove = function(pos) {
		ds_list_delete(_pool, pos)
	};
	
	static read = function(str) {
		ds_list_read(_pool, str);
	};
	
	static write = function() {
		return ds_list_write(_pool);
	};
}