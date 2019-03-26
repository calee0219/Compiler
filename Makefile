all: lex ycc
	./scanner ./test.c

lex: scanner.l
	lex ./scanner.l

ycc: lex.yy.c
	gcc ./lex.yy.c -ll -g -o scanner
