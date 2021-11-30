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
int targetvalue = 0; // To check whether the target existed before command section
int errno = 0; // To check whether the error occured in the rules section
void yyerror( const char *s);
%}
%union{
    char *str;
}
//%parse-param { char* line }
%token<str> FNAME COMMANDLINE EIGHTSPACE COMMANDSBEFORE NOTARGETS NORULES
%type<str>files
%type<str>commands
%type<str>targeterrors
%%

statement:
	 | files ':' files {printf("Target line is valid.\n");}
	 | files ':' {printf("Target line is valid.\n");}
	 | commands {printf("Command line is valid.\n");}
	 | targeterrors
	 | commanderrors
	 ;
         
	 /* Now for the error handling which is not ordinary parsing error*/
	 /* This is a error when using 8 spaces instead of tab */
targeterrors: EIGHTSPACE {printf("missing separator (did you mean TAB instead of 8 spaces?).\n"); errno++;}
	 /* This is commands commence before first target error */
	 | COMMANDSBEFORE {printf("commands commence before first target.\n"); errno++;}
	 /* This is no targets error */
	 | NOTARGETS {printf("No targets.\n"); errno++;}
	 /* No rule to make target 'xxx'*/
	 | files ':' NORULES {printf("No rule to make target %s\n", $$); errno++;}
	 /* Warning: overriding recipie for target 'xxx' */
	 /* Circular xxx <- yyy dependency dropped */
	 /* Recursive variable 'xxx' references itself (eventually). */
	 /* This can be do in here */
	 /* Unterminated variable reference. */
	 /* insufficient arguments to function 'xxx'. */
	 ;

commanderrors: EIGHTSPACE {printf("missing separator (did you mean TAB instead of 8 spaces?).\n"); errno++;}

files: FNAME files {strcpy($$, strcat(strcat($1, " "), $2 )); 
                        }
     |  FNAME 
    ;

commands: COMMANDLINE commands {strcpy($$, strcat(strcat($1, " "), $2 ));}
	| COMMANDLINE
	;

%%
int main(int argc, char **argv){
    char buffer[1024];
    char *line;
//    if ( argc == 0 ){
//    	fprintf(stderr, "Usage: ./main Makefile\n");
//	exit(1);
//    }
    if ( strcmp(argv[1], "Makefile") ){
        fprintf(stderr, "Makefile '%s' was not found\n", argv[1]);
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
    
    if(errno == 0){
    /* This is the error part when the ordinary parsing fails*/
    printf("Missing separator.\n");
    }
    errno = 0;
}

int yywrap(){return 1;}
