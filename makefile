FONTSITE = http://greekfontsociety.gr
# FONTSITE = http://ancientgreekocr.org/archived # backup copies

FONT_LIST = \
             "GFS Artemisia \
             + GFS Artemisia Bold \
             + GFS Artemisia Bold Italic \
             + GFS Artemisia Italic \
             + GFS Bodoni \
             + GFS Bodoni Bold \
             + GFS Bodoni Bold Italic \
             + GFS Bodoni Italic \
             + GFS Didot \
             + GFS Didot Bold \
             + GFS Didot Bold Italic \
             + GFS Didot Italic \
             + GFS DidotClassic \
             + GFS Neohellenic \
             + GFS Neohellenic Bold \
             + GFS Neohellenic Bold Italic \
             + GFS Neohellenic Italic \
             + GFS Philostratos \
             + GFS Porson \
             + GFS Pyrsos \
             + GFS Solomos"

FONT_URLNAMES = \
                GFS_ARTEMISIA_OT \
                GFS_BODONI_OT \
                GFS_DIDOTCLASS_OT \
                GFS_DIDOT_OT \
                GFS_NEOHELLENIC_OT \
                GFS_PHILOSTRATOS \
                GFS_PORSON_OT \
                GFS_PYRSOS \
                GFS_SOLOMOS_OT

CORPUSCOMMIT = 5d069b29bd9dd40c8bb1dc1b9e2623236ebb22b9
RIGAUDONCOMMIT = 3f6292f656bd2920fc8980893ad57fa111153837

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

GENLANGDATA = \
	langdata/grc/grc.training_text \
	langdata/grc/grc.training_text.bigram_freqs \
	langdata/grc/grc.training_text.unigram_freqs \
	langdata/grc/grc.unicharambigs \
	langdata/grc/grc.word.bigrams \
	langdata/grc/grc.wordlist

all: grc.traineddata

langdata: $(GENLANGDATA)

corpus/.git/HEAD:
	rm -rf corpus
	git clone https://github.com/PerseusDL/canonical-greekLit corpus
	cd corpus && git checkout $(CORPUSCOMMIT)

rigaudon/.git/HEAD:
	rm -rf rigaudon
	git clone https://github.com/brobertson/rigaudon
	cd rigaudon && git checkout $(RIGAUDONCOMMIT)

wordlist.perseus: tools/utf8greekonly tools/wordlistfromperseus.sh corpus/.git/HEAD
	./tools/wordlistfromperseus.sh corpus/ | ./tools/utf8greekonly > $@

wordlist.rigaudon: tools/wordlistfromrigaudon.sh rigaudon/.git/HEAD
	./tools/wordlistfromrigaudon.sh < rigaudon/Dictionaries/greek_and_latin.txt | ./tools/utf8greekonly > $@

unicharambigs.accent: tools/accentambigs
	./tools/accentambigs > $@

unicharambigs.breathing: tools/breathingambigs charsforambigs.txt
	./tools/breathingambigs charsforambigs.txt > $@

unicharambigs.rho: tools/rhoambigs charsforambigs.txt
	./tools/rhoambigs charsforambigs.txt > $@

unicharambigs.omicronzero: tools/omicronzeroambigs.sh charsforambigs.txt
	./tools/omicronzeroambigs.sh charsforambigs.txt > $@

langdata/grc/grc.training_text: tools/makegarbage allchars.txt langdata/grc/grc.wordlist
	mkdir -p langdata/grc
	cat langdata/grc/grc.wordlist allchars.txt | ./tools/makegarbage > $@

langdata/grc/grc.unicharambigs: $(AMBIGS)
	mkdir -p langdata/grc
	echo v1 > $@
	cat $(AMBIGS) >> $@

langdata/grc/grc.wordlist: tools/sortwordlist.sh wordlist.perseus wordlist.rigaudon
	mkdir -p langdata/grc
	cat wordlist.perseus wordlist.rigaudon | ./tools/sortwordlist.sh > $@

langdata/grc/grc.training_text.bigram_freqs: tools/bigramfreqs.awk wordlist.perseus
	./tools/bigramfreqs.awk < wordlist.perseus | LC_ALL="C" sort -n -r | awk '{print $$2, $$1}' > $@

langdata/grc/grc.training_text.unigram_freqs: tools/unigramfreqs.awk wordlist.perseus
	./tools/unigramfreqs.awk < wordlist.perseus | LC_ALL="C" sort -n -r | awk '{print $$2, $$1}' > $@

langdata/grc/grc.word.bigrams: tools/bigramwords.awk wordlist.perseus
	./tools/bigramwords.awk < wordlist.perseus | LC_ALL="C" sort -n -r | awk '$$1 > 5 {print $$2, $$3}' > $@

tools/accentambigs: tools/accentambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/breathingambigs: tools/breathingambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/makegarbage: tools/makegarbage.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/rhoambigs: tools/rhoambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/utf8greekonly: tools/utf8greekonly.c
	$(CC) $(UTFSRC) $@.c -o $@

fonts/download:
	rm -rf fonts
	mkdir -p fonts
	cd fonts && for i in $(FONT_URLNAMES); do \
		wget -q -O $$i.zip $(FONTSITE)/$$i.zip ; \
		unzip -q -j $$i.zip ; \
		rm -f OFL-FAQ.txt OFL.txt *Specimen.pdf *Specimenn.pdf ; \
		rm -f readme.rtf .DS_Store ._* $$i.zip; \
	done
	chmod 644 fonts/*otf
	touch $@

grc.traineddata: $(GENLANGDATA) fonts/download
	tesstrain.sh --exposures -3 -2 -1 0 1 2 3 --fonts_dir fonts --fontlist $(FONT_LIST) --lang grc --langdata_dir langdata --overwrite --output_dir .

clean:
	rm -f tools/accentambigs tools/breathingambigs tools/makegarbage tools/rhoambigs tools/utf8greekonly
	rm -f unicharambigs.accent unicharambigs.breathing unicharambigs.rho unicharambigs.omicronzero
	rm -f wordlist.perseus wordlist.rigaudon
	rm -rf corpus fonts rigaudon
	rm -f $(GENLANGDATA)
	rm -f grc.traineddata
