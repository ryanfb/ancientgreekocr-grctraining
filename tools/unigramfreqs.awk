#!/usr/bin/awk -f
#
# Outputs the frequencies of all unigrams (characters).

NF == 1 {
	for(i = 1; i <= length($1); i++) {
		u = substr($1, i, 1);
		unigrams[u]++;
	}
}

END {
	for (i in unigrams) {
		print unigrams[i], i;
	}
}
