%{
#include <stdio.h>
#include <stdbool.h>
#include "parser.h"
%}

%%
"("                     {return OBRACE;}
")"                     {return CBRACE;}
\"                      {return QUOTE;}
"."                     {return DOT;}
[0-9]+                  {return NUMBER;}


"open"                  {return TOK_OPEN;}
"create"                {return TOK_CREATE;}
"close"                 {return TOK_CLOSE;}

"addSchema"             {return TOK_ADD_SCHEMA;}
"deleteSchema"          {return TOK_DELETE_SCHEMA;}

"addVertex"             {return TOK_ADD_NODE;}
"V"                     {return TOK_NODES;}
"has"                   {return TOK_SELECT;}

"gt"                    {return TOK_GREATER;}
"gte"                   {return TOK_GREATER_EQUAL;}
"lt"                    {return TOK_LESS;}
"lte"                   {return TOK_LESS_EQUAL;}
"neq"                   {return TOK_NOT_EQUAL;}
"like"                  {return TOK_LIKE;}

"values"                {return TOK_VALUES;}
"delete"                {return TOK_DELETE;}

[a-zA-Z][a-zA-Z0-9]*    {yylval.string = strdup(yytext); return WORD;}
\n                      {/* ignore end of line */;}
[ \t]+                  {/* ignore whitespace */;}
%%
