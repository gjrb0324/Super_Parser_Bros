%{
#include "y.tab.h"
#include <string.h>
%}
fname [a-z0-9A-Z][a-zA-Z0-9_.]+
commandline [a-z0-9A-Z_.-]+
anychar [a-z0-9A-Z ]+
eightspace ^"        "
newline "\n"
%%
[\t ] ;
{fname} { yylval.str = strdup(yytext); 
        return FNAME;}
{newline}	return 0;
. return yytext[0];
{commandline}	{yylval.str = strdup(yytext);
		return COMMANDLINE;}
[#]{anychar}		{return REMARK;}


{eightspace} 				{ yylval.str = strdup(yytext);
					return EIGHTSPACE;}
^[:]{anychar}				{yylval.str = strdup(yytext);
					return NOTARGETS;}
^[\t][\t ]+				{return NORULES;}
%%
