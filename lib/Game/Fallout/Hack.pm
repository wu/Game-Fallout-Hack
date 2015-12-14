package Game::Fallout::Hack;
use strict;
use warnings;

use Scalar::Util qw(looks_like_number);

=head1 NAME

Game::Fallout::Hack - terminal hacking for Fallout game series

=head1 SYNOPSIS

    use Game::Fallout::Hack;

    # note: see the included script in bin/, no need to use this library directly

    # get a recommendation for the first guess
    my $recommended = Game::Fallout::Hack::recommend( 1, @words );

    # given the number of letters that were in common, determine the
    # remaining valid words
    my @remaining_words = Game::Fallout::Hack::guess( \@words, $recommended, $num_letters );

    # get a recommendation for the second guess
    my $recommended = Game::Fallout::Hack::recommend( 2, @remaining_words );

=head1 DESCRIPTION

The recent titles in the Fallout game series contains terminals that
must be 'hacked' in order to gain access.  The 'hack' involves
presenting a list of up to 11 words of identical length, and requiring
the user to try to guess which one is correct.  When the player
guesses an incorrect word, they are told how many letters their guess
has in common in the same position (the 'likeness' score) with the
correct answer word.  The player is allowed 4 guesses to solve the
puzzle, although there may be opportunities to increase the number of
guesses.

There are numerous other sites on the web that offer to help solve
this challenge.  Most simply pick a word at random from the available
words, and then automate the removal of the invalid selections.  Some
go so far as to score the words based on the number of characters in
certain positions.

This library employs a simulation method.  Each time a guess is made,
it runs a simulation in which every word is considered as the
potential answer.  It plays out the simulation for each answer, trying
to guess using every other word in every valid permutation to reach
the answer.  The key here is to identify all the paths that lead to
failure, i.e. where valid answers were given at every guess, but not
all simulated answers could be guessed within four tries.  That
information is then used to pick a next guess word that has the least
potential chance of failure.  The chance for success is assured if a
guess has no failure paths associated with it, i.e. it led to
successfully guessing every other remaining word in the simulation
within the remaining tries.  If the chance of success is not assured,
then some feedback is given about the number of failure paths that
remain.

=head1 FITNESS

In the process of crafting this algorithm, I generated random tests
for words of various lengths.  Here is a comparison of 100k tests
using each strategy for a few different work lengths.  AVG is the
average number of guesses required to solve each test, and FAIL is the
number of tests that were not successfully answered within 4 guesses.

Note that none of these strategies ever pick a 'bad' answer,
i.e. they only pick words that are valid based on the likeness values
revealed by previous attempts.

Also note that as words length increases, the failure rate decreases.
Longer words are easier to solve since more information is available.

=head2 Random

This strategy looks at the available valid choices and simply picks
one at random.

 7 letter words: AVG=2.55  FAIL=4320
 6 letter words: AVG=2.57  FAIL=6767
 5 letter words: AVG=2.59  FAIL=10671

=head2 Similarity Score

This strategy scores each word based on the number of characters it
has in the same position as other words.  The word with the highest
score provides the most information, and will produce the highest
success rate.

 7 letter words: AVG=2.47  FAIL=2343
 6 letter words: AVG=2.50  FAIL=3363
 5 letter words: AVG=2.52  FAIL=5136

The failure rates here are roughly half of the failure rates of
randomly generated answers.

=head2 Simulation

This is the strategy employed by the current library.  See the
DESCRIPTION for a longer explanation.

 7 letter words: AVG=2.50  FAIL=29
 6 letter words: AVG=2.52  FAIL=112
 5 letter words: AVG=2.54  FAIL=498

Note that the failure rates are less than 1/10th of the failure rate
of the similarity score method for 5 letter words, and closer to 1/100
for 7 letter words.


=head1 SUBROUTINES/METHODS

=over 8


=item calculate_match_count( $word1, $word2 )

Given two words, determine the number of letters in common in the
identical position.  For example, 12345 and 11355 would return '3'
characters, since the first 1, the 3, and the last 5 are in the same
positions.

=cut

sub calculate_match_count {
    my ( $word1, $word2 ) = @_;

    my $count_matched = 0;

    unless ( length $word1 eq length $word2 ) {
        die "ERROR: calculate_match_count called with different length strings: '$word1' vs '$word2'";
    }

    for my $idx ( 0 .. length( $word1 ) - 1 ) {
        if ( substr( $word1, $idx, 1 ) eq substr( $word2, $idx, 1 ) ) {
            $count_matched++;
        }
    }

    return $count_matched;
}

