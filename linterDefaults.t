#charset "us-ascii"
//
// linterDefaults.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "linter.h"

#ifdef __DEBUG

modify Linter
	defaultRules = static [
		weakTokensLinter,
		pluralMismatchLinter,
		nameAsOtherLinter,
		isEquivalentLinter
	]
;

#endif // __DEBUG
