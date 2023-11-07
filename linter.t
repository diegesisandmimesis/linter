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
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
linterModuleID: ModuleID {
        name = 'Linter Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class Linter: PreinitObject
	// Name displayed at the top of report
	logName = 'linter'

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

	// Vectors for our errors and warnings
	_errors = perInstance(new Vector)
	_warnings = perInstance(new Vector)
	_info = perInstance(new Vector)

	// Called at preinit.
	execute() {
		lint();
		report();
	}

	// By default, do nothing.
	lint() {}

	// Main output method.
	report() {
		// If we don't have any errors, we bail unless we have
		// have warnings and were compiled with -D WERROR
		if((_errors.length == 0)
			&& (!werror || (_warnings.length == 0)))
			return;

		// Start report output
		reportHeader();

		// Meat of the report
		reportErrors();
		reportWarnings();
		reportInfo();

		// End report output
		reportFooter();

		// Throw an exception to halt the game.
		throw new LinterException();
	}

	// Displayed at the top of the report
	reportHeader() {
		log(logWrapper);

		log('<<logName>>');
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
;

// If we're NOT compiled with the -d flag, the linter does nothing
// at preinit.
#ifndef __DEBUG
modify Linter execute() {};
#endif // __DEBUG
