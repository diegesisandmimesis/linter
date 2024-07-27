#charset "us-ascii"
//
// linterDefaults.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "linter.h"

modify Linter
	defaultRules = static [ weakTokensLinter ]
;
