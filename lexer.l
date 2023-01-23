%{
#include <stdio.h>
#include <stdbool.h>
#include <math.h>
#include "parser.h"
%}

%%
"("                     {return OBRACE;}
")"                     {return CBRACE;}
\"                      {return QUOTE;}
"."                     {return DOT;}
","                     {return COMMA;}



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

"integer"               {return TOK_INTEGER;}
"float"                 {return TOK_FLOAT;}
"string"                {return TOK_STRING;}
"boolean"               {return TOK_BOOLEAN;}
"reference"             {return TOK_REFERENCE;}

"values"                {return TOK_VALUES;}
"delete"                {return TOK_DELETE;}

"true"|"false"        {yylval.boolean = !strcmp(yytext, "true"); return BOOLEAN;}

[a-zA-Z][a-zA-Z0-9_]*           {yylval.string = strdup(yytext); return WORD;}
(\.[0-9]+)|([0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?)   {
      double f = atof(yytext);
      if (ceil(f) == f) {
        yylval.integer = atoi(yytext);
        return INTEGER;
      } else {
        yylval.decimal = f;
        return DECIMAL;
      }
}

\n                      {/* ignore end of line */;}
[ \t]+                  {/* ignore whitespace */;}
%%
