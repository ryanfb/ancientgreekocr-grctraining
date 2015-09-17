/* See LICENSE file for copyright and license details. */

#define usage "utf8only\n\n" \
              "Outputs only the lines from stdin which contain exclusively\n" \
              "UTF-8 encoded Ancient Greek characters (see the ranges[] array\n" \
              "for the characters this refers to).\n"

#include <stdio.h>
#include "libutf/utf.h"

#define LENGTH(X) (sizeof X / sizeof X[0])

typedef struct {
	unsigned int start;
	unsigned int end;
} Range;

static const Range ranges[] = {
	{ 0x0370, 0x03FF }, /* Greek and Coptic */
	{ 0x1F00, 0x1FFE }, /* Greek extended */
	{ 0x0300, 0x036F }, /* Combining diacritical marks */
};

int main(int argc, char *argv[]) {
	unsigned int b, i, n;
	unsigned int inrange, print, runenum;
	char buf[BUFSIZ];
	Rune rune;

	if(argc != 1) {
		fputs("usage: " usage, stdout);
		return 1;
	}

	while(fgets(buf, BUFSIZ, stdin)) {
		runenum = utflen(buf);
		print = 1;
		for(i = 0, b = 0; i < runenum; i++) {
			b += chartorune(&rune, buf + b);
			if(rune == '\n' || rune == ' ') {
				break;
			}
			inrange = 0;
			for(n = 0; n < LENGTH(ranges); n++) {
				if(rune >= ranges[n].start && rune <= ranges[n].end) {
					inrange = 1;
				}
			}
			if(!inrange) {
				print = 0;
			}
		}
		if(print) {
			fputs(buf, stdout);
		}
	}

	return 0;
}
