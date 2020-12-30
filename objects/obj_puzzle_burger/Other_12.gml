/// @description ゲームクリア.
if(_cnt > 60) {
	_stage++;
	event_user(ePuzzleBurgerUser.CreateQuestion);
	_state = ePuzzleBurgerState.Main;
	//_state = ePuzzleBurgerState.End;
}
