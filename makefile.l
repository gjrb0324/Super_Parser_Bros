%{
#include "y.tab.h"
#include <string.h>
%}
fname [a-z0-9A-Z]+

%%
[\t ]+ ;
{fname} { yylval.str = strdup(yytext); return FNAME;}

%%
