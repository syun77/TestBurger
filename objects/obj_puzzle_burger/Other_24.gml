/// @description 初期化.
_cnt = 0;
_completed = false;
_tap = ePuzzleBurgerTapState.None;
_start_idx_x = noone;
_start_idx_y = noone;

ds_grid_clear(_grid, ePuzzleBurgerTile.None);
ds_grid_clear(_grid_line, ePuzzleBurgerLine.None);
ds_grid_clear(_grid_answer, ePuzzleBurgerAnswer.None);
_line_list.clear();

