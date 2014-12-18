RIGAUDONURL = https://github.com/brobertson/rigaudon/raw/master/Dictionaries/greek_and_latin.txt
CORPUSURL = http://www.perseus.tufts.edu/hopper/opensource/downloads/texts/hopper-texts-GreekRoman.tar.gz
# CORPUSURL = http://ancientgreekocr.org/archived/hopper-texts-GreekRoman.tar.gz # backup copy
UTFSRC = tools/libutf/rune.c tools/libutf/utf.c
OPENGREEKANDLATIN_REPOS = \
	athenaeus-dev \
	church_fathers-dev \
	misc-dev \
	fragmentary-dev \
	dfhg-dev \
	libanius-dev \
	philo-dev \
	catenae-dev \
	cag-dev

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

all: training_text.txt grc.freq.txt grc.word.txt grc.unicharambigs

corpus:
	mkdir -p $@
	cd $@ ; wget -O - $(CORPUSURL) \
	| zcat | tar x

opengreekandlatin:
	mkdir -p $@
	cd $@; for i in $(OPENGREEKANDLATIN_REPOS); do \
		wget -O - https://github.com/OpenGreekAndLatin/$$i/tarball/master | zcat | tar x; \
	done

greek_and_latin.txt:
	wget $(RIGAUDONURL)

wordlist.perseus: tools/wordlistfromperseus.sh  tools/betacode2utf8.sh tools/striplineswithnonmatchingchars.sh corpus
	tools/wordlistfromperseus.sh corpus "*_gk.xml" > wordlist-betacode
	tools/betacode2utf8.sh wordlist-betacode | tools/striplineswithnonmatchingchars.sh allchars.txt > $@
	rm wordlist-betacode

wordlist.opengreekandlatin: tools/wordlistfromperseus.sh tools/striplineswithnonmatchingchars.sh opengreekandlatin
	tools/wordlistfromperseus.sh opengreekandlatin "*.xml" | tools/striplineswithnonmatchingchars.sh allchars.txt > $@

grc.opengreekandlatin.freq.txt: tools/wordlistparsefreq.sh wordlist.opengreekandlatin
	tools/wordlistparsefreq.sh < wordlist.opengreekandlatin > $@

wordlist.rigaudon: tools/wordlistfromrigaudon.sh greek_and_latin.txt
	tools/wordlistfromrigaudon.sh < greek_and_latin.txt > $@

grc.freq.txt: tools/wordlistparsefreq.sh wordlist.perseus
	tools/wordlistparsefreq.sh < wordlist.perseus > $@

grc.rigaudon.word.txt: tools/rigaudonparseword.sh wordlist.rigaudon
	tools/rigaudonparseword.sh < wordlist.rigaudon > $@

grc.perseus.word.txt: tools/wordlistparseword.sh wordlist.perseus
	tools/wordlistparseword.sh < wordlist.perseus > $@

grc.word.txt: grc.rigaudon.word.txt grc.perseus.word.txt
	cat $^ | LC_ALL="C" sort | LC_ALL="C" uniq > $@

grc.opengreekandlatin.word.txt: tools/wordlistparseword.sh wordlist.opengreekandlatin
	tools/wordlistparseword.sh < wordlist.opengreekandlatin > $@

grc.word.all.txt: grc.perseus.word.txt grc.rigaudon.word.txt grc.opengreekandlatin.word.txt
	cat $^ | LC_ALL='C' sort | LC_ALL='C' uniq > $@

seed:
	dd if=/dev/urandom of=$@ bs=1024 count=1536

training_text.txt: tools/makegarbage.sh tools/isupper allchars.txt grc.word.txt seed
	tools/makegarbage.sh allchars.txt grc.word.txt seed > $@

unicharambigs.accent: tools/accentambigs
	tools/accentambigs > $@

unicharambigs.breathing: tools/breathingambigs charsforambigs.txt
	tools/breathingambigs charsforambigs.txt > $@

unicharambigs.rho: tools/rhoambigs charsforambigs.txt
	tools/rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: tools/omicronzeroambigs.sh charsforambigs.txt
	tools/omicronzeroambigs.sh charsforambigs.txt > $@

grc.unicharambigs: $(AMBIGS)
	echo v1 > $@
	cat $(AMBIGS) >> $@

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
	rm -f training_text.txt grc.freq.txt grc.word.txt grc.unicharambigs
	rm -rf greek_and_latin.txt corpus wordlist.rigaudon wordlist.perseus wordlist-betacode
