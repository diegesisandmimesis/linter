#charset "us-ascii"
//
// linterAction.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "linter.h"

#ifdef __DEBUG

enum eLintWarn, eLintErr, eLintInfo;

modify playerActionMessages
	lintActionBadNumber = 'Invalid lint message number. '
	lintActionMsgNotFound = 'No lint message found. '
	lintActionNoHelp = 'No further information available. '
;

class LintAction: SystemAction
	msgArray = nil

	execSystemAction() {
		local l, m, n;

		n = numMatch.getval();
		forEachInstance(Linter, function(o) {
			if(!o.active) return;
			l = o.(msgArray);
			if((n < 1) || (l.length < n)) {
				reportFailure(&lintActionBadNumber);
				exit;
			}
			if((m = l[n].help()) == nil)
				reportFailure(&lintActionNoHelp);
			else
				defaultReport(m);
			exit;
		});
		reportFailure(&lintActionMsgNotFound);
	}
;

DefineLintAction(LintError)
	msgArray = &_errors
;

DefineLintAction(LintWarning)
	msgArray = &_warnings
;

DefineLintAction(LintInfo)
	msgArray = &_info
;

VerbRule(LintError)
	'lint' ( 'error' | 'err' ) singleNumber
	: LintErrorAction
	verbPhrase = 'show/showing a lint error'
;
VerbRule(LintWarning)
	'lint' ( 'warning' | 'warn' ) singleNumber
	: LintWarningAction
	verbPhrase = 'show/showing a lint warning'
;
VerbRule(LintInfo)
	'lint' ( 'info' | 'information' ) singleNumber
	: LintInfoAction
	verbPhrase = 'show/showing a lint info message'
;

#endif // __DEBUG
