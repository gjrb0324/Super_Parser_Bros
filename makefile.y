%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

int yylex();
void yyerror(const char *s);
void read_line_fd(int fd);
%}
%union{
    char *str;
}
//%parse-param { FILE* fp }
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
    char buffer[1000];
    if ( strcmp(argc[1], "Makefile") ){
        fprintf(stderr, "Not Makefile!!");
        exit(1);
    }
    
    int fd = open(argc[1], O_RDWR);
    dup2(fd, 0);
    printf("yyparse begins\n");
    yyparse();
    printf("yyparse end\n");
    close(fd);
    return 0;
}
void yyerror( const char *s){
    printf("Error : %s\n", s);
    exit(1);
}

    

