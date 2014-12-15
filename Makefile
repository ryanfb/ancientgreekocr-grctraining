CORPUSURL = https://github.com/brobertson/rigaudon/raw/master/Dictionaries/greek_and_latin.txt
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

all: training_text.txt grc.freq.txt grc.word.txt grc.unicharambigs

greek_and_latin.txt:
	wget $(CORPUSURL)

wordlist: tools/wordlistfromrigaudon.sh greek_and_latin.txt
	tools/wordlistfromrigaudon.sh < greek_and_latin.txt > $@

grc.freq.txt: tools/rigaudonparsefreq.sh wordlist
	tools/rigaudonparsefreq.sh < wordlist > $@

grc.word.txt: tools/rigaudonparseword.sh wordlist
	tools/rigaudonparseword.sh < wordlist > $@

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
	rm -rf greek_and_latin.txt corpus wordlist wordlist-betacode
