function fill_rect2(px, py, w, h, color, alpha) {
	var prev_color = draw_get_color();
	var prev_alpha = draw_get_alpha();

	draw_set_color(color);
	draw_set_alpha(alpha);

	draw_rectangle(px, py, px+w, py+h, false);

	draw_set_color(prev_color);
	draw_set_alpha(prev_alpha);
}

function fill_circle(cx, cy, radius, color, alpha) {
	var prev_alpha = draw_get_alpha();
	var prev_color = draw_get_color();
	draw_set_alpha(alpha);
	draw_set_color(color);
	draw_circle(cx, cy, radius, false);
	draw_set_alpha(prev_alpha);
	draw_set_color(prev_color);
};