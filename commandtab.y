%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}

%token STRING

%%
[\t]	;
.	printf("Syntax Error!\n");	
%%

int main(){
	yyparse();
	return 0;
}

int yyerror(char* errline){
	printf("Syntax error on the command line!\n To be specific: %s\n", errline);
	return 0;
}

int yywrap(void){
	return 1;
}
