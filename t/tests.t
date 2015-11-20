#!/perl
use strict;
use warnings;

use Test::More;

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

my $test_number   = 0;
my $total_guesses = 0;

for my $line ( <DATA> ) {
    $test_number++;
    print ">"x77, "\n";

    chomp $line;

    my ( $answer, $words_string ) = split /\:\s+/, $line;
    my @test_words = split /\s+/, $words_string;

    my $guesses;
  COUNT:
    for my $count ( 1 .. 3 ) {
        $guesses++;
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

    ok( $guesses <= 4,
        "Checking that answer was found by the 4th guess"
    );

    my $avg_guesses = $total_guesses / $test_number;
    print "GUESSES=$total_guesses TESTS=$test_number  AVG=$avg_guesses\n";
}


done_testing;

__DATA__
silver: fierce pleads insane shiner wagons ripped visage crimes silver tables wastes
cult: cult kind bill warm pare good loud labs furs pots boss
take: self atop join shot four once ways take hair mood mace
lamp: dens flat pays full farm lamp colt chip crap cain call
scene: scene start minds flame types while aware alien fails wires sizes
instore: fanatic objects instore warning welfare offense takings stunned becomes invaded decried
four: ball call cape colt does evil face four hope owed pots
spokes: across devoid handle herald jacket marked movies random rather refuse spokes
silks: allow silks rolls comes wires sever haven again clear paper pulls
because: cleared allowed thieves because greeted between stained watched streets country dwindle
gift: gift iron last lots mood nice none oily seat shop spin
wants: spies robes dress wants james posed rates radio ready sells tires
fall: pray task raid lamp maul fall cave wave rats pays lays
speed: death orbit usual joins broke level scope would speed scent weird
waves: butch clock hatch kinds lance peace ranks rubes scant skins waves
