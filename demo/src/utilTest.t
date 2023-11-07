#charset "us-ascii"
//
// utilTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the linter library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f utilTest.t3m
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

class Foo: object;
class Bar: object;
class Baz: object;
class Quux: object
	isTrue = true
	isNil = nil
	returnTrue() { return(true); }
	returnNil() { return(nil); }
;

function instanceTest0(obj) { return(obj.isTrue); }
function instanceTest1(obj) { return(obj.isNil); }

widget: Thing, Foo;

class Pebble: Thing, Bar '(small) (round) pebble' 'pebble'
	"A small, round pebble. "
	isEquivalent = true
;
class Rock: Thing, Baz '(ordinary) rock' 'rock'
	"An ordinary rock. "
	isEquivalent = true
;

startRoom: Room 'Void' "This is a featureless void.";
+me: Person;
+pebble1: Pebble;
+pebble2: Pebble;

rock: Rock;

quux0: Quux;
quux1: Quux;
quux2: Quux;

myLinter: Linter
	logName = 'this should output several errors marked <q>success</q>
		and none marked <q>FAILURE</q>'

	// When run, this should display all of the "success" errors and
	// none of the "FAILURE" errors.
	lint() {
		// Tests of superclass ordering.
		// "widget"'s superclass list is "Thing, Foo", so
		// the first conditional should be true, the second false.
		if(!testSuperclassOrder(widget, Foo, Thing))
			error('success 1');
		if(!testSuperclassOrder(widget, Thing, Foo))
			error('FAILURE 1');

		// Instance count tests.
		// There's only one Foo, so the first conditional is true.
		// There are two Pebbles, so the second is false.
		if(isSingleton(Foo))
			error('success 2');
		if(isSingleton(Pebble))
			error('FAILURE 2');

		// Test for orphaned instances.
		// The pebbles all have locations, so the first conditional
		// is true
		if(!hasOrphans(Pebble))
			error('success 3');
		if(!hasOrphans(Rock))
			error('FAILURE 3');

		if(testInstanceProp(Quux, &returnTrue, true))
			error('success 4');
		if(testInstanceProp(Quux, &isNil, true))
			error('FAILURE 4');
		if(testInstanceProp(Quux, instanceTest0, true))
			error('success 5');
		if(testInstanceProp(Quux, instanceTest1, true))
			error('FAILURE 5');
		if(testInstanceProp(Quux, { x: x.isNil == nil }))
			error('success 6');
		if(testInstanceProp(Quux, { x: x.isTrue != true }))
			error('FAILURE 6');
	}
;
