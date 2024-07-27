#charset "us-ascii"
//
// linterRule.t
//
#include <adv3.h>
#include <en_us.h>

class _LintRule: object
	linter = nil

	error(msg) { if(linter) linter.error(msg); }
	warning(msg) { if(linter) linter.warning(msg); }
	info(msg) { if(linter) linter.info(msg); }

	setFlag(id) { if(linter) linter.setFlag(id); }
	addCounter(id) { if(linter) linter.addCounter(id); }
	getCounter(id) { return(linter ? linter.getCounter(id) : 0); }

	initLintRule() {
		if((location == nil) || !location.ofKind(Linter))
			return;
		location.addLintRule(self);
	}
;

class LintClass: _LintRule
	lintClass = nil
	linter = nil

	executeLintRule(lntr) {
		if(lntr && !linter) linter = lntr;

		if((lintClass == nil) || (linter == nil))
			return;

		forEachInstance(lintClass, function(o) { lintAction(o); });
	}

	lintAction(obj) {}
;

class LintRule: _LintRule
	executeLintRule(lntr) {
		if(lntr && !linter) linter = lntr;
		if(linter == nil)
			return;
		lintAction();
	}
	lintAction() {}
;

class LintFlags: _LintRule
	lintFlags = nil
	executeLintRule(lntr) {
		if(lntr && !linter) linter = lntr;

		if((lintFlags == nil) || (linter == nil))
			return;

		if(lntr.checkFlags(lintFlags))
			lintAction();
	}
	lintAction() {}
;
