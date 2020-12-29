/// @description draw debug
draw_text(8, 8, "can put:" + (_can_put ? "true" : "false"));

for(var j = 0; j < _grid_h; j++) {
	var str1 = "";
	var str2 = "";
	var str3 = "";
	for(var i = 0; i < _grid_w; i++) {
		str1 += string(_grid[# i, j]) + " ";
		str2 += string(_get_line_type(i, j)) + " ";
		str3 += string(_get_answer_type(i, j)) + " ";
	}
	draw_text(8, 24 +12*j, str1);
	draw_text(8, 128+12*j, str2);
	draw_text(8, 256+12*j, str3);
}

for(var i = 0; i < _line_list.size(); i++) {
	var p = _line_list.get(i);
	draw_text(8, 384+12*i, "[" + string(i) + "] " + string(p._x) + ", " + string(p._y));
}
