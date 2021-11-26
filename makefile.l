%{
#include "y.tab.h"
#include <string.h>
%}
fname [a-z0-9A-Z][a-zA-Z0-9_.]+
eightspace "        "
nontab "^\t"
newline "\n"
nocolon "^:"
space [ \t\n]+
%%
[\t ] ;
{fname} { yylval.str = strdup(yytext); 
        return FNAME;}
{newline}	return 0;
. return yytext[0];

{eightspace}	{return EIGHTSPACE;}
{nontab}	{return NONTAB;}
{nocolon}	{return NOCOLON;}
{space} 	{return SPACE;}
%%
