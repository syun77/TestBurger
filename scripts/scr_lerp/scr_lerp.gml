// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function lerp_abs(a, b, amt) {
	if(a == b) {
		return a;
	}
	
	var d = abs(amt);
	if(a < b) {
		return min(a + d, b);
	}
	else {
		return max(a - d, b);
	}
}