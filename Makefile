main : lex yacc 
	rm -f main	# Yahoo YAHOO
	cc lex.yy.c y.tab.c -o main -ll -lfl -g
	
lex :
	lex makefilemario.l 

yacc: 
	yacc makefilemario4.y -d

#clear:
	#rm y.tab.c lex.yy.c y.tab.h -f
	#rm -f main
asdf: #what
#command c o m m e n cebeforefirsttarget-  asdf      
#rm good -adsdf
asdf:
asdfasdf
: sdfgsdafg
#asdfasdf
         
