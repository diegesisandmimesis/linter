#charset "us-ascii"
//
// commonTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the linter library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f commonTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "linter.h"

versionInfo: GameID;
gameMain: GameMainDef
	initialPlayerChar = me
/*
	newGame() {
		forEachInstance(NameAsOther, function(o) {
			aioSay('\n<<toString(o)>>\n ');
		});
	}
*/
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
// This should produce a complaint because the weak token '(cards)'
// will prevent the noun 'cards' from ever matching.
+deck: Thing '(of) (cards) deck/cards' 'deck of cards'
	"It's a deck of cards. "
;
+card: Unthing 'card*cards' 'cards'
	notHereMsg = '{You/He} can\'t do anything with individual cards. '
;
// A NameAsOther delcaration with two mistakes:  superclass list in wrong
// order and "targetObject" instead of "targetObj".
pebble: Thing, NameAsOther targetObject = rock;
rock: Thing '(ordinary) rock' 'rock' "An ordinary rock. ";

myLinter: Linter
	logHeader = 'This is just a test of the stock <q>common</q> linter
		rules. '
;
