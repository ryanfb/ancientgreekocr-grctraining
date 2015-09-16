#!/usr/bin/awk -f
#
# Prints random words from the wordlist, ensuring that each
# character is represented.
#
# Usage: makegarbage.awk < wordlist

BEGIN {
	repeats = 2;
	maxlinechars = 55;
	srand(1);
}

{
	# Store the word in arrays for each character it contains.
	for(i = 1; i <= length($1); i++) {
		c = substr($1, i, 1);

		# Increment the numwords count for character and
		# add the word to the words array for character.
		numwords[c]++;
		words[c][numwords[c]] = $1;

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
			c = chars[i]
			# Select a random word from the list of words
			# that contain the character.
			wordindex = int(1 + rand() * numwords[c]);
			printf("%s", words[c][wordindex]);

			linechars += length(words[c][wordindex]) + 1;
			if(linechars > maxlinechars) {
				printf("\n");
				linechars = 0;
			} else {
				printf(" ");
			}
		}
		printf("\n");
	}
}
