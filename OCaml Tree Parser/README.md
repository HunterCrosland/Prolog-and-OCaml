This is a Grammar Parser written in OCaml using tree logic.
I wrote a brief in tree_parser_explained.txt which reads:

To solve this problem, I decided to write make_parser in terms of make_matcher:

It seemed like the obvious approach to do it this way, since make_matcher does
all the same work as make_parser, except that it doesn't create a tree.
Creating the tree was as simple as changing a bit of the logic around so that
a Node was created at all points where a new make_parser was called, be it an
appended (nested) matcher, or an or_matcher.

I think I could have potentially avoided the look-alike code by separating logic
from make_or_matcher and make_appended_matchers and using make_matcher as a
router function, similar to how the DNA parser worked in the hw2 hint. I tried
this for a while, but ultimately was struggling with passing make_a_matcher
properly without mutual recursion. If there was a case, for example, where I
needed to nest an or_matcher, I could not figure out the logic for 
make_a_matcher being one or the other at the appropriate times. 

Had I been able to do this, I think I could have used my exact code for 
make_matcher but with a new router in make_parser to create the nodes and 
leaves, which would have meant I had more reusable code.

My approach to the actual make_matcher was to create a mutually recursive set 
of functions make_or_matcher and make_appended_matchers that dealt with 
situations where I needed to check new grammar rules due to the failure of one 
(make_or_matcher) and where I needed to use a set of established grammar rules 
to check against a fragment of terminal rules (make_appended_matchers). 
My strategy was to nest matchers with make_appended_matchers so that I would 
only get a result if the stack trace always returned Some.

There is a major weakness in the make_matcher and make_parser functions due to
the possibility of infinite recursion. If, for example, I swap the first N Term 
in awksub grammar (the one that arises from Expr) to N Expr, my matcher will not
work due to the fact that it will infinitely recurse. It will continue checking
Expr goes to Expr until there is a stack overflow error. This is of course a
major problem if our grammar's first rule allows for Expr to go to itself, which
it ought to, because this makes the matcher (and consequently, the parser)
completely useless the moment it faces an actual grammatically sound language
with a modicum of complexity. 

Another potential weakness of the matcher function is its tendency to find the 
first possible, and therefore not necessarily most sound, match for a 
given fragment. This means that it will sometimes pass a suffix into the 
acceptor before it has fully parsed the fragment, meaning that if I am 
accepting any suffix as a legitimate suffix, there could be another viable 
grammar match for the fragment that my matcher does not find.

This project certainly had its trickiness, and most of it, as with homework 1,
lay in the syntax of OCaml over anything else. Finding ways to properly forward
arguments and functors was a major challenge, and led to a bit of nasty 
argumentation, particularly in my parser. I would have liked to be able to split
the functionality of make_matcher and make_parser into multiple functions, but
I found this was the easiest way to accomplish the task at hand.
