%{
#include <stdio.h>

void yyerror(const char* errmsg);
void yywrap(void);

%}

%union{
	char *str;
	int intval;
}

//constant string tokens
%token T_AUTHOR T_DOCCLASS T_PACKAGE

%token <intval> T_DIGIT
%token <str> T_STRING

%%

tex:
	docclass packages title	author document

docclass: T_DOCCLASS ;

packages: T_PACKAGE ;

//title:

author: T_AUTHOR ;

//document: 

stmt_list:  	stmt ';'
	 | 	stmt_list stmt ';'

stmt: T_STRING '=' T_DIGIT     { printf("%s", $1); }

%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


void yywrap(void){
	return 1;
}


void main()
{
	yyparse();
	return 0;
}



