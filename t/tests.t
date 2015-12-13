#!/perl
use strict;
use warnings;

use Test::More;

use Fallout::Hack;

#############################################################################
#
# 7 letter words
#   - after:  GUESSES=250670 TESTS=100039  AVG=2.50  FAIL=29
#   - before: GUESSES=247883 TESTS=100016  AVG=2.47  FAIL=2343
#
# 6 letter words
#   - after:  GUESSES=252486 TESTS=100041  AVG=2.52  FAIL=112
#   - before: GUESSES=250464 TESTS=100016  AVG=2.50  FAIL=3363
#
# 5 letter words
#   - after:  GUESSES=254769 TESTS=100041  AVG=2.54  FAIL=498
#   - before: GUESSES=252954 TESTS=100015  AVG=2.52  FAIL=5136
#
#############################################################################

# to enable randomly generated test cases, set this to the number of
# random tests you want to generate
my $random_tests = 0;

#############################################################################

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
my $total_failures = 0;

for my $line ( <DATA> ) {
    chomp $line;
    next unless $line;
    my ( $answer, $words_string ) = split /\:\s+/, $line;
    my @words = split /\s+/, $words_string;
    run_test( $answer, @words );
}

if ( $random_tests ) {
    print "Getting word list...\n";
    my @all_words = split /\n/, `cat t/5_word_list`;
    my $num_words = scalar @all_words;
    print "WORDS: num_words\n";

    for ( 1 .. $random_tests ) {

        my @words;
        for ( 1 .. 11 ) {
            my $num = int( rand( $num_words ) );
            push @words, $all_words[$num];
        }

        my $answer = $words[ int( rand( 11 ) ) ];

        run_test( $answer, @words );
    }

}

sub run_test {
    my ( $answer, @test_words ) = @_;
    print ">"x77, "\n";
    print "$answer: ", join( " ", @test_words ), "\n";

    $test_number++;

    my @recommended;

    my $guesses;
  COUNT:
    for my $count ( 1 .. 3 ) {
        $guesses++;
        $total_guesses++;

        unless ( @recommended ) {
            @recommended = Fallout::Hack::full_guess_tree( $count, @test_words );
        }

        my $recommended = shift @recommended;

        print "Recommended: $recommended\n";

        ok( $recommended,
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
            "Plugging the recommended word back into guess: $match_count matches: " . scalar @new_test_words . " left"
        );

        @test_words = @new_test_words;
    }

    is( Fallout::Hack::full_guess_tree( 4, @test_words ),
        $answer,
        "Checking that final word was found: $answer"
    ) or $total_failures++;

    ok( $guesses <= 4,
        "Checking that answer was found by the 4th guess"
    );

    my $avg_guesses = $total_guesses / $test_number;
    print "GUESSES=$total_guesses TESTS=$test_number  AVG=$avg_guesses  FAIL=$total_failures\n";
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
trip: hand send dens task trip went says beam cold soap none
elders: remain armies result almost taurus rescue failed timers report knight elders
round: above booty round voice large thick taint scarf crude ready shops
poised: befell utmost slight mongol poised locals ripped single ritual result couple
sides: range waves owned raids sides stead races raise state owner hired
dropped: dropped captain routing ceiling packing closest fertile helping caliber founded desired
past: past lays huts walk camp sash line role last garl dais
plan: huts hear wear fork very loan feat pack rank plan away food
cast: fuse fork cast rule tall soil felt rank fuel here tarp
vast: deed read rush sash rats dead also owed vast held sets
does: very well wars does fork huts fell fear cool term fury
exit: sung stay exit weak spin yeah wish step star mass seen
hearts: hearts travel blamed paying dapper beaten passes caring healed wealth worked
ripper: teevee driver thinks shiner temple status ripper common spoils center yields
vipers: vipers justin mirror wooden hauled bundle street failed misers anyone erupts
ages: gang ages deep gain none nice lift owns lose seem salt
befell: shovel minute bowels raider prayer seemed oxygen module single befell debate
tore: foul four egos tore goes fell join golf core song soul
seems: aways taunt plush alert loose looks gangs takes seems scene logic
section: dragons staying hurting parties winning reached captain outcast signals section reading
godfather: radiation crumbling engineers projector surviving defensive discovery godfather monocolor situation murderous
same: died hits wars furs fork goes walk used holy same part
chooses: reduced shelter thrower worried tonight erected strange turrets chooses hundred godlike
armor: thugs notes cache board truth shady armor games slips speed catch
retreated: sponsored increased processor violently wastelord clockwork secretive kidnapped delimiter retreated desperate
expose: riches cattle limped figure rocket expose caught immune gained listed rifles
