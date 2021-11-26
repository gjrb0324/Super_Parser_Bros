%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern YY_BUFFER_STATE yy_scan_string(const char* str);
extern YY_BUFFER_STATE yy_scan_buffer(char *, size_t);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
extern void yy_switch_to_buffer(YY_BUFFER_STATE buffer);
int yylex();
void yyerror( const char *s);
%}
%union{
    char *str;
}
//%parse-param { char* line }
%token<str> FNAME
%token<str> EIGHTSPACE
%token<str> NONTAB
%token<str> NOCOLON
%token<str> SPACE
%type<str>files
%%

statement: files ':' files {printf("Sentence is valid.\n");}
	 | files ':' {printf("Sentence is valid.\n");}
	 ;
         /* Now for the error handling which is not ordinary parsing error*/
	 /* This is a error when using 8 spaces instead of tab */
errors: NONTAB EIGHTSPACE {printf("missing separator (did you mean TAB instead of 8 spaces?). Stop\n"); exit(1);}
	/* This is commands commence before first target error */
	| '\n' SPACE {printf("commands commence before first target. Stop\n"); exit(1);}
	| '\n' NOCOLON {printf("commands commence before first target. Stop\n"); exit(1);}
	/* This is no targets error */
	| ':' {printf("No targets. Stop\n"), exit(1);}
	;

files: FNAME files {strcpy($$, strcat(strcat($1, " "), $2 )); 
                        }
     |  FNAME 
    ;

%%
int main(int argc, char **argv){
    char buffer[1024];
    char *line;
    if ( strcmp(argv[1], "Makefile") ){
        fprintf(stderr, "Not Makefile!!");
        exit(1);
    }
    unsigned int n = 1; 
    FILE *fp = fopen(argv[1], "r");
    while ( (line = fgets(buffer,1024, fp)) != NULL) {
        printf("line %u : %s",n,line);
	if(line[0] == '\n'){
		n++;
		continue;
	}
	if(line[0] == '\t'){
		int ret = system(line);
		if(WEXITSTATUS(ret) == 0)
			printf("Executable Command\n");
		else if(WIFSIGNALED(ret))
			printf("Abnormally Terminated : %d\n", WTERMSIG(ret));
		n++;
		continue;
	}
        YY_BUFFER_STATE buffer = yy_scan_string(line);
        yy_switch_to_buffer(buffer);
        yyparse();
        yy_delete_buffer(buffer);
        printf("\n");
        n++;
    }
    fclose(fp);
    return 0;
}

void yyerror( const char *s){
    /* This is the error part when the ordinary parsing fails*/
    printf("Missing separator. Stop\n");
    exit(1);
}

int yywrap(){return 1;}
