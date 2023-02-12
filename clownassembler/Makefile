LEX = flex
YACC = bison

ifneq ($(RELEASE),)
 CFLAGS = -ansi -Wno-long-long -Wall -Wextra -pedantic -Wc++-compat -O2 -DNDEBUG
else
 CFLAGS = -ansi -Wno-long-long -Wall -Wextra -pedantic -Wc++-compat -ggdb3 -Og -fwrapv -Wshift-overflow=2
 YFLAGS = --debug
endif

all: generators

generators: lexical.c lexical.h syntactic.c syntactic.h

lexical.c lexical.h: lexical.l syntactic.h
	$(LEX) --outfile=lexical.c --header-file=lexical.h $<

syntactic.c syntactic.h: syntactic.y
	$(YACC) -d syntactic.y
	mv syntactic.tab.h syntactic.h
	mv syntactic.tab.c syntactic.c
	$(YACC) --output=syntactic.c $(YFLAGS) $<

assemblers: clownassembler clownassembler_asm68k

clownassembler_asm68k: frontend_asm68k.c dictionary.c lexical.c semantic.c strcmpci.c syntactic.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $@ $(LIBS)

clownassembler: frontend_custom.c dictionary.c lexical.c semantic.c strcmpci.c syntactic.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $@ $(LIBS)
