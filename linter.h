//
// linter.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_LINTER

LintClass template @lintClass?;
LintFlags template [lintFlags]?;

#define DefineLintAction(name) \
	DefineAction(name, LintAction)

#define LINTER_H
