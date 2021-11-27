main: lex yacc
	rm -f main
	cc lex.yy.c y.tab.c -o main -ll -lfl -g

lex:
	lex makefile.l

yacc:
	yacc makefilemario.y -d
	
clear:
	rm y.tab.c lex.yy.c y.tab.h -f
	rm -f main
