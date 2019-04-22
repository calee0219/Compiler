#makefile for scanner
LEX			= lex
LEXFN		= lex.l
CC			= gcc
CFLAGS		= -O2
LIBS		= -lfl
RM          = rm -f
SCANNERN    = scanner
SCANNERSN	= scanner.c
TESTFN      = whole.cm
YACC		= bison
YACCRSN     = y.tab.c
YACCFN      = yacc.y


all: scanner

scanner: lex yacc
	$(CC) -o $(SCANNERN) $(SCANNERSN) $(YACCRSN) $(LIBS)
lex:
	$(LEX) -o $(SCANNERSN) $(LEXFN)
yacc:
	$(YACC) -o $(YACCRSN) $(YACCFN)
test:
	./$(SCANNERN) $(TESTFN)
clean:
	$(RM) $(SCANNERN)
	$(RM) $(SCANNERSN)
