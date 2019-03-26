all: lex ycc

lex: scanner.l
	lex ./scanner.l

ycc: lex.yy.c
	gcc ./lex.yy.c -ll -g -o scanner

start:
	./scanner ./test.c

clean:
	rm -rf ./lex.yy.c ./scanner
