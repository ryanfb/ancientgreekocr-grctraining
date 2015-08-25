CORPUSCOMMIT = 5d069b29bd9dd40c8bb1dc1b9e2623236ebb22b9

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

all: langdata/grc/grc.training_text langdata/grc/grc.unicharambigs langdata/grc/grc.wordlist

corpus/.git/HEAD:
	rm -rf corpus
	git clone https://github.com/PerseusDL/canonical-greekLit corpus
	cd corpus && git checkout $(CORPUS)

wordlist: tools/wordlistfromperseus.sh tools/betacode2utf8.sh corpus/.git/HEAD
	./tools/wordlistfromperseus.sh corpus/ > wordlist-betacode
	./tools/betacode2utf8.sh wordlist-betacode > $@
	rm wordlist-betacode

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=1536

unicharambigs.accent: tools/accentambigs
	./tools/accentambigs > $@

unicharambigs.breathing: tools/breathingambigs charsforambigs.txt
	./tools/breathingambigs charsforambigs.txt > $@

unicharambigs.rho: tools/rhoambigs charsforambigs.txt
	./tools/rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: tools/omicronzeroambigs.sh charsforambigs.txt
	./tools/omicronzeroambigs.sh charsforambigs.txt > $@

langdata/grc/grc.training_text: tools/makegarbage.sh tools/isupper allchars.txt langdata/grc/grc.wordlist seed
	mkdir -p langdata/grc
	./tools/makegarbage.sh allchars.txt langdata/grc/grc.wordlist seed > $@

langdata/grc/grc.unicharambigs: $(AMBIGS)
	mkdir -p langdata/grc
	echo v1 > $@
	cat $(AMBIGS) >> $@

langdata/grc/grc.wordlist: tools/sortwordlist.sh wordlist
	mkdir -p langdata/grc
	./tools/sortwordlist.sh < wordlist > $@

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
	rm -f langdata/grc/grc.training_text langdata/grc/grc.unicharambigs langdata/grc/grc.wordlist
	rm -rf corpus wordlist wordlist-betacode
