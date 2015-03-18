%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#define STRSIZE 1024
#define DIGSIZE 10
#define OUTPUT_NAME "file.html"
#define YYDEBUG 1

char output_name[STRSIZE];
char *concat(int count, ...);
int match_string(char ** v, char * str);

void yyerror(const char* errmsg);
int yywrap(void);

extern FILE * yyin;
extern FILE * yyout;

FILE * output;

int has_title;
char * title_name;

char **bib;
int count_bib;
%}

%define parse.error verbose

%union{
	int ival;
	float fval;
	char *sval;
}

//constant string tokens
%token T_DOCUMENT_CLASS
%token T_USE_PACKAGE
%token T_AUTHOR
%token T_TITLE
%token T_BEGIN_DOCUMENT
%token T_END_DOCUMENT
%token T_DOLLAR
%token T_MAKE_TITLE
%token T_BOLD
%token T_ITALIC
%token T_BEGIN_ITEMIZE
%token T_ITEM
%token T_END_ITEMIZE
%token T_INCLUDE_GRAPHICS
%token T_CITE
%token T_BEGIN_BIBLIOGRAPHY
%token T_BIBLIOGRAPHY_ITEM
%token T_END_BIBLIOGRAPHY

%token <ival> INT
%token <fval> FLOAT
%token <sval> T_STRING ENDL T_COMMAND T_MATH

%type <sval> document documentlines documentline ENDLS text bold it itemize itemlines itemline bibliography bibitemlines bibitemline cite multiline;

%start latex

%%

// the first rule defined is the highest-level rule:
latex:
	header T_BEGIN_DOCUMENT ENDLS document T_END_DOCUMENT ENDLS	{	
										printf("Done parsing!\n");
										fprintf(output, "%s", "<!DOCTYPE html>\n");
										fprintf(output, "%s", "<html lang='pt-br'>\n");
										
										fprintf(output, "%s", "<head>\n");
										fprintf(output, "%s", "<meta charset='UTF-8' />\n");
										if(has_title)	fprintf(output, "%s", concat(3, "<title>", title_name, "</title>\n"));

										fprintf(output, "%s", "<script type='text/x-mathjax-config'>\n");
										fprintf(output, "%s", "\tMathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']], processEscapes: true}});\n");
										fprintf(output, "%s", "</script>\n");
										fprintf(output, "%s", "<script type='text/javascript'\n");
										fprintf(output, "%s", "\tsrc='http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'>\n");
										fprintf(output, "%s", "</script>\n");

										fprintf(output, "%s", "</head>\n");
										
										fprintf(output, "%s", "<body>\n");
										fprintf(output, "%s", $4);
										fprintf(output, "%s", "</body>\n");

										fprintf(output, "%s", "</html>\n");
									}
	;
header:
	headerlines
	;
	
headerlines:
	headerlines headerline
	| headerline						
	;
headerline:
	T_DOCUMENT_CLASS ENDLS					
	| T_USE_PACKAGE	ENDLS					
	| T_AUTHOR ENDLS						
	| T_TITLE '{' text '}'	ENDLS		{ title_name = strdup ($3); }		
	;
text:
	text T_STRING				{ $$ = concat (3, $1, " ", $2); }
	| text bold				{ $$ = concat (3, $1, " ", $2); }
	| text it				{ $$ = concat (3, $1, " ", $2); }
	| text T_MATH				{ $$ = concat (4, $1, " $", $2, "$"); }
	| text cite				{ $$ = concat (3, $1, " ", $2); }
	| T_MATH				{ $$ = concat (3, "$", $1, "$"); }
	| T_STRING	 			{ $$ = $1; }
	| bold					{ $$ = $1; }
	| it					{ $$ = $1; }
	| cite					{ $$ = $1; }
	;
	
cite:
	T_CITE T_STRING '}' 			{ 	char str[DIGSIZE];
							sprintf(str, "%d", match_string(bib, $2) );
							$$ = concat (3, "[", str, "]"); }
	;

