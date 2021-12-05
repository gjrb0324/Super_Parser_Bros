%{
#include "y.tab.h"
#include <string.h>
%}
fname [a-z0-9A-Z][a-zA-Z0-9_.]+
anychar [a-z0-9A-Z]+
anyline [a-z0-9A-Z_.: -=]+
newline "\n"
eightspace ^"        "
space ^[ ]+
%%
[\t ] ;
{fname} 	{yylval.str = strdup(yytext); 
        	return FNAME;}
{newline}	return 0;
. 		return yytext[0];
[-]{anyline} 	{yylval.str = strdup(yytext);
                return FLAG;}
[#]{anyline}+		{return REMARK;}
[\t ][#]{anyline}+	{return REMARK;}
{eightspace}		{return EIGHTSPACE;}
^[:]{anychar}		{yylval.str = strdup(yytext);
			return NOTARGETS;}

{space}			{return SPACE;}
%%
