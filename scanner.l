%x IN_MATH
%{
#include "parser.h" 
%}

DOCCLASS 			\\documentclass*(\[(.)*\])*(\{(.)*\})*
PACKAGE 			\\usepackage(\[(.)*\])*(\{(.)*\})*
AUTHOR 				\\author(\{(.)*\})*
TITLE 				\\title	
BEGIN_DOC 			\\begin\{document\}					
END_DOC				\\end\{document\}
DOLLAR				\$
MAKETITLE			\\maketitle
BOLD				\\textbf
ITALIC				\\textit
BEGIN_ITEM			\\begin\{itemize\}
ITEM				\\item
END_ITEM			\\end\{itemize\}
INCLUDE_GRAPH			\\includegraphics
CITE				\\cite\{
BEGIN_BIB			\\begin\{thebibliography\}
BIB_ITEM			\\bibitem\{
END_BIB				\\end\{thebibliography\}

ENDL				\n

FLOAT 				[0-9]+\.[0-9]+
STRING 				[a-zA-Z0-9\-.,:;!?]+[ a-zA-Z0-9\-,.;:!?\(\)+^\*/]*
WHITESPACE 			[ \r\t]+
DIGIT  				[0-9]+
ANY_CHAR 			.

%%
	

<INITIAL>{
{DOLLAR}              		BEGIN(IN_MATH);

{DOCCLASS}			{ return T_DOCUMENT_CLASS; }
{PACKAGE}			{ return T_USE_PACKAGE; }
{AUTHOR}			{ return T_AUTHOR; }
{TITLE}				{ return T_TITLE; }
{BEGIN_DOC}			{ return T_BEGIN_DOCUMENT; }
{END_DOC}			{ return T_END_DOCUMENT; }
{MAKETITLE}			{ return T_MAKE_TITLE; }
{BOLD}				{ return T_BOLD; }
{ITALIC}			{ return T_ITALIC; }
{BEGIN_ITEM}			{ return T_BEGIN_ITEMIZE; }
{ITEM}				{ return T_ITEM; }
{END_ITEM}			{ return T_END_ITEMIZE; }
{INCLUDE_GRAPH}			{ return T_INCLUDE_GRAPHICS; }
{CITE}				{ return T_CITE; }
{BEGIN_BIB}			{ return T_BEGIN_BIBLIOGRAPHY; }
{BIB_ITEM}			{ return T_BIBLIOGRAPHY_ITEM; }
{END_BIB}			{ return T_END_BIBLIOGRAPHY; }

"["				{ return '['; }
"]"				{ return ']'; }
"{"				{ return '{'; }
"}"				{ return '}'; }

{DIGIT}				{return INT;}
{STRING}			{
					yylval.sval = (char*) strdup(yytext);	
					return T_STRING;
				}

{WHITESPACE}			;

{ENDL}				{ return ENDL; }

{ANY_CHAR} 			{
					printf("Caracter %c (ASCII %d) inesperado.\n", yytext[0], yytext[0]);
					return yytext[0];
				}
}
<IN_MATH>{
"$"	BEGIN(INITIAL);
[a-zA-Z0-9\-\\]+[ a-zA-Z0-9\-,.;:!?\(\)+^/\*\[\]\\\{\}]*     {
								yylval.sval = (char *) strdup(yytext);
								return T_MATH;}   
}
	
%%

// Codigo C


