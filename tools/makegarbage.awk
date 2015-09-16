#!/usr/bin/awk -f
#
# Prints random words from the wordlist, ensuring that each
# character is represented.
#
# Usage: makegarbage.awk < wordlist

BEGIN {
	repeats = 2;
	maxlinechars = 55;
	# 500 possibilities per character is plenty, and limiting
	# this keeps memory usage under control
	maxwordsperchar = 500 * repeats;
	srand(1);
}

{
	# Store the word in arrays for each character it contains.
	for(i = 1; i <= length($1); i++) {
		c = substr($1, i, 1);

		# Initialise numwords[c] so it can be used as an
		# array index.
		if(numwords[c] == 0) {
			numwords[c] = 0;
		}

		# Don't save the word if we already have enough
		# words for that character.
		if(numwords[c] >= maxwordsperchar) {
			continue;
		}

		# Increment the numwords count for character and
		# add the word to the words array for character.
		words[c "," numwords[c]] = $1;
		numwords[c]++;

		# Store the character in the chars string if it
		# hasn't been seen before.
		charexists = 0;
		for(n = 0; n < numchars; n++) {
			if(chars[n] == c) {
				charexists = 1;
				break;
			}
		}
		if(!charexists) {
			chars[numchars++] = c;
		}
	}
}

END {
	for(n = 0; n < repeats; n++) {
		for(i = 0; i < numchars; i++) {
			c = chars[i];
			# Select a random word from the list of words
			# that contain the character.
			wordindex = int(rand() * numwords[c]);
			printf("%s", words[c "," wordindex]);

			linechars += length(words[c "," wordindex]) + 1;
			if(linechars > maxlinechars) {
				printf("\n");
				linechars = 0;
			} else {
				printf(" ");
			}
		}
		printf("\n");
		linechars = 0;
	}
}
