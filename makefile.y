%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);
char string[1000];
%}
%union{
    char *str;
}
%parse-param { FILE* fp }
%token<str> FNAME
%type<str>files
%%

statement: files ':' files {printf("Sentence is valid.\n");}
         ;

files: FNAME files {strcpy($$, strcat(strcat($1, " "), $2 )); 
                        }
     |  FNAME 
    ;

%%
int main(int argv, char **argc){
    FILE *fp;
    char buffer[100];
    if ( strcmp(argc[1], "Makefile") ){
        fprintf(stderr, "Not Makefile!!");
        exit(1);
    }
    fp = fopen(argc[1], "rwx");
    fread(buffer, sizeof(buffer), 100, fp);
    printf(" buffer = %s\n", buffer);
    yyparse(fp);
    return 0;
}
void yyerror(const char *s){
    printf("Error : %s\n", s);
    exit(1);
}

