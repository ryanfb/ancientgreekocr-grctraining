#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0 perseusdir

Outputs a list of all Greek words encountered in a Perseus corpus."

test $# -ne 1 && echo "$usage" && exit 1

find "$1" -type f -name '*-grc?.xml' | LC_ALL=C sort | while read i; do
	# - Strip XML
	# - Print one word per line
	# - Remove characters that shouldn't be present (lone diacritical characters)
	# - Remove final punctuation characters
	# - Ensure apostrophe characters are ancient greek
	cat "$i" \
	| sed '1,/<body>/ d; /<\/body>/,$ d' \
	| sed 's/<[^>]*>//g; s/\&[^;]*;//g' \
	| tr ' ' '\n' \
	| sed '/[᾽ι῀῁῝῞῟῭΅`´῾]/d' \
	| sed 's/ʼ/᾿/g' \
	| sed 's/[.,·;]$//g' \
	| sed '/^$/d'
done
