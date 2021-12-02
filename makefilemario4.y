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
static char *errno = "X"; // To check whether the error occured in the rules section
static int isitcommand = 0; // To check whether we are in the command line
void yyerror( const char *s);
%}
%union{
    char *str;
}
//%parse-param { char* line }
%token<str> FNAME REMARK EIGHTSPACE NOTARGETS
%type<str> statement /*targeterrors*/ commanderrors remarkline targetline files prerequisites remarks
%%

// Valid state handling
statement: targetline		// Go to the target line handling
	 | remarkline		// Go to the remark handling
//	 | targeterrors		// Go to the target error handling
	 | commanderrors	// Go to the command error handling
	 ;
         
	    /* Now for the error handling which is not ordinary parsing error*/
	    /* In here, it handles the error usually occurs in the target line */
	    /* This is commands commence before first target error */
//targeterrors: asdf {printf("commands commence before first target.\n"); errno="A"; yyerror(errno);}
	    /* Recursive variable 'xxx' references itself (eventually). */
	    /* Unterminated variable reference. */
	    /* insufficient arguments to function 'xxx'. */
	    ;

	     /* This is the error handling which usually occurs in the command line */
	     /* This is the error when using 8 spaces instead of tab */
commanderrors: EIGHTSPACE {printf("missing separator (did you mean TAB instead of 8 spaces?).\n"); errno="C"; yyerror(errno);}
	     /* When there is no rule to make the target */
	     | prerequisites {printf("No rule to make target\n"); errno="D"; yyerror(errno);}
	     ;

remarkline: remarks {printf("This line contains remarks.\n");}
	   | targetline remarks {printf("Target line contains remarks.\n");}
	   ;

targetline: files ':' prerequisites {printf("Target line exists with prerequisite(s).\n"); isitcommand=1;}
	  | files ':' {printf("Target line is valid.\n"); isitcommand=1;}
	  /* No targets error */
	  | ':' files {printf("No targets.\n"); errno="B"; yyerror(errno);}
	  | ':' {printf("No targets.\n"); errno= "B", yyerror(errno);}
	  ;

prerequisites: files '|' files
	     | files
	     ;

files: FNAME files {strcpy($$, strcat(strcat($1, " "), $2));}
     | FNAME 
     ;

remarks: REMARK remarks {strcpy($$, strcat($1, $2));}
       | REMARK
       ;
%%
int main(int argc, char **argv){
    char buffer[1024];
    char *line;

    /* In here, we check whether the correct value came in */
    if ( argc == 1 ){
    	fprintf(stderr, "Usage: ./main Makefile\n");
	exit(1);
    } else if ( strcmp(argv[1], "Makefile") ){
        fprintf(stderr, "Makefile '%s' was not found\n", argv[1]);
        exit(1);
    }

    /* Now it starts the parsing */
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

/* General Error Handling + Error correction */
void yyerror( const char *s){
    
    if(errno == "X"){
    /* This is the error part when the ordinary parsing fails*/
    printf("Missing separator.\n");
    }
    
    /* This is the part where error correction holds */
    if(errno == "A"){
	printf("Please check whether you correctly put your command line.\n");
    }

    if(errno == "B"){
        printf("Please put the target before \":\" line.\n");
    }

    if(errno == "C"){
    	printf("Please use TAB in the beginning of command line.\n");
    }
    
    if(errno == "D"){
	printf("Please put the recipie to make the target.\n");
    }
    errno = "X";
}

int yywrap(){return 1;}
