#charset "us-ascii"
//
// linterUtil.t
//
//	Utility methods for linters.
//
#include <adv3.h>
#include <en_us.h>

modify Linter

	superclassListIsABeforeB(obj, arg0, arg1) {
		local match0, match1;

		// Have we matched arg0 class yet?
		match0 = nil;

		// Have we match the arg1 class?
		match1 = nil;

		obj.getSuperclassList().forEach(function(cls) {
			if((match0 == true) || (match1 == true))
				return;

			if(cls == arg0) {
				match0 = true;
				return;
			}

			if(cls.ofKind(arg0)) {
				if(!superclassListIsABeforeB(cls, arg0, arg1))
					match1 = true;
				else
					match0 = true;
				return;
			}
			if(cls == arg1) {
				match1 = true;
				return;
			}
			if(cls.ofKind(arg1))
				if(!superclassListIsABeforeB(cls, arg0, arg1))
					match1 = true;
		});

		return(match0);
	}
;
