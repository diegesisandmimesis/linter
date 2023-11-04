#charset "us-ascii"
//
// linterWerror.t
//
//	Changes for when we're compiled with -D WERROR, telling us
//	to treat warnings as errors.
//
//	We use a bespoke compiler flag because we can't just check if t3make
//	was called with -we (the compiler's own flag to treat warnings as
//	errors) because the compiler doesn't set a preprocessor flag for that
//	for us to check.
//
#include <adv3.h>
#include <en_us.h>

#ifdef WERROR

// We just toggle a property on the linter.
modify Linter
	werror = true
;

#endif // WERROR
