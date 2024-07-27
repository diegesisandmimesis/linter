#charset "us-ascii"
//
// werrorTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the linter library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f werrorTest.t3m
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
gameMain: GameMainDef initialPlayerChar = me;

class Pebble: Thing '(small) (round) pebble' 'pebble'
	"A small, round pebble. "
	isEquivalent = true
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+pebble1: Pebble;
+pebble2: Pebble;

myLinter: Linter
	logHeader = 'This should display a warning but <b>NOT</b> throw
		an exception and halt the game. '
	lint() {
		warning('This is a warning.');
	}
;
