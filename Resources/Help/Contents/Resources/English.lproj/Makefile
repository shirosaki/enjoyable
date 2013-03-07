#!/usr/bin/make -f

HTML := *.html pgs/*.html

all: Enjoyable.helpindex

Enjoyable.helpindex: $(HTML)
	hiutil -C -f $@ -g -a -s en .
