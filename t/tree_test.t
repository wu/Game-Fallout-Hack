#!/perl
use strict;
use warnings;

use Test::More;

use Fallout::Hack;

#my $answer = "fall";
#my @words = qw( pray task raid lamp maul fall cave wave rats pays lays );

my $answer = "seems";
my @words = qw( aways taunt plush alert loose looks gangs takes seems scene logic );

#Fallout::Hack::recommend_guess_tree( 1, @words );

Fallout::Hack::full_guess_tree( @words );

done_testing;



# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# wayward: requiem insigne seizing gantlet wayward contort decrees muggier grenade eatable skeptic
# Warning: 1 trees are dead ends, running simulation with first guess
# found dead ends, checking next two guesses
# Found a path with no failures: requiem
# ok 3352 - Getting a recommended guess: requiem
# ok 3353 - Plugging the recommended word back into guess: 6 left
# ok 3354 - Getting a recommended guess: grenade
# ok 3355 - Plugging the recommended word back into guess: 4 left
# ok 3356 - Getting a recommended guess: eatable
# ok 3357 - Plugging the recommended word back into guess: 2 left
# not ok 3358 - Checking that final word was found: wayward
# #   Failed test 'Checking that final word was found: wayward'
# #   at t/tests.t line 104.
# #     Structures begin differing at:
# #          $got->[0] = 'insigne'
# #     $expected->[0] = 'wayward'
# ok 3359 - Checking that answer was found by the 4th guess
# GUESSES=1364 TESTS=546  AVG=2.4981684981685  FAIL=1
