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
	testSuperclassOrder(obj, arg0, arg1) {
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

	superclassListIsABeforeB(obj, arg0, arg1) {
		return(testSuperclassOrder(obj, arg0, arg1));
	}

	// Returns the number of instances of cls.
	getInstanceCount(cls) {
		local i;

		i = 0;
		forEachInstance(cls, function(o) {
			i += 1;
		});

		return(i);
	}

	// Returns boolean true iff the argument is a singleton.
	isSingleton(cls) { return(getInstanceCount(cls) == 1); }

	// Returns boolean true if there are instances of the argument
	// with no location.
	checkForOrphans(cls) {
		local i;

		i = 0;
		forEachInstance(cls, function(o) {
			if(o.location == nil)
				i += 1;
		});

		return(i > 0);
	}

	// Iterates all instances of the first arg.  If fn is a method
	// or property, that method/property will be tested on each instance.
	// If fn is a function, it will be called with each instance as its
	// argument.
	// The return value is the number of instances for which the test
	// above did not return true.
	testInstanceProp(cls, fn) {
		local i;

		i = 0;
		forEachInstance(cls, function(o) {
			switch(dataTypeXlat(fn)) {
				case TypeProp:
					if(o.(fn)() != true)
						i += 1;
					break;
				case TypeFuncPtr:
					if(fn(cls) != true)
						i += 1;
					break;
			}
		});

		return(i == 0);
	}
;
