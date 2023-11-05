#charset "us-ascii"
//
// linterUtil.t
//
//	Utility methods for linters.
//
#include <adv3.h>
#include <en_us.h>

modify Linter
	// Returns boolean true if obj's superclass list contains the
	// class arg0 earlier than it includes arg1.
	superclassListIsABeforeB(obj, arg0, arg1) {
		local i, l;

		// Go through the superclass list, returning whenever we
		// match either arg.
		l = obj.getSuperclassList();
		for(i = 1; i <= l.length; i++) {
			// If we have an exact match of arg0, success.
			if(l[i] == arg0)
				return(true);

			// If we have a subclass of arg0, recurse.
			if(l[i].ofKind(arg0))
				return(superclassListIsABeforeB(l[i], arg0,
				arg1));

			// If we reach here and it's a subclass of arg1, no
			// fancy check needed (we know it's not ALSO a subclass
			// of arg0, or it would've been caught above), fail.
			if(l[i].ofKind(arg1))
				return(nil);
		}

		return(nil);
	}
;
