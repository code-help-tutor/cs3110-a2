# A2: Adventure

**Deadline:** Monday, 10/23/23, 3:00 pm

*This assignment is to be done as individuals, not with partners nor with teams.*

In this assignment, you will develop a *text adventure game* (TAG), also
known as *interactive fiction*. The characteristic elements of TAGs
include gameplay driven by exploration and puzzle-solving, and a
text-based interface in which users type natural-language commands and
the game responds with text. The seminal work in this genre is the
[Colossal Cave Adventure][adventure].

**Exercise:** An interactive example is worth a thousand words. So
before reading any further in this writeup, spend just a few minutes
playing this [online version of Colossal Cave Adventure][playcave].  And
don't worry; that game is far bigger than what you will build in this
assignment.

**How to get started:**
Begin by reading this entire writeup and making sure you have a good
understanding of it. The next thing you should do is spend a good bit of
time, maybe a whole day, sketching out on paper how you're going to
solve this assignment. Your focus should be on identifying what features
you need to implement, what data structures and functions you'll need
for those features, and how you'll go about testing those data
structures and functions during the process of implementing them.
Waiting until the very end to test is a recipe for disaster!

[adventure]: https://en.wikipedia.org/wiki/Colossal_Cave_Adventure
[playcave]: https://rickadams.org/adventure/advent/

**Table of Contents:**

