#!/usr/bin/awk -f
# taken from http://www.cis.uni-muenchen.de/kurse/pmaier/Korpus/DataIntensiveLinguistics/node41.html

BEGIN {
	prev = "";
}

{
	for(i= 1; i <= NF; i++){
		if(prev != "") {
			bigram = prev " " $i; # build the bigram
			count[bigram]++; # count the bigram
		}
		prev = $i; # keep track of the previous word
	}
}

END {
	for (w in count) {
		print count[w], w;
	}
}
