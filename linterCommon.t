#charset "us-ascii"
//
// linterCommon.t
//
//	Common linter rules.  These are checks that can be applied generally
//	to any game.
//
//
#include <adv3.h>
#include <en_us.h>

#include "linter.h"

#ifdef __DEBUG

// Tweak Thing to add a check for weakTokens.
// This checks to see if a weak token matches a declared noun.  This
// is probably a mistake, as the weak token will prevent the matching noun
// from ever resolving.
// Example:  a Thing with declared with:
//	deck: Thing '(of) (cards) deck/cards' 'deck of cards' [...]
// ...will never match a command like >X CARDS, because the weak token
// '(cards)' will prevent the noun 'cards' from ever matching.
modify Thing
	lintWeakTokens() {
		local i, j;

		// We only care if we have both weakTokens and nouns
		// declared on the object.
		if((weakTokens == nil) || (noun == nil))
			return(true);

		for(i = 1; i <= weakTokens.length; i++) {
			for(j = 1; j <= noun.length; j++) {
				if(weakTokens[i] == noun[j])
					return(nil);
			}
		}

		return(true);
	}
;

weakTokensLinter: LintClass @Thing
	lintAction(obj) {
		if(!obj.lintWeakTokens())
			warning('<q><<obj.name>></q> has weakTokens that
				conflict with its noun list');
		
	}
;

#endif // __DEBUG
