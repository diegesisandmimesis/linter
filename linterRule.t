#charset "us-ascii"
//
// linterRule.t
//
#include <adv3.h>
#include <en_us.h>

class _LintRule: object
	error(msg) { if(linter) linter.error(msg); }
	warning(msg) { if(linter) linter.warning(msg); }
	info(msg) { if(linter) linter.info(msg); }

	setFlag(id) { if(linter) linter.setFlag(id); }
;

class LintClass: _LintRule
	lintClass = nil
	linter = nil


	executeLintRule(lntr) {
		if(lintClass == nil)
			return;

		linter = lntr;

		forEachInstance(lintClass, function(o) { lintAction(o); });
	}

	lintAction(obj) {}
;

class LintRule: _LintRule
	lintFlags = nil
	executeLintRule(lntr) {
		if((lintFlags == nil) || (lntr == nil))
			return;

		linter = lntr;

		if(lntr.checkFlags(lintFlags))
			lintAction();
	}
	lintAction() {}
;
