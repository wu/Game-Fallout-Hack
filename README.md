DESCRIPTION
==============

The recent titles in the Fallout game series contains terminals that
must be 'hacked' in order to gain access.  The 'hack' involves
presenting a list of 11 words of identical length, and requiring the
user to try to guess which one is correct.  When the player guesses an
incorrect word, they are told how many letters their guess has in
common in the same position (the 'likeness' score) with the correct
answer word.  The player is allowed 4 guesses to solve the puzzle,
although there may be opportunities to increase the number of guesses.

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

FITNESS
==============

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

Random
--------------

This strategy looks at the available valid choices and simply picks
one at random.

- 7 letter words: AVG=2.55  FAIL=4320
- 6 letter words: AVG=2.57  FAIL=6767
- 5 letter words: AVG=2.59  FAIL=10671

This strategy is equivalent to picking the first available valid
choice if you were trying to work out the answer by hand, assuming
that the words are randomly selected, and order is not relevant.


Similarity Score
--------------

This strategy scores each word based on the number of characters it
has in the same position as other words.  The word with the highest
score provides the most information, and will produce the highest
success rate.

- 7 letter words: AVG=2.47  FAIL=2343
- 6 letter words: AVG=2.50  FAIL=3363
- 5 letter words: AVG=2.52  FAIL=5136

The failure rates here are roughly half of the failure rates of
randomly generated answers.

Simulation
--------------

This is the strategy employed by the current library.  See the
DESCRIPTION for a longer explanation.

- 7 letter words: AVG=2.50  FAIL=29
- 6 letter words: AVG=2.52  FAIL=112
- 5 letter words: AVG=2.54  FAIL=498

Note that the failure rates are roughly 1/10th of the failure rate of
the similarity score method.
