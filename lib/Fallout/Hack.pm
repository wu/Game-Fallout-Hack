package Fallout::Hack;
use strict;
use warnings;

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

sub score_words {
    my ( @words ) = @_;

    my $indexes;
    my $matches;
    for my $word ( @words ) {
        for my $idx ( 0 .. length( $word ) - 1 ) {
            my $char = substr( $word, $idx, 1 );
            $indexes->{$idx}->{$char}++;
            $matches->{$idx}->{$char}->{$word}++;
        }
    }

    my $scores;
    for my $word ( @words ) {

        for my $idx ( 0 .. length( $word ) - 1 ) {
            my $char = substr( $word, $idx, 1 );

            # add the rank of this letter in this substring index to the
            # total score of this word
            $scores->{$word} += $indexes->{$idx}->{$char} * $indexes->{$idx}->{$char};
        }
    }

    return $scores;
}

sub recommend_guess {
    my ( $count, @words ) = @_;

    my $guess;

    #print "RECOMMENDING GUESS # $count\n";

    if ( scalar @words == 1 ) {
        die "ERROR: asked to recommend guess, but only given one word!";
    }

    if ( $count == 1 ) {
        $guess = recommend_guess_middle_score( @words );
    }
    elsif ( $count == 2 ) {
        $guess = recommend_guess_middle_score( @words );
    }
    elsif ( $count == 3 ) {
        $guess = recommend_guess_highest_score( @words );
    }
    elsif ( $count == 4 ) {
        $guess = recommend_guess_highest_score( @words );
    }
    else {
        die "No count specified?"
    };

    print "RECOMMENDING GUESS # $count => $guess\n";

    return $guess;
}

# just pick the first one in alphabetical order
sub recommend_guess_first {
    my ( @words ) = @_;

    @words = sort @words;

    return $words[0];
}

sub recommend_guess_highest_score {
    my ( @words ) = @_;

    my $scores = score_words( @words );

    my $highest_num = 0;
    my $highest_name;

    for my $name ( sort keys %{ $scores } ) {
        #print "NAME:$name SCORE:$scores->{$name}\n";
        if ( $scores->{ $name } > $highest_num ) {
            $highest_num = $scores->{ $name };
            $highest_name = $name;
        }
    }

    return $highest_name;
}

sub recommend_guess_lowest_score {
    my ( @words ) = @_;

    my $scores = score_words( @words );

    my $highest_num = $scores->{ $words[0] };
    my $highest_name;

    for my $name ( sort keys %{ $scores } ) {
        #print "NAME:$name SCORE:$scores->{$name}\n";
        if ( $scores->{ $name } < $highest_num ) {
            $highest_num = $scores->{ $name };
            $highest_name = $name;
        }
    }

    return $highest_name;
}

sub recommend_guess_middle_score {
    my ( @words ) = @_;

    my $word_scores = score_words( @words );

    my $score_words;
    my $max_score = 0;
    for my $word ( sort keys %{ $word_scores } ) {
        $score_words->{ $word_scores->{$word} } = $word;

        if ( $word_scores->{$word} > $max_score ) { $max_score = $word_scores->{$word} }
    }

    my $sum;
    for my $word ( sort keys %{ $word_scores } ) {
        $sum += $word_scores->{$word};
    }

    # start with the average
    my $guess = int( $sum / (scalar @words) );

    # go slightly above the average, better scores so far
    $guess += 1;

    print "SUM:$sum GUESS ID: $guess\n";

    my $name;
    for my $guess_id ( $guess .. $max_score ) {
        if ( $score_words->{ $guess_id } ) {
            return $score_words->{ $guess_id };
        }
    }

    die "ERROR: unable to get word with middle score";

}

1;
