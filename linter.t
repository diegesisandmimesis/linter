#charset "us-ascii"
//
// linter.t
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
	_errors = perInstance(new Vector)
	_warnings = perInstance(new Vector)

	logName = 'linter'
	logPrefix = nil
	logWrapper = '===================='

	errorPrefix = 'ERROR: '
	warningPrefix = 'warning: '

	errorClass = LinterError
	warningClass = LinterWarning

	// Treat warnings as errors
	werror = nil

	execute() {
		lint();
		report();
	}

	lint() {}

	report() {
		if((_errors.length == 0)
			&& (!werror || (_warnings.length == 0)))
			return;

		log(logWrapper);

		log('<<logName>>');
		log('\terrors:  <<toString(_errors.length)>>');
		log('\twarnings:  <<toString(_warnings.length)>>');

		reportErrors();
		reportWarnings();

		log(logWrapper);

		throw new LinterException();
	}

	reportErrors() {
		if(_errors.length == 0)
			return;
		_errors.forEach(function(o) {
			o.report(self);
		});
	}

	reportWarnings() {
		if(_warnings.length == 0)
			return;
		_warnings.forEach(function(o) {
			o.report(self);
		});
	}

	log(msg) {
		aioSay('\n<<(logPrefix ? logPrefix : '')>><<toString(msg)>>\n ');
	}

	logError(msg) { log('<<errorPrefix>><<msg>>'); }
	logWarning(msg) { log('<<warningPrefix>><<msg>>'); }

	error(msg) { _errors.append(errorClass.createInstance(msg)); }
	warning(msg) { _warnings.append(warningClass.createInstance(msg)); }
;
