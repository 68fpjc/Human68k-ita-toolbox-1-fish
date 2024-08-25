#  Makefile for Human68k ITA TOOLBOX #1 - FISH

MAKE = make

RELEASE_ARCHIVE  = FISH081

RELEASE_FILES = \
	doc/MANIFEST \
	doc/README \
	../NOTICE \
	../DIRECTORY \
	doc/CHANGES \
	doc/FAQ \
	doc/FISH.DOC \
	prg/fish.x \
	doc/Pfishrc \
	doc/Plogin \
	doc/Plogout \
	doc/Passwd

CONTRIB_FILES = \
	contrib\manscrpt.Lzh

###

.PHONY: all install clean clobber release backup

###

all::
	cd prg; $(MAKE) all

install::
	cd prg; $(MAKE) install

clean::
	cd extlib; $(MAKE) clean
	cd lib; $(MAKE) clean
	cd prg; $(MAKE) clean

clobber::
#	cd extlib; $(MAKE) clobber
	cd lib; $(MAKE) clobber
	cd prg; $(MAKE) clobber

$(RELEASE_ARCHIVE).LZH:: $(CONTRIB_FILES)
	LHA u -x $(RELEASE_ARCHIVE).LZH $?

###

include ../Makefile.sub

###
