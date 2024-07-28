#charset "us-ascii"
//
// linterAction.t
//
//	Some simple debugging action declarations.
//
//	The commands and their usage(s) are:
//
//		>LINT ERROR [number]
//		>LINT WARNING [number]
//		>LINT INFO [number]
//
//	...where [number] is a message number reported by the linter.
//
//
#include <adv3.h>
#include <en_us.h>

#include "linter.h"

#ifdef __DEBUG

// Messages for the linter actions.
modify playerActionMessages
	lintActionBadNumber = 'Invalid lint message number. '
	lintActionMsgNotFound = 'No lint message found. '
	lintActionNoHelp = 'No further information available. '
;

// All of these lint actions take a numeric argument and then try
// to look up the corresponding message in the linter, displaying
// the extended help/information for that message if there is any.
class LintAction: SystemAction
	msgArray = nil

	execSystemAction() {
		local l, m, n;

		// We always need a numeric value.
		n = numMatch.getval();

		// Kludge.  In theory we could have multiple linters, so
		// we just look for the first active one.
		forEachInstance(Linter, function(o) {
			// Make sure the linter is active.
			if(!o.active) return;

			// Get the array we care about.
			l = o.(msgArray);

			// Make sure the numeric arg is a valid array
			// index.
			if((n < 1) || (l.length < n)) {
				reportFailure(&lintActionBadNumber);
				exit;
			}

			// If the requested message has help defined,
			// display it.  Otherwise we show a generic
			// "no further information" message.
			if((m = l[n].help()) == nil)
				reportFailure(&lintActionNoHelp);
			else
				defaultReport(m);
			exit;
		});

		// If we made it this far we didn't find a message,
		// complain.
		reportFailure(&lintActionMsgNotFound);
	}
;

// Lint action declarations.  The only difference between them is the
// array they query.
DefineLintAction(LintError) msgArray = &_errors;
DefineLintAction(LintWarning) msgArray = &_warnings;
DefineLintAction(LintInfo) msgArray = &_info;

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
