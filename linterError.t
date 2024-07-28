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
	helpMsg = nil
	idx = nil

	construct(msg, h?, v?) { message = msg; helpMsg = h; idx = v; }
	report(prefix) {
		return('<<prefix>> <<(idx ? toString(idx) : '')>>:
			<<message>>');
	}
	help() { return(helpMsg); }
;

// Class for errors.  Created by Linter.error()
class LinterError: LinterObject;

// Class for warnings.  Created by Linter.warning()
class LinterWarning: LinterObject;

class LinterInfo: LinterObject;
