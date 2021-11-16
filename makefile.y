%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char str[1000];
%}
%token FNAME

%%

statement: FNAME  ':' prerequisites {printf("%s : %s", $1, str);}
        ;

prerequisites:  FNAME ' ' prerequisites { strcat(str, " "); }
             |  FNAME { strcat(str, $1); }
             ;

%%
