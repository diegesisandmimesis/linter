#charset "us-ascii"
//
// linter.t
//
//	A TADS3 module for implementing linters for static analysis.
//
//
// USAGE:
//
//	Declare an instance of Linter, putting static analysis tests in
//	the lint() method.
//
//	Use Linter.error() to add an error and Linter.warning() to
//	add a warning.
//
//		// Declare a linter.
//		myLinter: Linter
//			lint() {
//				warning('this is an example warning');
//				error('this is an example error');
//			}
//		;
//
//	The lint() method will be called at preinit in debugging builds
//	(when compiled with the -d flag).
//
//	By default, the linter will throw an exception at runtime if there
//	are any errors, and output all errors and warnings before exiting.
//
//	If compiled with -D WERROR the linter will treat warnings as errors.
//	
//	If the -d flag is not used when compiling the module will do nothing.
//
//
// LINTCLASS AND LINTRULE
//
//	In addition to adding procedural code to a linter's lint() method,
//	you can add checks by adding instances of LintClass and LintRule
//	to the linter.  Example:
//
//		myLinter: Linter;
//		+LintClass @Foo
//			lintAction(obj) {
//				if(obj.foo == 'bar')
//					warning('foo is bar');
//			}
//		;
//
//	This will iterate through all instances of the Foo class, calling
//	lintAction() for each instance.
//
//	LintClass provides error(), warning(), and info().
//
//	LintClass also provides a setFlag() method, which takes a single
//	text literal as its argument.  Flags can then be checked via
//	LintRule.  Example:
//
//		myLinter: Linter;
//		+LintClass @Foo
//			lintAction(obj) {
//				if(obj.foo == 'bar') {
//					warning('foo is bar');
//					setFlag('fooIsBar');
//				}
//			}
//		;
//		+LintClass @Bar
//			lintAction(obj) {
//				if(obj.bar == 'foo') {
//					warning('bar is foo');
//					setFlag('barIsFoo');
//				}
//			}
//		;
//		+LintFlag [ 'fooIsBar', 'barIsFoo' ]
//			lintAction() {
//				error('foo and bar potentially reversed');
//			}
//		;
//
//	This checks all instances of Foo to see if foo = 'bar', and all
//	instances of Bar to see if bar = 'foo'.  In each case a warning is
//	added and a flag is set.  The LintRule will match when both flags
//	are set, and will report an error.
//
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
linterModuleID: ModuleID {
        name = 'Linter Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

linterPreinit: PreinitObject
	execute() {
		forEachInstance(_LintRule, { x: x.initLintRule() });
		forEachInstance(Linter, { x: x.execute() });
	}
;

class Linter: object
	active = true

	// Header text displayed at the top of report
	logHeader = 'linter'
	logName = (logHeader)

	// Added to the start of every line of output
	logPrefix = nil

	// Delimeter added at the top and bottom of the linter output
	logWrapper = '===================='

	errorPrefix = 'ERROR: '
	warningPrefix = 'warning: '
	infoPrefix = 'info: '

	// Object classes to use for errors and warnings.
	errorClass = LinterError
	warningClass = LinterWarning
	infoClass = LinterInfo

	// Treat warnings as errors
	werror = nil

	defaultRules = static []

	// Vectors for our errors and warnings
	_errors = perInstance(new Vector)
	_warnings = perInstance(new Vector)
	_info = perInstance(new Vector)

	_flags = perInstance(new LookupTable)
	_counters = perInstance(new LookupTable)

	_lintRulesList = nil

	// Called at preinit.
	execute() {
		if(!active) return;
		addDefaultRules();
		lint();
		lintRules();
		report();
	}

	addLintRule(obj) {
		if(obj == nil) return(nil);
		if(!obj.ofKind(LintClass) && !obj.ofKind(_LintRule))
			return(nil);
		if(_lintRulesList == nil) _lintRulesList = new Vector();
		if(_lintRulesList.indexOf(obj) != nil) return(nil);
		_lintRulesList.append(obj);
		obj.linter = self;
		return(true);
	}

	addDefaultRules() {
		if(defaultRules.length == 0)
			return;
		defaultRules.forEach({ x: addLintRule(x) });
	}

	// By default, do nothing.
	lint() {}

	_lintRules(cls) {
		if(_lintRulesList == nil) return;
		_lintRulesList.subset({ x: x.ofKind(cls) })
			.forEach(function(o) { o.executeLintRule(self); });
	}

	lintRules() {
		_lintRules(LintClass);
		_lintRules(LintRule);
		_lintRules(LintFlag);
	}

	// Main output method.
	report() {
		// If we have no errors, no warnings, and no informational
		// messages, bail.
		if((_errors.length == 0) && (_warnings.length == 0)
			&& (_info.length == 0))
			return;

		// Start report output
		reportHeader();

		// Meat of the report
		reportErrors();
		reportWarnings();
		reportInfo();

		// End report output
		reportFooter();

		if((_errors.length == 0)
			&& (!werror || (_warnings.length == 0)))
			return;
		// Throw an exception to halt the game.
		throw new LinterException();
	}

	// Displayed at the top of the report
	reportHeader() {
		log(logWrapper);

		log('<<logHeader>>');
		log('\terrors:  <<toString(_errors.length)>>');
		log('\twarnings:  <<toString(_warnings.length)>>');
	}

	// Displayed at the bottom of the report
	reportFooter() {
		log(logWrapper);
	}

	// Report errors, if there are any to report.
	// We just iterate through the error objects and call their
	// report() method.  In the base module this is unnecessarily
	// baroque, but in theory we could be saving data in the error
	// and warning objects (instead of just a text literal) and then
	// doing some kind of analysis and reporting on it in the report()
	// method.
	reportErrors() {
		if(_errors.length == 0)
			return;

		_errors.forEach(function(o) { o.report(self); });
	}

	reportWarnings() {
		if(_warnings.length == 0)
			return;

		_warnings.forEach(function(o) { o.report(self); });
	}

	reportInfo() {
		if(_info.length == 0)
			return;

		_info.forEach(function(o) { o.report(self); });
	}

	// Simple output method.
	log(msg) {
		aioSay('\n<<(logPrefix ? logPrefix : '')>><<toString(msg)>>\n ');
	}

	// Convenience methods for outputting single-line error and warning
	// messages.
	logError(msg) { log('<<errorPrefix>><<msg>>'); }
	logWarning(msg) { log('<<warningPrefix>><<msg>>'); }
	logInfo(msg) { log('<<infoPrefix>><<msg>>'); }

	// Append error/warning to the appropriate list.
	error(msg) { _errors.append(errorClass.createInstance(msg)); }
	warning(msg) { _warnings.append(warningClass.createInstance(msg)); }
	info(msg) { _info.append(infoClass.createInstance(msg)); }

	addCounter(id, v?) {
		if(_counters[id] == nil)
			_counters[id] = 0;
		_counters[id] += ((v != nil) ? v : 1);
	}

	getCounter(id) { return(_counters[id]); }

	setFlag(id) {
		_flags[id] = true;
	}

	checkFlags(lst) {
		local i;

		if(lst == nil)
			return(nil);
		if(!lst.ofKind(Collection))
			lst = [ lst ];

		i = 0;
		lst.forEach(function(id) {
			if(_flags[id] == true)
				i += 1;
		});

		return(i == lst.length);
	}
;

// If we're NOT compiled with the -d flag, the linter does nothing
// at preinit.
#ifndef __DEBUG
modify Linter execute() {};
#endif // __DEBUG
