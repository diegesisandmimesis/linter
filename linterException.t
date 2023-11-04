#charset "us-ascii"
//
// linterException.t
//
//	Class for the linter exception.
//
//	This isn't handled in any special way, it'll just halt the
//	interpreter with an "unknown exception".  Which is all we need
//	it to do.
//
#include <adv3.h>
#include <en_us.h>

class LinterException: Exception
	linterMsg = nil

	construct(msg?) {
		linterMsg = msg;
	}
;
