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
        words => {
            fierce => 12,
            pleads => 13,
            insane => 13,
            shiner => 14,
            wagons => 14,
            ripped => 14,
            visage => 15,
            crimes => 16,
            silver => 16,
            tables => 17,
            wastes => 20,
        }
    },
    {
        answer => 'cult',
        words => {
            cult => 6,
            kind => 7,
            bill => 7,
            warm => 8,
            pare => 9,
            good => 9,
            loud => 10,
            labs => 10,
            furs => 10,
            pots => 11,
            boss => 11,
        },
    },
    {
        answer => 'take',
        words => {
            self => 5,
            atop => 6,
            join => 7,
            shot => 7,
            four => 7,
            once => 7,
            ways => 7,
            take => 9,
            hair => 9,
            mood => 9,
            mace => 11,
        }
    },
    {
        answer => 'lamp',
        words => {
            dens => 5,
            flat => 8,
            pays => 9,
            full => 9,
            farm => 10,
            lamp => 10,
            colt => 11,
            chip => 11,
            crap => 11,
            cain => 13,
            call => 15,
        }
    },
    {
        answer => 'scene',
        words => {
            scene => 10,
            start => 10,
            minds => 11,
            flame => 12,
            types => 12,
            while => 12,
            aware => 12,
            alien => 12,
            fails => 13,
            wires => 15,
            sizes => 16,
        },

    },
    {
        answer => 'instore',
        words => {
            fanatic => 10,
            objects => 11,
            instore => 12,
            warning => 12,
            welfare => 13,
            offense => 13,
            takings => 13,
            stunned => 15,
            becomes => 15,
            invaded => 15,
            decried => 16,
        }
    },
    {
        answer => 'four',
        words => {
            ball => 11,
            call => 13,
            cape => 12,
            colt => 12,
            does => 10,
            evil => 6,
            face => 10,
            four => 9,
            hope => 11,
            owed => 5,
            pots => 9,
        }
    },
    {
        answer => 'spokes',
        words => {
            across => 28,
            devoid => 28,
            handle => 45,
            herald => 36,
            jacket => 62,
            marked => 81,
            movies => 44,
            random => 44,
            rather => 62,
            refuse => 28,
            spokes => 46,
        }
    },
    {
        answer => 'silks',
        words => {
            allow => 1,
            silks => 1,
            rolls => 1,
            comes => 1,
            wires => 1,
            sever => 1,
            haven => 1,
            again => 1,
            clear => 1,
            paper => 1,
            pulls => 1,
        }
    },
);

my $total_guesses = 0;
my $test_number   = 0;

for my $test ( @tests ) {

    $test_number++;
    print ">"x77, "\n";
    print "TEST NUMBER $test_number\n";

    my %words = %{ $test->{words} };
    my $answer = $test->{answer};
    my @words = keys %words;

    # is_deeply( Fallout::Hack::score_words( @words ),
    #            \%words,
    #            "Checking word scores"
    #        );

    my @test_words = ( @words );

    my $count;
  COUNT:
    for ( 1 .. 4 ) {
        $count = $_;

        my $recommended;
        ok( $recommended = Fallout::Hack::recommend_guess( $count, @test_words ),
            "Getting a recommended guess: $recommended"
        );

        $total_guesses++;

        my $match_count = Fallout::Hack::calculate_match_count( $recommended,
                                                                $answer,
                                                            );

        my @new_test_words;
        ok( @new_test_words = Fallout::Hack::guess( \@test_words, $recommended, $match_count ),
            "Plugging the recommended word back into guess: " . scalar @new_test_words . " left"
        );

        @test_words = @new_test_words;

        if ( scalar @test_words == 1 ) {
            $total_guesses++;
            $count++;
            print "FINAL GUESS #$count = ", @test_words, "\n";
            last COUNT;
        }
    }

    is_deeply( [ @test_words ],
               [ $answer ],
               "Checking that final word was found: $answer"
           );

    ok( $count <= 4,
        "Checking that answer was found by the 4th guess"
    );

}

print "\nTOTAL TESTS: $total_guesses\n";

done_testing;
