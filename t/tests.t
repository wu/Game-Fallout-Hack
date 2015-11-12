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
);

for my $test ( @tests ) {

    my %words = %{ $test->{words} };
    my $answer = $test->{answer};
    my @words = keys %words;

    is_deeply( Fallout::Hack::score_words( @words ),
               \%words,
               "Checking word scores"
           );

    my @test_words = ( @words );
    for my $count ( 1 .. 3 ) {

        my $recommended;
        ok( $recommended = Fallout::Hack::recommend_guess( $count, @test_words ),
            "Getting a recommended guess: $recommended"
        );

        my $match_count = Fallout::Hack::calculate_match_count( $recommended,
                                                                $answer,
                                                            );

        my @new_test_words;
        ok( @new_test_words = Fallout::Hack::guess( \@test_words, $recommended, $match_count ),
            "Plugging the recommended word back into guess: " . scalar @new_test_words . " left"
        );

         @test_words = @new_test_words;
    }

    #print YAML::Dump { remaining => \@test_words };

    ok( scalar @test_words == 1,
        "Checking that test word was identified by the 3rd guess"
    );

}



done_testing;