=item matches_string( $word1, $word2, $num_letters )

Determine if two words have a given number of letters in common.
Returns true if the two words are the given number of characters
apart.

=cut


sub matches_string {
    my ( $word1, $word2, $num_letters ) = @_;

    my $count_matched = calculate_match_count( $word1, $word2 );

    #print "MATCHES: $word1 $word2 = $count_matched\n";

    if ( $count_matched == $num_letters ) {
        return 1;
    }

    return;

}

=item guess( \@words, $guess_word, $match_count )

Given a set of words, a word that was guessed, and the number of
characters that were reported as matching, return the list of valid
remaining words.

=cut

sub guess {
    my ( $words_a, $guess, $match_count ) = @_;

    my @results;

    for my $word ( sort @{ $words_a } ) {

        if ( matches_string( $word, $guess, $match_count )  ) {
            push @results, $word;
        }

    }

    return @results;
}

=item recommend( $guess_number, @words )

Given a list of words, and the number of the guess (1 through 4), run
the simulator to generate a recommendation.

=cut

sub recommend {
    my ( $guess, @words ) = @_;

    unless ( looks_like_number( $guess ) ) {
        die "ERROR: called guess, but failed to supply a guess number as the first argument";
    }

    # consider all possible answers to search for failure paths
    my %failures;
    for my $answer_word ( @words ) {

        # consider all possible choices
        for my $first_guess_word ( @words ) {
            next if $first_guess_word eq $answer_word;

            # if this was the 4th guess and we didn't get the answer, we failed
            if ( $guess == 4 ) {
                $failures{$first_guess_word}->{"$first_guess_word"} = $answer_word;
                next;
            }

            # eliminate invalid words from the remaining selection
            my $first_match_count = calculate_match_count( $first_guess_word, $answer_word );
            my @first_remaining_words = guess( \@words,
                                               $first_guess_word,
                                               $first_match_count
                                           );
            my $first_remaining_words_count = scalar @first_remaining_words;

            for my $second_guess_word ( @first_remaining_words ) {
                next if $second_guess_word eq $answer_word;

                # if this was the 3rd guess and we didn't get the answer, we failed
                if ( $guess == 3 ) {
                    $failures{$first_guess_word}->{"$second_guess_word"} = $answer_word;
                    next;
                }

                # eliminate invalid words from the remaining selection
                my $second_match_count = calculate_match_count( $second_guess_word, $answer_word );
                my @second_remaining_words = guess( \@first_remaining_words,
                                                    $second_guess_word,
                                                    $second_match_count
                                                );
                my $second_remaining_words_count = scalar @second_remaining_words;

                for my $third_guess_word ( @second_remaining_words ) {
                    next if $third_guess_word eq $answer_word;

                    # if this was the 2nd guess and we didn't get the answer, we failed
                    if ( $guess == 2 ) {
                        $failures{$first_guess_word}->{"$second_guess_word.$third_guess_word"} = $answer_word;
                        next;
                    }

                    # eliminate invalid words from the remaining selection
                    my $third_match_count = calculate_match_count( $third_guess_word, $answer_word );
                    my @third_remaining_words = guess( \@second_remaining_words,
                                                        $third_guess_word,
                                                       $third_match_count
                                                   );
                    my $third_remaining_words_count = scalar @third_remaining_words;

                    for my $fourth_guess_word ( @third_remaining_words ) {
                        next if $fourth_guess_word eq $answer_word;

                        # this was the fourth guess and we didn't get the answer, so we failed
                        $failures{$first_guess_word}->{"$second_guess_word.$third_guess_word.$fourth_guess_word"} = $answer_word;
                    }
                }
            }
        }
    }

    # all possibilities have been considered, and the simulation is
    # complete.  now to identify the next guess word that has the
    # least number of failure paths.

    my $min_score = 99999;
    my $min_score_word;

    for my $word ( sort @words ) {

        # if we find a word that is free of failure paths, select it immediately!
        if ( ! exists $failures{$word} ) {
            print "No failure paths found => $word\n";
            return $word;
        }

        # check if the number of failures is less than any other we've seen so far
        my $failure_count = scalar keys %{ $failures{$word} };
        if ( $failure_count < $min_score ) {
            $min_score = $failure_count;
            $min_score_word = $word;
        }
    }

    # return the word with the least number of failure paths
    print "Least failure paths found = $min_score => $min_score_word\n";
    return $min_score_word;
}


1;

__END__

=back

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2015, VVu@geekfarm.org
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

- Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



