CORPUSURL = http://www.perseus.tufts.edu/hopper/opensource/downloads/texts/hopper-texts-GreekRoman.tar.gz
# CORPUSURL = http://ancientgreekocr.org/archived/hopper-texts-GreekRoman.tar.gz # backup copy
UTFSRC = tools/libutf/rune.c tools/libutf/utf.c

AMBIGS = \
	unicharambigs.accent \
	unicharambigs.anoteleiaaccent \
	unicharambigs.apostrophe \
	unicharambigs.breathing \
	unicharambigs.rho \
	unicharambigs.deltaomicron \
	unicharambigs.misc \
	unicharambigs.omicroniotaalpha \
	unicharambigs.omicronzero \
	unicharambigs.quoteaccent

all: langdata/grc.training_text langdata/grc.unicharambigs langdata/grc.wordlist

corpus:
	mkdir -p $@
	cd $@ ; wget -O - $(CORPUSURL) \
	| zcat | tar x

wordlist: tools/wordlistfromperseus.sh tools/betacode2utf8.sh corpus
	tools/wordlistfromperseus.sh corpus > wordlist-betacode
	tools/betacode2utf8.sh wordlist-betacode > $@
	rm wordlist-betacode

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=1536

unicharambigs.accent: tools/accentambigs
	tools/accentambigs > $@

unicharambigs.breathing: tools/breathingambigs charsforambigs.txt
	tools/breathingambigs charsforambigs.txt > $@

unicharambigs.rho: tools/rhoambigs charsforambigs.txt
	tools/rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: tools/omicronzeroambigs.sh charsforambigs.txt
	tools/omicronzeroambigs.sh charsforambigs.txt > $@

langdata/grc.training_text: tools/makegarbage.sh tools/isupper allchars.txt grc.word.txt seed
	mkdir -p langdata
	tools/makegarbage.sh allchars.txt grc.word.txt seed > $@

langdata/grc.unicharambigs: $(AMBIGS)
	mkdir -p langdata
	echo v1 > $@
	cat $(AMBIGS) >> $@

langdata/grc.wordlist: tools/sortwordlist.sh wordlist
	mkdir -p langdata
	tools/sortwordlist.sh < wordlist > $@

tools/accentambigs: tools/accentambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/breathingambigs: tools/breathingambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/rhoambigs: tools/rhoambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/isupper: tools/isupper.c
	$(CC) $(UTFSRC) tools/util/runetype.c $@.c -o $@

clean:
	rm -f tools/accentambigs tools/breathingambigs tools/rhoambigs tools/isupper
	rm -f unicharambigs.accent unicharambigs.breathing unicharambigs.rho unicharambigs.omicronzero
	rm -f langdata/grc.training_text langdata/grc.unicharambigs langdata/grc.wordlist
	rm -rf corpus wordlist wordlist-betacode
