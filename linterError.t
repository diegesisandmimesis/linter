#charset "us-ascii"
//
// linterError.t
//
//	Class definitions for error and warning objects.
//
//	There are two methods to worry about:
//
//		construct(msg)	takes a single argument, which is
//				saved to the message property
//		report(linter)	takes a single argument, which is the
//				linter calling the method.  This method
//				should output whatever the error or warning
//				has to report.
//
//	As written below these are just wrappers around a text literal, but
//	in theory the "message" could be arbitrary data and the report
//	could be more elaborate.
//
#include <adv3.h>
#include <en_us.h>

class LinterObject: object
	message = nil

	construct(msg) { message = msg; }
	report(linter) { linter.log(message); }
;

// Class for errors.  Created by Linter.error()
class LinterError: LinterObject
	report(linter) { linter.logError(message); }
;

// Class for warnings.  Created by Linter.warning()
class LinterWarning: LinterObject
	report(linter) { linter.logWarning(message); }
;
