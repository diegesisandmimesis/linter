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
	lintPluralMismatch() {
		local i, j, r;

		if((noun == nil) || (isPlural == true))
			return(nil);
		r = nil;
		forEachInstance(Thing, function(o) {
			if(r == true) return;
			if(o.plural == nil) return;
			for(i = 1; i <= noun.length; i++) {
				for(j = 1; j <= o.plural.length; j++) {
					if(noun[i] == o.plural[j]) {
						r = o;
						return;
					}
				}
			}
		});

		return(r);
	}

	lintCompareVocab(otherObj) {
		local idx, l0, l1, r, t;

		r = new _LintVocabCheck();
		t = new LookupTable();
		cmdDict.forEachWord(function(obj, str, prop) {
			if((obj != self) && (obj != otherObj)) return;
			if(t[prop] == nil) {
				t[prop] = new Vector(2);
				t[prop].append(new Vector());
				t[prop].append(new Vector());
			}
			if(obj == self)
				idx = 1;
			else
				idx = 2;
			t[prop][idx].append(str);
		});
		t.forEachAssoc(function(prop, v) {
			l0 = v[1].sort();
			l1 = v[2].sort();
			if(l0 != l1)
				r.addDiff(new _LintVocabDiff(prop, l0, l1));
		});

		return(r);
	}
;

class _LintVocabDiff: object
	prop = nil
	vocab0 = nil
	vocab1 = nil
	construct(p, v0, v1) { prop = p; vocab0 = v0; vocab1 = v1; }
;

class _LintVocabCheck: object
	isEquivalent = true
	diff = nil
	addDiff(v) {
		if(diff == nil) diff = new Vector();
		if((v == nil) || !v.ofKind(_LintVocabDiff))
			return(nil);
		diff.append(v);
		isEquivalent = nil;
		return(true);
	}
	reportDiffs() {
		local buf;

		if(diff == nil) return('<.p>No differences.');

		buf = new StringBuffer();
		buf.append('<.p>');
		diff.forEach(function(o) {
			o.vocab0.forEach(function(v) {
				if(o.vocab1.indexOf(v) != nil) {
					o.vocab0.removeElement(v);
					o.vocab1.removeElement(v);
				}
			});
			o.vocab1.forEach(function(v) {
				if(o.vocab0.indexOf(v) != nil) {
					o.vocab1.removeElement(v);
					o.vocab0.removeElement(v);
				}
			});
			buf.append('\n\t<<toString(o.prop)>>:
				<<toString(o.vocab0)>>
				<<toString(o.vocab1)>>\n ');
		});
		return(toString(buf));
	}
;

weakTokensLinter: LintClass @Thing
	lintAction(obj) {
		if(!obj.lintWeakTokens())
			warning('<q><<obj.name>></q> has weakTokens that
				conflict with its noun list',
				'If an object declaration has weak tokens
				(words in the vocabulary in parentheses)
				this will prevent the parser from matching
				that word as a noun.
				<.p>The linter rule complains when it notices
				that an object has a weak token that matches
				a noun on the same object, because that
				usually means one or the other shouldn\'t
				be part of the object\'s vocabulary. ');
	}
;

pluralMismatchLinter: LintClass @Thing
	lintAction(obj) {
		local o;

		if((o = obj.lintPluralMismatch()) != nil)
			warning('<q><<obj.name>></q> has a non-plural
				noun that matches another object\'s
				(<<o.name>>) vocabulary',
				'If a non-plural object has a noun that\'s
				the same as a plural in another object\'s
				vocabulary this will generally cause the
				parser to always prefer the second object
				over the first.
				<.p>The linter complains about this because
				this generally indicates a mistake
				somewhere in one of the objects\' declarations,
				either in failing to make the first object
				plural (by setting isPlural = true on the
				object) or in incorrectly declaring the
				word in question.  For example, declaring
				a deck of cards \'deck/cards\' instead of
				\'deck*cards\'.');
	}
;

class _nameAsOtherFake: object targetObject = nil;

nameAsOtherLinter: LintClass @NameAsOther
	lintAction(obj) {
		if(linter.superclassListIsABeforeB(obj, Thing, NameAsOther))
			warning('NameAsOther after Thing in superclass list
				for object <<toString(obj)>>',
				'NameAsOther was found after Thing in an
				object\'s superclass list.  This is almost
				always indicative of a problem, and the
				order should be reversed.
				<.p>The name of the offending object is
				<q><<obj.name>></q>, but that may or may
				not be helpful because an object declared
				with NameAsOther shouldn\'t have a name
				in the first place.');
		if((obj.targetObj == nil) && (obj.targetObject != nil))
			warning('<q>targetObject</q> found in NameAsOther
				instance <<toString(obj)>>',
				'NameAsOther instance need a <b>targetObj</b>
				property.  In this case that property was
				nil, but <b>targetObject</b> was non-nil,
				possibly indicating a typo.');
	}
;

isEquivalentLinter: LintClass @Thing
	_flaggedEquivalenceKeys = perInstance(new Vector())

	lintAction(obj) {
		local r;

		if(!obj.isEquivalent) return;
		if(_flaggedEquivalenceKeys.indexOf(obj.equivalenceKey) != nil)
			return;
		forEachInstance(Thing, function(o) {
			if(!o.isEquivalent || (o == obj)) return;
			if(o.equivalenceKey != obj.equivalenceKey) return;
			r = obj.lintCompareVocab(o);
			if(r.isEquivalent == true) return;
			warning('Equivalent objects with equivalenceKey
				<q><<toString(obj.equivalenceKey)>></q>
				have varying vocabulary',
				'Objects with isEquivalent = true and
				the same equivalenceKey are usually
				intended to be indistinguishable from
				each other.  This warning means that
				the linter found otherwise equivalent
				objects that have vocabulary differences.
				<.p>The equivalenceKey is
				<q><<toString(obj.equivalenceKey)>></q>,
				and the differences are: <<r.reportDiffs()>>');
			_flaggedEquivalenceKeys.append(obj.equivalenceKey);
		});
	}
;

#endif // __DEBUG
