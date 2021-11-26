%{
#include "y.tab.h"
#include <string.h>
%}
fname [a-z0-9A-Z][a-zA-Z0-9_.]*
%%
[\t ] ;
{fname} { yylval.str = strdup(yytext); 
        return FNAME;}
\n return 0;
. return yytext[0];
%%
