%{
#include "y.tab.h"
#include <string.h>
%}
fname [a-z0-9A-Z][a-zA-Z0-9_.]+
anychar [a-z0-9A-Z*&#]+
eightspace "        "
newline "\n"
nontab	[^\n]
nocolon [^:]
%%
[\t ] ;
{fname} { yylval.str = strdup(yytext); 
        return FNAME;}
{newline}	return 0;
. return yytext[0];

{anychar}	{ yylval.str = strdup(yytext);
		return ANYCHAR;}
{eightspace}	{ yylval.str = strdup(yytext);
		return EIGHTSPACE;}
[^\n]		{ yylval.str = strdup(yytext);
		return NONTAB;}
{nocolon}	{ yylval.str = strdup(yytext);
		return NOCOLON;}
%%