* [Introduction](#intro)
* [Assignment information](#assignment-info)
* [Part 1: Game engine](#part-1-game-engine)
* [Part 2: Testing](#part-2-testing)
* [Part 3: Your own adventure](#part-3-your-own-adventure)
* [What to turn in](#what-to-turn-in)
* [Assessment](#assessment)
* [Karma](#karma)

## Introduction

You are to implement a *game engine* that
could be used to play many *adventures*.  Here, the game
engine is an OCaml program that implements the gameplay and
user interface.  An adventure is a data file that is
input by the game engine and describes a particular gaming
experience:  exploring a cave, hitchhiking on a spaceship,
finding the missing pages of a powerful magical book, etc.
This factoring of responsibility between the engine and
input file is known as *data driven design* in games.

The gameplay of TAGs is based on an *adventurer* moving between *rooms*.
Rooms might represent actual rooms, or they might be more
abstract&mdash;for example, a room might be an interesting location in a
forest. Each room also has a text description associated with it.  Some
rooms have *items* in them.  These items can be taken by the adventurer
and carried to another location, where they can then be dropped.  The
adventurer begins the game in a predetermined *starting* room, possibly
with some predetermined items.

The *player* does not so much win a TAG as *complete* the TAG by
accomplishing various tasks:  exploring the entire *map* of rooms and
corridors, finding items, moving items to specified locations, etc.  To
indicate the player's progress toward completion, a TAG gives a player a
numeric *score*.  The TAG also tracks the number of *turns* taken by the
player.  Savvy players attempt to achieve the highest score with the
lowest number of turns.

Your task is to develop a game engine and to write a small adventure of your own.

## Assignment information 

**Objectives.**

* Design and use data types, especially records and variants.
* Write code that uses pattern matching and higher-order functions on lists and
  on trees.
* Interact with the environment outside the program by reading and writing
  information from files and the user.
* Use JSON, a standard data format.
* Practice writing programs in the functional style using immutable data.

**Recommended reading.**

* The front page of the [JSON website][json]

*Caution: There is a chapter on JSON in [RWO][rwojson], but you are
probably better off ignoring it.  The features used in that chapter are
more advanced than what you need, hence might be more confusing than
helpful for this assignment. The ATDgen library and tool at the end of
that chapter are not permitted for use on this assignment, because using
them would preclude some of the list and tree processing that we want
you to learn from this assignment. Note that the Core library used in
that book is not supported in this course.

[rwojson]: https://dev.realworldocaml.org/json.html

**Requirements.**

1. Your engine must satisfy the requirements stated below.

2. You must submit your own, original small adventure file.

3. You must submit an OUnit test suite, as described below.

4. Your code must be written with good style and be well documented.

**What we provide.**
In the release code on the course website you will find these files:

* Several `.ml` and `.mli` files:  `command.ml(i)`, `state.ml(i)`, and `main.ml`.
  You are permitted to change the `.ml` files (i.e., the implementations) 
  but not the `.mli` files (i.e., the interfaces), unless otherwise specified.
  You are permitted to add new compilation units of your own design.
* A couple small adventure files, `one_room.json` and `two_rooms.json`, that you could
  use as a basis for writing new adventures.
* A larger adventure file, `small_circle.json`.  When you finish your engine, you
  can play this file.
* A JSON schema `schema.json` for adventure files that defines
  the format of such files.  It is not an adventure file itself,
  so your engine will not be able to load it.
  Most people will want to ignore this file, but we provide it for those
  who want an exact description of the JSON format for adventures.
* A dune setup for compiling your code.

**Grading issues.**

* **Late submissions:** Carefully review the course policies on
  submission and late assignments.  Verify before the deadline
  that you have submitted the correct version.
* **Environment, names, and types:**  You are required to adhere to the names and
  types of the functions and modules specified in the release code. 
  Otherwise, your solution will receive minimal credit.

**Prohibited OCaml features.**
You may not use imperative data structures, including refs, arrays,
mutable fields, and the `Bytes` and `Hashtbl` modules.  Strings are
allowed, but the deprecated functions on them in the [`String`
module][string] are not, because those functions provide imperative
features. The `Map` module is not imperative, hence is permitted. Your
solutions may not require linking any additional libraries/packages
beyond OUnit, Yojson, Str, and ANSITerminal.
You may and in fact must use I/O functions provided by the
`Pervasives` module, even though they cause side effects,
to implement your user interface.

[string]: https://caml.inria.fr/pub/docs/manual-ocaml/libref/String.html

## Part 1: Game engine 

Implement a game engine that provides the following functionality.
The release code provides the following files to get you started:

* `Command`:  a compilation unit (`.ml` + `mli`) for player commands.
* `State`: a compilation unit for the state of the game.
* `main.ml`: the user interface to the game.

You are permitted to change the `.ml` files.  The existing code
in the `.mli` files may not be changed, unless otherwise specified,
because those files declare the names and types against which the course
staff will test your engine.  You are permitted to add new
declarations to the `.mli` files, because additional names and types
the course staff is unaware of will not impair our testing.
In fact, you will almost certainly want to declare new names and types
in `state.mli`.  

**Interface.**
The interface to a TAG is based on the player issuing text *commands* to
a *prompt*; the game replies with more text and a new prompt, and so on.
Thus, the interface is a kind of read-eval-print-loop (REPL), much like
`utop`. For this assignment, commands will generally be two-word phrases
of the form "VERB OBJECT".  We leave the design of the user interface up
to your own creativity. In grading, we will not be strictly comparing
your user interface's text output against expected output, so you have
freedom in designing the interface.

All the console I/O functions you need are in the [`Pervasives`
module][pervasives]. Some people might want to investigate the [`Printf`
module][printf] for output, but it's not necessary. The `Scanf` module
is overkill for input in this assignment; in fact the `read_line`
function in `Pervasives` is probably all you need. For parsing player
commands, you are welcome to use the OCaml [Str library][str], but
it's not necessary; the standard library `String` module suffices.

Your user interface must be implemented entirely within `main.ml`
or any supporting modules you design yourself.  It may not
be implemented in `state.ml`.   There are a couple reasons for 
this restriction.  First, we want you to think of `State` as being 
purely functional.  Second, games are often designed using the
[Model-View-Controller][mvc] design pattern.  Here, `State` 
is the model, hence it should not be implementing any of the 
user interface.  Indeed, you should imagine your `State` module 
being usable equally well by other programmers implementing 
graphical user interfaces, which have no need for printing of text 
responses. So instead of printing inside `State`, you can add 
functions to the `State` interface to help  `Main` figure out 
what to print.

[mvc]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller

**Commands.**
Your engine is required to support the following commands:

* **Movement** is performed by using the verb "go" followed by the
direction.  The room itself determines what the allowed directions 
are, for example, "go north", "go up", "go clock tower", etc.
If such movement is possible, the adventurer transitions to a
new room, and the description of the new room is displayed.  The
description of the room may vary depending on the items in the
player's inventory or located in the room itself.  If the
movement is impossible, an error message is displayed.  As a
*shorthand*, the player may simply type the direction itself without the
verb "go".  For example, "go north" and "north" are equivalent. For
movement to be possible, certain *keys* may be necessary, and it suffices
for those keys to be either in the player's inventory or located
in the room from which movement originates.

* **Items** can be manipulated by the verbs "take" and "drop" followed
by the name of the item, for example, "take hat", "take bronze key", etc.
The command "take" transfers an item from the current room
to the adventurer's *inventory*, and "drop" transfers an item from the
inventory to the current room.  The items present in the current room
are displayed whenever the room description is displayed.

* **Other commands** include "quit", which ends the game, "look", which
re-displays the description of the current room, "inventory" (shorthand:
"inv"), which gives a list of what the adventurer is currently carrying,
"score", which displays the current score, and "turns", which displays
the current number of turns.

Input from the player must be handled as case-insensitive. 
For example, "go north" and "gO NoRtH" should be recognized and
treated as the same.  Nonetheless, the room descriptions, directions
and item names in the adventure file are case sensitive and should be
displayed by the engine with their proper case.  For example, if the
adventure file defines an item named "Lambda", then when that name is
displayed it should be "Lambda" and not "lambda". But the player is
permitted to enter "take lambda" to pick it up. 

A *turn* is any successfully completed issue of the commands
"go" (or any of its shorthand forms), "take", or "drop".  For example,
"go north" counts as a turn only if the current room permits exit to the
north. At the beginning of play, the current number of turns is zero.
   
**Scoring.**
The player's score is determined by these rules:

* The player starts with zero points, but might automatically receive
  more as described below.

* Every room is worth a certain number of points, which are earned simply
  for having entered the room at least once.  The player automatically
  gets whatever points are associated with the starting room at the
  beginning of play.

* Every item is worth a certain number of points.  The points for an
  item are earned if the item is currently located in a *treasure room*.
  Different items may have different treasure rooms, and a single item
  might have multiple possible treasure rooms. Dropping an item
  in the item's treasure room(s) earns points, and taking the item away
  loses points.  The player automatically gets whatever points
  are associated with items already located in their treasure room(s) at
  the beginning of play.  Taking or dropping an item in a room
  other than its treasure room(s) is permitted but has no effect on the score.
  Items in the adventurer's inventory are not located in any room;
  they must be dropped to be considered as located in a room.
  
* The points that a room or item is worth might be positive, zero, or 
  negative.

The *winning score* for a game is sum of all the item points plus the
sum of all the room points, regardless of whether it's actually possible
to earn those points (i.e., maybe a room is unreachable), or whether the
points are negative (hence decrease the sum).  If the player does earn
the winning score possible for the adventure, the game engine informs
the player that they have completed the adventure using a message
specified in the adventure file, but the player is
still allowed to interact with the game afterwards&mdash;the game
doesn't automatically quit.  So the player's score might go down or up
again.  After the completion message has been displayed once, the engine
does not have to display it again.

**Robustness.**
We want you to imagine that you are writing the game engine as a product
that you ship to customers.  The customers then additionally acquire
adventure files that they want to play, and those files could be authored by
someone other than you.  In that scenario, you want to make sure that
the customers do not blame you for errors that are not your own.  That
is, the game engine itself should not exhibit any errors, but if it
detects an error in an adventure file, it should correctly blame that
file (and by association its developer rather than you).

So your game engine may not terminate abnormally, meaning it may not 
raise an unhandled exception, nor may it go into an infinite loop
that would prevent the player from entering a command. But if the
adventure file itself contains errors, your engine is permitted to
print an error message blaming the adventure file, then terminate
normally.

**Adventure files.**
Adventure files are formatted in [JSON][json].  We provide a couple
example adventure files in the release code. Note that the JSON property
names in that file may not be changed. Also note that many of the
property values are strings, which are case sensitive and can contain
arbitrary characters (including whitespace). An adventure file contains
six main entries:

* The rooms.  Each room contains five entries:
  - an id,
  - a list of descriptions (a description itself contains two entries:
    the set of items that must be collectively present in the adventurer's inventory
    or in the room in order for that description to be displayed,
    and the description text itself; the first description in the list
    for which all the items are present is the one that must be displayed),
  - the number of points exploring the room is worth,
  - the exits from the room (an exit itself contains three entries:  the
    direction of the exit, and the room to which it leads, and the items
    that the adventurer must have in their inventory or must be present in
    the room for the exit to be unlocked), and
  - the treasures that should be dropped in the room.
* The items.  Each item contains three entries:
  - an id (which is the item's name by which it can be taken and dropped),
  - a description, and
  - the number of points the item is worth when it is dropped in its treasure room,
    or any one of its treasure rooms if there are multiple.
* The starting room (where the adventurer begins).
* The starting items (which are initially in the inventory).
* The starting locations of all items not in the inventory.  Each location contains
  two entries:
  - the id of the item
  - the room id where the item starts
* The message to display when the player wins
  
Adventure files will never have huge maps in them; as a rough estimate
there might be on the order of 100 rooms and 100 items.

For those who desire additional precision, we provide a JSON schema for
adventure files in `schema.json`.  Your game engine is required to be
compatible with this schema, which defines the required elements of the
file and their names.  It is possible for you to extend this schema
to add more functionality to your engine, but you must make sure that
you don't remove any properties or objects and that you maintain support
for adventures that don't have your additional features.  Otherwise,
the course staff will be unable to grade your submission using our test suite
of adventures.  Using a JSON [schema validator][validator], you can check the
well-formedness of an adventure file again the schema.

[json]: http://json.org/
[schema]: schema.json
[validator]: http://www.jsonschemavalidator.net/

There are many errors that could exist in an adventure file, however,
that cannot be detected by a schema validator.  For example, a room
could have an exit to a non-existent room, or two items could have the
same name, or a non-existent item could be given in the starting
inventory, or there could be two exits with the same name,
etc.  For these and other such errors that are the fault of
the adventure file creator (as discussed above under the heading
"Robustness") your game engine may not itself exhibit any errors, but it
may blame the adventure file and terminate normally. 

Your engine is not responsible for detecting adventure file errors or 
for attempting to continue gameplay beyond the point it happens to 
detect an error, although your engine may not raise unhandled exceptions 
or go into an infinite loop, as discussed above under "Robustness."

**JSON.**
We recommend using the [Yojson library's Basic module][yojsonbasic] for parsing JSON
adventure files.  Although you are welcome to use any functionality
provided by the library, we suggest concentrating your attention
as follows:

* Use `Yojson.Basic.from_file` to read the contents
  of a JSON file and construct a `Yojson.Basic.json` tree.
  `Yojson.Basic.from_string` might also be helpful for test cases.
* Use the `Yojson.Basic.Util` module to extract information
  from that tree.  That module might seem intimidating at first,
  but there are really a very small number of functions that you
  need.  In fact, you can implement your entire parser with just
  these:  `member`, `to_list`, `to_string`, and `to_int`.
  
[str]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Str.html
[yojsonbasic]: https://mjambon.github.io/mjambon2016/yojson-doc/Yojson.Basic.html
[pervasives]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html
[printf]: http://caml.inria.fr/pub/docs/manual-ocaml/libref/Printf.html

**Plan of attack.**
Here's one way you might approach implementation of your game engine.

1. Implement the loading of an adventure file into a `json`-typed value.

2. Implement converting that JSON into OCaml types, including designing
   the types.  Do some interactive testing in `utop` to check whether it looks
   like the conversion is being done right.  

3. Implement the game state, including producing the initial state,
   and all the required functions except `run_command`.  Write an OUnit test suite
   using those required functions to make sure the initial state is correct for
   some small adventure files.

4. Implement parsing of a string into a verb and object (if any),
   including designing a type to represent commands.  Do interactive
   testing in `utop` to make sure all the commands that need to be supported
   are being correctly parsed.

5. Implement `run_command` and write a OUnit test suite for some test adventure files.


Tasks 2 and 5 are probably the hardest, but YMMV.

## Part 2: Testing

There are two aspects to testing this assignment.
The first is to create an OUnit test suite in `test_state.ml`.
The second is to playtest your REPL.

* *Unit testing*:  Write black-box unit tests against the
`State` interface.  Determine whether the initial state computed by your
JSON parser is correct.  Determine whether the state is updated
correctly based on commands. Your unit tests should use the interface
provided by `state.mli`. You are not required to submit unit tests for
any functions beyond those in the interface (e.g., helper functions you
design yourself), though of course you are permitted to do so.



## Part 3:  Your own adventure 

Write and submit your own adventure that a grader will play using your
own engine. Your adventure must have at least 5 rooms and 3 items. If
your engine is somehow non-operable, the grader will attempt to play it
using the staff's own engine.

We ask you to do this for two reasons.  First, it will help you
understand the adventure file format and implement your game engine. (So
you need not do this part last!)  Second, it provides you with an
opportunity for some creativity, which we encourage but will not assess
as part of your grade. If there are some really great adventures
submitted, we will consider making them available for other students to
play.



## Assessment 

The course staff will assess the following aspects of your solution.
The percentages shown are the approximate weight we expect each to receive.

* **Correctness.** [50%] Does your solution compile against and correctly pass
  the course staff's test cases? Only Part 1 is relevant to Correctness.
  As a rough guide, here is a further breakdown of the approximate weight we expect 
  to assign to the parts of our test suite: `init_state`: 20%; unit tests for `run_command` and 
  `parse`: 60%; integration tests on new adventure files of our own creation: 20%.
  Note that these tests are necessarily somewhat cumulative:  if your solution
  cannot read in a simple adventure file (e.g., `one_room.json`) or parse at least
  simple player commands, then it has no chance of passing unit tests for `run_command`.
  Partial credit is based on the test cases your submission passes, not on
  code you write per se.  So to optimize your partial credit, make sure your submission
  can read `.json` files and parse player commands before spending a lot of time
  implementing `run_command` or a fancy REPL.

* **Testing.** [15-20%] Does your test suite for `State` adequately 
  provide black-box tests against the specification?

* **Code quality.** [15-20%] How readable and elegant is your source code?  How
  readable and informative are your specification comments?  All functions,
  including helper functions, must have specification comments.

* **Gameplay.** [10-15%] How usable is your REPL?  Does it ever
  terminate abnormally?  Does it print the messages it is
  supposed to print?

* **Your own adventure.** [5%] Did you submit an adventure meeting the 
  minimum requirements?

## Karma 

You are highly encouraged to go beyond the minimal requirements for this
assignment as described above. But, no matter what you implement, be
sure to maintain compatibility with the basic adventure file format and
required commands.  Note that it should be possible to add additional
information (e.g., properties and objects) to the JSON file and still
remain compatible with the required schema.  Your karma
implementation must not cause you to change or violate the
specifications of any of the functions in the provided interfaces.  It's
true that might rule out some cool features that you have in mind, but
we hope you understand that the course staff must be able to run 
your solution through our autograder with those interfaces.

**Experienced Adventurer:**

* item sizes and weights, and inventory limits on those
* game save and restore
* consumable items (e.g., money, which could be earned and spent)
* time passing as adventurer explores, with effects occurring as a result
  (e.g., the sun rises and sets, and what is possible changes as a result)
* other in-game characters (which could be stationary or could themselves
  wander around) with which the adventurer can have conversations
* the adventurer getting lost in a maze

**Seasoned Adventurer:**

* an automated bot that completes adventures without human assistance  
* flexible command parsing so that users can type in interesting natural
  language instead of two-word commands
* a larger vocabulary of commands that enables designers to create puzzles
  and players to solve them (e.g., manipulating items and rooms&mdash;locks and
  keys are a good place to start)
  
**Master Adventurer:**

* text-based graphics to display images of rooms, a map of the area
  explored so far, etc.
* a level editor that makes it easy for designers to create adventure files
  without having to write JSON themselves

* * *

**Acknowledgement:** 
Adapted from Prof. Michael Clarkson (Cornell University),
who in turn adapted it from Prof. John Estell (Ohio Northern University).
# cs3110 a2

# 程序代做代写 CS编程辅导

# WeChat: cstutorcs

# Email: tutorcs@163.com

# CS Tutor

# Code Help

# Programming Help

# Computer Science Tutor

# QQ: 749389476
