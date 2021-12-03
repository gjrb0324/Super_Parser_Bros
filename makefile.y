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
%token<str> FNAME REMARK EIGHTSPACE NOTARGETS ANYLINE FLAG
%type<str> statement macroline /*targeterrors*/ commanderrors remarkline targetline files prerequisites remarks
%%

// Valid state handling
statement: targetline		// Go to the target line handling
     | macroline
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

macroline: FNAME '=' FLAG {
                            setenv($1,$3,1);
                            printf("%s\n",getenv($1));
                            }
        | FNAME '=' files {
                            setenv($1,$3,1);
                            printf("%s\n", getenv($1));
                            }

        ;


	     /* This is the error handling which usually occurs in the command line */
	     /* This is the error when using 8 spaces instead of tab */
commanderrors: EIGHTSPACE {printf("Are you trying to trick me just using eight spaces?\n");}
	     | EIGHTSPACE prerequisites {printf("missing separator (did you mean TAB instead of 8 spaces?).\n"); errno="C"; yyerror(errno);}
	     /* When there is no rule to make the target */
	     | prerequisites {printf("No rule to make target\n"); errno="D"; yyerror(errno);}
	     | prerequisites '-' prerequisites {printf("No rule to make target\n"); errno="D"; yyerror(errno);}
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

files: FNAME files {strcpy($$, strcat(strcat($1, " "), $2));
                    printf("%s\n",$$);}
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
    	fprintf(stderr, "Usage: %s Makefile\n",argv[0]);
	exit(1);
    } else if ( (strcmp(argv[1], "Makefile") != 0) && (strcmp(argv[1], "makefile") != 0) ){
        fprintf(stderr, "Makefile '%s' was not found\n", argv[1]);
        exit(1);
    }

    /* Now it starts the parsing */
    unsigned int n = 1; 
    FILE *fp = fopen(argv[1], "r");
    char target[BUFSIZ]="\0";
    int size; //target's array size
    char **pre = (char **)malloc(sizeof(char *)*100);
    for (int i = 0 ; i <100 ; i++)
        pre[i] = "init";
    if(pre == NULL)
        exit(1);
    while ( (line = fgets(buffer,1024, fp)) != NULL) {
        printf("line %u : %s",n,line);
	if(line[0] == '\n'){
		n++;
		continue;
	}
	if(line[0] == '\t'){
        char n_line[BUFSIZ]="\0";
        line = strtok(line, "\t");
        char *tok = strtok(line, " ");
        while(tok != NULL )
        {
            if(tok[0] == '$'){
                char newtok[strlen(tok)];
                strcpy(newtok,"\0");
                int n=0;
                if(tok[1] == '('){
                    for(int i =1;  i<strlen(tok);i++){
                        if(tok[i] == '(')
                            continue;
                        else if(tok[i] == ')')
                            break;
                        newtok[n] = tok[i];
                        n++;
                    }
                    
                    newtok[n] = '\0';
                    printf("%s\n",getenv(newtok));
                    strcat(n_line, getenv(newtok));
                }
                //Current target
                else if(tok[1] == '*'){
                    char *basename = strtok(target, ".");
                    strcat(n_line, basename);
                }
                //First current ddependency(prerequisite) file
                else if(tok[1] == '<'){
                    strcat(n_line,pre[0]);
                }
                //The name of all dependents
                else if(tok[1] == '^'){
                    for(int j=0; j<size; j++){
                        strcat(n_line, pre[j]);
                        strcat(n_line, " ");
                    }
                }
                //Current target
                else if(tok[1] == '@'){
                    strcat(n_line, target);
                }
                /*
                else if(tok[i] == '?'){
                }*/
            }       
            else 
                strcat(n_line, tok);
            strcat(n_line,  " ");
            tok= strtok(NULL, " ");    
        }
		int ret = system(n_line);
		if(WEXITSTATUS(ret) == 0)
			printf("Executable Command\n");
		else if(WIFSIGNALED(ret))
			printf("Abnormally Terminated : %d\n", WTERMSIG(ret));
		n++;
		continue;
	}
    //target line
    else if(strstr(line, ":") != NULL) {
        strcpy(target, strtok(line, ":"));
        char *ptr = strtok(NULL, " ");
        size=0;
        int i=0;
        while( ptr != NULL){
            strcpy(pre[i], ptr);
            i++;
            ptr = strtok(NULL, " ");
        }
        size = i;
        
    }
        YY_BUFFER_STATE buffer = yy_scan_string(line);
        yy_switch_to_buffer(buffer);
        yyparse();
        yy_delete_buffer(buffer);
        printf("\n");
        n++;
    }
    free(pre);
    pre=NULL;
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
