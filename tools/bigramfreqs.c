/* See LICENSE file for copyright and license details. */

#define usage "bigramfreqs\n\n" \
              "Outputs the frequencies of all bigrams (occurances of two\n" \
              "characters adjacent to each other). These are used to calculate\n" \
              "most common spacing patterns for the characters.\n"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libutf/utf.h"

typedef struct {
	Rune bigram[2];
	unsigned int freq;
} Bigrams;

int main(int argc, char *argv[]) {
	Bigrams *bigrams = NULL;
	unsigned int numbigrams = 0;
	Bigrams *cur;
	char c[UTFmax];
	char buf[BUFSIZ];
	Rune c1, c2;
	unsigned int b, i, n;
	int exists;

	if(argc != 1) {
		fputs("usage: " usage, stdout);
		return 1;
	}

	while(fgets(buf, BUFSIZ, stdin)) {
		if(buf[strlen(buf) - 1] == '\n') {
			buf[strlen(buf) - 1] = '\0';
		}

		for(i = 0, b = 0; i < utflen(buf) - 1; i++) {
			b += chartorune(&c1, buf + b);
			chartorune(&c2, buf + b);

			if(c1 == '\n' || c1 == ' ' || !c1 ||
			   c2 == '\n' || c2 == ' ' || !c2) {
				break;
			}

			exists = 0;
			for(n = 0, cur = bigrams; n < numbigrams; n++, cur++) {
				if(cur->bigram[0] == c1 && cur->bigram[1] == c2) {
					exists = 1;
					break;
				}
			}
			if(!exists) {
				bigrams = realloc(bigrams, sizeof(*bigrams) * ++numbigrams);
				cur = &(bigrams[numbigrams - 1]);
				cur->bigram[0] = c1;
				cur->bigram[1] = c2;
				cur->freq = 0;
			}

			cur->freq++;
		}
	}

	for(i = 0, cur = bigrams; i < numbigrams; i++, cur++) {
		fprintf(stdout, "%d ", cur->freq);
		for(n = 0; n < 2; n++) {
			b = runetochar(c, &(cur->bigram[n]));
			c[b] = '\0';
			fputs(c, stdout);
		}
		fputc('\n', stdout);
	}

	free(bigrams);

	return 0;
}
