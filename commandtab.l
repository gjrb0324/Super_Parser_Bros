%{
#include "y.tab.h"
extern int yylval;
%}

%%
[\t]+	return G;
%%

void main(){
	yylex();
}