document:
	documentlines				{ $$ = $1; }
	;
documentlines:
	documentlines documentline 		{ $$ = concat (2, $1, $2); }
	| documentline 				{ $$ = $1; }
	;
documentline:
	text ENDLS				{ $$ = concat (2, $1, $2); }
	| itemize				{ $$ = $1; }
	| T_MAKE_TITLE	ENDLS			{ has_title = 1; $$=""; }
	| T_INCLUDE_GRAPHICS '{' text '}' ENDLS	{ $$ = concat (4, "<img src='", $3, "'>", $5); }
	| bibliography				{ $$ = $1; }
	;
	
itemize:
	T_BEGIN_ITEMIZE ENDLS itemlines T_END_ITEMIZE ENDLS		{ $$ = concat(3, "<ul>", $3, "</ul>\n"); }
	;
itemlines:
	itemlines itemline			{ $$ = concat (2, $1, $2); }
	| itemlines itemize			{ $$ = concat (2, $1, $2); }
	| itemline				{ $$ = $1; }
	| itemize				{ $$ = $1; }
	;
itemline:
	T_ITEM text ENDLS			{ $$ = concat (3, "<li>", $2, "</li>\n"); }
	;	
		
bold:
	T_BOLD '{' text '}'			{ $$ = concat (3, "<b>", $3, "</b>"); }
	;
	
it:
	T_ITALIC '{' text '}'			{ $$ = concat (3, "<i>", $3, "</i>"); }
	;

bibliography:
	T_BEGIN_BIBLIOGRAPHY ENDLS bibitemlines T_END_BIBLIOGRAPHY ENDLS	{ $$ = concat (4, "<b>Bibliografia</b><br>", "<ol>", $3, "</ol>\n"); }
	;
	
bibitemlines:
	bibitemlines bibitemline		{ $$ = concat (2, $1, $2); }
	| bibitemline				{ $$ = $1; }
	;
bibitemline:
	T_BIBLIOGRAPHY_ITEM T_STRING '}' multiline 	{ 	count_bib++;
								bib[count_bib] = strdup ($2);
								$$ = concat (3, "<li>", $4, "</li>\n"); }
	;	
	
multiline:
	multiline text ENDLS			{ $$ = concat (3, $1, " ", $2); }
	| text ENDLS				{ $$ = concat (3, $1, " ", $2); }
	;
	
ENDLS:
	ENDLS ENDL				{ $$ = concat (2, $1, "<br>\n"); }
							
	| ENDL					{ $$ = strdup("\n"); }
	;

%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


int yywrap(void){
	return 1;
}


int main(int argc, char** argv) {
	yydebug = 0;
	has_title = 0;
	count_bib= 0;
	title_name = (char *) malloc (STRSIZE*sizeof(char));
	bib = (char **) malloc (STRSIZE*sizeof(char*));	

	// open a file handle to a particular file:
	FILE *F = fopen(argv[1], "r");
	
	// make sure it's valid:
	if (!F) {
		printf("*** I can't open a.snazzle.file!\n");
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = F;
	output=fopen("teste.html", "w");
	yyparse();
	close(F);
	F = fopen(argv[1], "r");

	if(argc>2)	printf("Wrong number of arguments. Terminating.\n");
	else if(argc==1){
		strcpy(output_name, OUTPUT_NAME);
		output = fopen(output_name, "w");
	}else if(argc==2){
		strcpy(output_name, strcat(argv[1], ".html"));
		output = fopen(output_name, "w");
	}

	// parse through the input until there is no more:
	do {
		yyin = F;
		yyparse();
		
	} while (!feof(F));

	free(title_name);
	free(bib);
	fclose(F);
	fclose(output);
	exit(0);
}

char* concat(int count, ...)
{
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}

int match_string(char ** v, char * str){
	int i;
	for(i=1; i<=count_bib; i++){
		if ( !strcmp(v[i], str)) return i;
	}
	return -1;
}

