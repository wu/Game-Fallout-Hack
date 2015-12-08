package Fallout::Hack;
use strict;
use warnings;

use Scalar::Util qw(looks_like_number);

sub matches_string {
    my ( $word1, $word2, $num_letters ) = @_;

    my $count_matched = calculate_match_count( $word1, $word2 );

    #print "MATCHES: $word1 $word2 = $count_matched\n";

    if ( $count_matched == $num_letters ) {
        return 1;
    }

    return;

}

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

sub full_guess_tree {
    my ( $guess, @words ) = @_;

    unless ( looks_like_number( $guess ) ) {
        die "ERROR: called full_guess_tree, but failed to supply a guess number as the first argument";
    }

    my %failures;

    # consider all possible answers
    for my $answer_word ( @words ) {

        # consider all possible choices
        for my $first_guess_word ( @words ) {
            next if $first_guess_word eq $answer_word;

            if ( $guess == 4 ) {
                $failures{$first_guess_word}->{"$first_guess_word"} = $answer_word;
                next;
            }

            my $first_match_count = calculate_match_count( $first_guess_word, $answer_word );
            my @first_remaining_words = guess( \@words,
                                               $first_guess_word,
                                               $first_match_count
                                           );
            my $first_remaining_words_count = scalar @first_remaining_words;

            for my $second_guess_word ( @first_remaining_words ) {
                next if $second_guess_word eq $answer_word;

                if ( $guess == 3 ) {
                    $failures{$first_guess_word}->{"$second_guess_word"} = $answer_word;
                    next;
                }

                my $second_match_count = calculate_match_count( $second_guess_word, $answer_word );
                my @second_remaining_words = guess( \@first_remaining_words,
                                                    $second_guess_word,
                                                    $second_match_count
                                                );
                my $second_remaining_words_count = scalar @second_remaining_words;

                for my $third_guess_word ( @second_remaining_words ) {
                    next if $third_guess_word eq $answer_word;

                    if ( $guess == 2 ) {
                        $failures{$first_guess_word}->{"$second_guess_word.$third_guess_word"} = $answer_word;
                        next;
                    }

                    my $third_match_count = calculate_match_count( $third_guess_word, $answer_word );
                    my @third_remaining_words = guess( \@second_remaining_words,
                                                        $third_guess_word,
                                                       $third_match_count
                                                   );
                    my $third_remaining_words_count = scalar @third_remaining_words;

                    for my $fourth_guess_word ( @third_remaining_words ) {
                        next if $fourth_guess_word eq $answer_word;

                        $failures{$first_guess_word}->{"$second_guess_word.$third_guess_word.$fourth_guess_word"} = $answer_word;
                    }
                }
            }
        }
    }

    my $min_score = 99999;
    my $min_score_word;

    for my $word ( sort @words ) {

        if ( ! exists $failures{$word} ) {
            print "No failure paths found => $word\n";
            return $word;
        }

        my $failure_count = scalar keys %{ $failures{$word} };
        if ( $failure_count < $min_score ) {
            $min_score = $failure_count;
            $min_score_word = $word;
        }
    }

    print "Least failure paths found = $min_score => $min_score_word\n";
    return $min_score_word;
}

1;
