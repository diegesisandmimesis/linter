#charset "us-ascii"
//
// linterException.t
//
#include <adv3.h>
#include <en_us.h>

class LinterException: Exception
	linterMsg = nil

	construct(msg?) {
		linterMsg = msg;
	}
;
