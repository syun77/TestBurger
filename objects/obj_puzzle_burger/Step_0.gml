/// @description Insert description here
// You can write your code in this editor
_cnt++;

if(keyboard_check_pressed(ord("R"))) {
	game_restart();
}

switch(_state) {
case ePuzzleBurgerState.Main:
	event_user(ePuzzleBurgerUser.Main);
	break;
case ePuzzleBurgerState.Completed:
	event_user(ePuzzleBurgerUser.Completed);
	break;
case ePuzzleBurgerState.End:
	instance_destroy();
	break;
}

