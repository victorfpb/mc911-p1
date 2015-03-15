%{
#include "parser.h" 
%}

AUTHOR \\author{[a-zA-Z0-9 ]*}
DOCCLASS \\documentclass\[[a-zA-Z0-9 ,]*\]{[a-zA-Z0-9 ]*}
PACKAGE \\usepackage\[[a-zA-Z0-9 ,]*\]{[a-zA-Z0-9 ]*}

STRING [a-z][a-zA-Z0-9]*
DIGIT  [0-9]+
ANY_CHAR .

%%

{AUTHOR}	{return T_AUTHOR;}

{DOCCLASS}	{return T_DOCCLASS;}

{PACKAGE}	{return T_PACKAGE;}

{DIGIT}		{return T_DIGIT;}

{STRING}	{
			yylval.str = (char*) strdup(yytext);	
			return T_STRING;
		}

";"		{return ';';}
"="		{return '=';}		

{ANY_CHAR} {
	printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
}
	
%%

// Codigo C


