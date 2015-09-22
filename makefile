# Note: remote files are archived at http://ancientgreekocr.org/grctraining.deps.tar.xz
FONTSITE = http://greekfontsociety.gr

FONT_LIST = \
	'GFS Artemisia' \
	'GFS Artemisia Bold' \
	'GFS Artemisia Bold Italic' \
	'GFS Artemisia Italic' \
	'GFS Bodoni' \
	'GFS Bodoni Bold' \
	'GFS Bodoni Bold Italic' \
	'GFS Bodoni Italic' \
	'GFS Didot' \
	'GFS Didot Bold' \
	'GFS Didot Bold Italic' \
	'GFS Didot Italic' \
	'GFS DidotClassic' \
	'GFS Neohellenic' \
	'GFS Neohellenic Bold' \
	'GFS Neohellenic Bold Italic' \
	'GFS Neohellenic Italic' \
	'GFS Philostratos' \
	'GFS Porson' \
	'GFS Pyrsos' \
	'GFS Solomos'

# TODO: Patch tesseract's tess_train.sh to process font list arguments sanely
FONT_LIST_TESS = \
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

PKG_CONFIG = pkg-config
CAIROCFLAGS = `$(PKG_CONFIG) --cflags pangocairo`
CAIROLDFLAGS = `$(PKG_CONFIG) --libs pangocairo`

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
	langdata/Greek.unicharset \
	langdata/Greek.xheights \
	langdata/grc/grc.config \
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

langdata/Greek.unicharset: tools/addmetrics allchars.txt
	sed 's/$$/ 0 0 0 0 0/g' < allchars.txt > allchars.box
	unicharset_extractor allchars.box
	set_unicharset_properties -U unicharset -O unicharset --script_dir .
	./tools/addmetrics $(FONT_LIST) < unicharset > $@
	rm -f allchars.box unicharset

langdata/Greek.xheights: tools/xheight
	rm -f langdata/Greek.xheights
	for i in $(FONT_LIST); do \
		./tools/xheight "$$i" \
		| awk '{for(i=1;i<NF-1;i++) {printf("%s_",$$i)} printf("%s %d\n", $$(NF-1), $$NF)}' \
		>>$@ ; \
	done

langdata/grc/grc.config: grc.config
	mkdir -p langdata/grc
	sed '2i # commit: '`git rev-list -n 1 HEAD` < $< > $@

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

langdata/grc/grc.training_text.bigram_freqs: tools/bigramfreqs wordlist.perseus
	./tools/bigramfreqs < wordlist.perseus | LC_ALL="C" sort -n -r | awk '{print $$2, $$1}' > $@

langdata/grc/grc.training_text.unigram_freqs: tools/unigramfreqs wordlist.perseus
	./tools/unigramfreqs < wordlist.perseus | LC_ALL="C" sort -n -r | awk '{print $$2, $$1}' > $@

langdata/grc/grc.word.bigrams: tools/bigramwords.awk wordlist.perseus
	./tools/bigramwords.awk < wordlist.perseus | LC_ALL="C" sort -n -r | awk '$$1 > 5 {print $$2, $$3}' > $@

tools/accentambigs: tools/accentambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/addmetrics: tools/addmetrics.c
	$(CC) $(CAIROCFLAGS) $(UTFSRC) $@.c -o $@ $(CAIROLDFLAGS)

tools/bigramfreqs: tools/bigramfreqs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/breathingambigs: tools/breathingambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/makegarbage: tools/makegarbage.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/rhoambigs: tools/rhoambigs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/unigramfreqs: tools/unigramfreqs.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/utf8greekonly: tools/utf8greekonly.c
	$(CC) $(UTFSRC) $@.c -o $@

tools/xheight: tools/xheight.c
	$(CC) $(CAIROCFLAGS) $(UTFSRC) $@.c -o $@ $(CAIROLDFLAGS)

fonts/download: fontsums
	rm -rf fonts
	mkdir -p fonts
	cd fonts && for i in $(FONT_URLNAMES); do \
		wget -q -O $$i.zip $(FONTSITE)/$$i.zip ; \
		unzip -q -j $$i.zip ; \
		rm -f OFL-FAQ.txt OFL.txt *Specimen.pdf *Specimenn.pdf ; \
		rm -f readme.rtf .DS_Store ._* $$i.zip ; \
	done
	chmod 644 fonts/*otf
	while read i; do \
		f=`echo $$i | awk '{print $$1}'` ; \
		origsum=`echo $$i | awk '{print $$2}'` ; \
		sum=`cksum $$f | awk '{print $$1}'` ; \
		test $$origsum = $$sum || exit 1 ; \
	done < fontsums
	touch $@

grc.traineddata: $(GENLANGDATA) fonts/download
	tesstrain.sh --exposures -3 -2 -1 0 1 2 3 --fonts_dir fonts --fontlist $(FONT_LIST_TESS) --lang grc --langdata_dir langdata --overwrite --output_dir .

clean:
	rm -f tools/accentambigs tools/addmetrics tools/bigramfreqs tools/breathingambigs
	rm -f tools/makegarbage tools/rhoambigs tools/unigramfreqs tools/utf8greekonly tools/xheight
	rm -f allchars.box unicharset
	rm -f unicharambigs.accent unicharambigs.breathing unicharambigs.rho unicharambigs.omicronzero
	rm -f wordlist.perseus wordlist.rigaudon
	rm -rf corpus fonts rigaudon
	rm -f $(GENLANGDATA)
	rm -f grc.traineddata
