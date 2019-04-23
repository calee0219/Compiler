#makefile for scanner
LEX			= lex
LEXFN		= lex.l
YACC		= bison
YACCFN      = yacc.y
CC			= gcc
CFLAGS		= -O2
LIBS		= -lfl
RM          = rm -f
SCANNERN    = scanner
SCANNERSN	= scanner.c
TESTFN      = whole.cm
PARSERRSN     = parser.h
PARSERN     = parser


all: scanner

scanner: lex yacc
	$(CC) -I. -o $(PARSERN) $(SCANNERSN) $(PARSERRSN) $(LIBS)
lex:
	$(LEX) -o $(SCANNERSN) $(LEXFN)
yacc: $(YACCFN)
	$(YACC) -d -o $(PARSERRSN) $(YACCFN)
test:
	./$(SCANNERN) $(TESTFN)
clean:
	$(RM) $(SCANNERN)
	$(RM) $(SCANNERSN)
	$(RM) $(PARSERN)
	$(RM) $(PARSERRSN)

check:
	./parser ./testdata/1
	#./parser ./testdata/2
	./parser ./testdata/3
	./parser ./testdata/4
	./parser ./testdata/5
	./parser ./testdata/7
	./parser ./testdata/8
	./parser ./testdata/9
	./parser ./testdata/10
	./parser ./testdata/arithmetic
	./parser ./testdata/boolean
	./parser ./testdata/complex
	./parser ./testdata/func
	./parser ./testdata/general
	./parser ./testdata/mix
	./parser ./testdata/parentheses
	./parser ./testdata/relation
	./parser ./testdata/total
	./parser ./testdata/variable-decl
	./parser ./testdata/whilefor
	./parser ./testdata/err/1
	./parser ./testdata/6
	./parser ./testdata/err/4
	./parser ./testdata/err/2
	./parser ./testdata/err/3
	./parser ./testdata/err/5
	./parser ./testdata/err/exprfunccall
	./parser ./testdata/err/noprogram
