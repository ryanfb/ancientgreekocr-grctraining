#!/usr/bin/awk -f
#
# Outputs the frequencies of all bigrams (occurances of two
# characters adjacent to each other). These are used to calculate
# most common spacing patterns for the characters.

NF == 1 {
	for(i = 1; i < length($1); i++) {
		b = substr($1, i, 2);
		bigrams[b]++;
	}
}

END {
	for (i in bigrams) {
		print bigrams[i], i;
	}
}
