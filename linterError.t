#charset "us-ascii"
//
// linterError.t
//
#include <adv3.h>
#include <en_us.h>


class LinterObject: object
	message = nil

	construct(msg) { message = msg; }
	report(linter) { linter.log(message); }
;

class LinterError: LinterObject
	report(linter) { linter.logError(message); }
;
class LinterWarning: LinterObject
	report(linter) { linter.logWarning(message); }
;
