#!/perl
use strict;
use warnings;

use Test::More;
use YAML;

use Fallout::Hack;

{
    ok( Fallout::Hack::matches_string( 'a', 'a', 1 ),
        "Checking that string 'a' matches string 'a' in 1 position"
    );

    ok( Fallout::Hack::matches_string( 'abc', 'abc', 3 ),
        "Checking that string 'abc' matches string 'abc' in 3 positions"
    );

    ok( ! Fallout::Hack::matches_string( 'abc', 'abd', 3 ),
        "Checking that string 'abc' does not match string 'abd' in 3 positions"
    );

    ok( Fallout::Hack::matches_string( 'wastes', 'insane', 1 ),
        "Checking that string 'wastes' matches string 'insane' in 1 positions"
    );
}

my @tests = (
    {
        answer => 'silver',
        words => [ qw( fierce pleads insane shiner wagons ripped visage crimes silver tables wastes ) ],
    },
    {
        answer => 'cult',
        words => [ qw( cult kind bill warm pare good loud labs furs pots boss ) ],
    },
    {
        answer => 'take',
        words => [ qw( self atop join shot four once ways take hair mood mace ) ],
    },
    {
        answer => 'lamp',
        words => [ qw( dens flat pays full farm lamp colt chip crap cain call ) ],
    },
    {
        answer => 'scene',
        words => [ qw( scene start minds flame types while aware alien fails wires sizes ) ],

    },
    {
        answer => 'instore',
        words => [ qw( fanatic objects instore warning welfare offense takings stunned becomes invaded decried ) ],
    },
    {
        answer => 'four',
        words => [ qw( ball call cape colt does evil face four hope owed pots ) ],
    },
    {
        answer => 'spokes',
        words => [ qw( across devoid handle herald jacket marked movies random rather refuse spokes ) ],
    },
    {
        answer => 'silks',
        words => [ qw( allow silks rolls comes wires sever haven again clear paper pulls ) ],
    },
    {
        answer => 'because',
        words => [ qw( cleared allowed thieves because greeted between stained watched streets country dwindle ) ],
    },
    {
        answer => 'gift',
        words => [ qw( gift iron last lots mood nice none oily seat shop spin ) ],
    },
    {
        answer => 'wants',
        words => [ qw( spies robes dress wants james posed rates radio ready sells tires ) ],
    },
    {
        answer => 'fall',
        words => [ qw( pray task raid lamp maul fall cave wave rats pays lays ) ],
    },
    {
        answer => 'speed',
        words => [ qw( death orbit usual joins broke level scope would speed scent weird ) ],
    },
    {
        answer => 'waves',
        words => [ qw( butch clock hatch kinds lance peace ranks rubes scant skins waves ) ],
    },
);

my $total_guesses = 0;
my $test_number   = 0;

for my $test ( @tests ) {

    $test_number++;
    print ">"x77, "\n";
    print "TEST NUMBER $test_number\n";

    my @words = @{ $test->{words} };
    my $answer = $test->{answer};

    my @test_words = ( @words );

    my $count;
  COUNT:
    for ( 1 .. 3 ) {
        $count = $_;
        $total_guesses++;

        my $recommended;
        ok( $recommended = Fallout::Hack::recommend_guess( $count, @test_words ),
            "Getting a recommended guess: $recommended"
        );

        if ( $recommended eq $answer ) {
            print "Correct guess: $answer\n";
            @test_words = ( $recommended );
            last COUNT;
        }

        my $match_count = Fallout::Hack::calculate_match_count( $recommended,
                                                                $answer,
                                                            );

        my @new_test_words;
        ok( @new_test_words = Fallout::Hack::guess( \@test_words, $recommended, $match_count ),
            "Plugging the recommended word back into guess: " . scalar @new_test_words . " left"
        );

        @test_words = @new_test_words;
    }

    is_deeply( [ @test_words ],
               [ $answer ],
               "Checking that final word was found: $answer"
           );

    ok( $count <= 4,
        "Checking that answer was found by the 4th guess"
    );

}

my $num_tests = scalar @tests;
my $avg_guesses = $total_guesses / $num_tests;

print "\nGUESSES=$total_guesses TESTS=$num_tests  AVG=$avg_guesses\n";

done_testing;
