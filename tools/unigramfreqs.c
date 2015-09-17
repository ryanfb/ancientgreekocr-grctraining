/* See LICENSE file for copyright and license details. */

#define usage "unigramfreqs\n\n" \
              "Outputs the frequencies of all unigrams (characters).\n"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libutf/utf.h"

typedef struct {
	Rune unigram;
	unsigned int freq;
} Unigrams;

int main(int argc, char *argv[]) {
	Unigrams *unigrams = NULL;
	unsigned int numunigrams = 0;
	Unigrams *cur;
	char c[UTFmax];
	char buf[BUFSIZ];
	Rune rune;
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

		for(i = 0, b = 0; i < utflen(buf); i++) {
			b += chartorune(&rune, buf + b);

			if(rune == '\n' || rune == ' ' || !rune) {
				break;
			}

			exists = 0;
			for(n = 0, cur = unigrams; n < numunigrams; n++, cur++) {
				if(cur->unigram == rune) {
					exists = 1;
					break;
				}
			}
			if(!exists) {
				unigrams = realloc(unigrams, sizeof(*unigrams) * ++numunigrams);
				cur = &(unigrams[numunigrams - 1]);
				cur->unigram = rune;
				cur->freq = 0;
			}

			cur->freq++;
		}
	}

	for(i = 0, cur = unigrams; i < numunigrams; i++, cur++) {
		fprintf(stdout, "%d ", cur->freq);
		b = runetochar(c, &(cur->unigram));
		c[b] = '\0';
		fputs(c, stdout);
		fputc('\n', stdout);
	}

	return 0;
}
