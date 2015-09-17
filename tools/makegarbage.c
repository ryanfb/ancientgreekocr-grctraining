/* See LICENSE file for copyright and license details. */

#define usage "makegarbage\n\n" \
              "Prints random words from the wordlist given on stdin,\n" \
              "ensuring that each character is represented.\n"

#define REPEATS 2
#define MAXLINECHARS 55
#define MAXWORDSPERCHAR 500 * REPEATS

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libutf/utf.h"

typedef struct {
	Rune c;
	char words[MAXWORDSPERCHAR][BUFSIZ];
	unsigned int numwords;
} CharWords;

int main(int argc, char *argv[]) {
	CharWords *charwords = NULL;
	unsigned int numcharwords = 0;
	CharWords *cur;
	Rune c;
	char buf[BUFSIZ];
	unsigned int b, i, n;
	int charexists;
	int linechars;

	if(argc != 1) {
		fputs("usage: " usage, stdout);
		return 1;
	}

	while(fgets(buf, BUFSIZ, stdin)) {
		if(buf[strlen(buf) - 1] == '\n') {
			buf[strlen(buf) - 1] = '\0';
		}
		/* Store the word in an array for each character it contains */
		for(i = 0, b = 0; i < utflen(buf); i++) {
			b += chartorune(&c, buf + b);
			if(c == '\n' || c == ' ') {
				break;
			}

			/* Create new charwords entry if ithasn't been seen before */
			charexists = 0;
			for(n = 0; n < numcharwords; n++) {
				if(charwords[n].c == c) {
					charexists = 1;
					cur = &(charwords[n]);
					break;
				}
			}
			if(!charexists) {
				charwords = realloc(charwords, sizeof(*charwords) * ++numcharwords);
				cur = &(charwords[numcharwords - 1]);
				cur->c = c;
				cur->numwords = 0;
			}

			/* Store the new word if we don't have enough yet */
			if(cur->numwords < MAXWORDSPERCHAR) {
				strncpy(cur->words[cur->numwords++], buf, BUFSIZ);
			}
		}
	}

	linechars = 0;
	for(i = 0; i < REPEATS; i++) {
		for(n = 0, cur = charwords; n < numcharwords; n++, cur++) {
			/* Select a random word from the list of words that
			 * contain the character */
			b = random() % cur->numwords;
			fputs(cur->words[b], stdout);

			linechars += utflen(cur->words[b]) + 1;
			if(linechars > MAXLINECHARS) {
				linechars = 0;
				fputc('\n', stdout);
			} else {
				fputc(' ', stdout);
			}
		}
	}
	fputc('\n', stdout);

	return 0;
}
