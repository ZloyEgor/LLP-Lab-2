%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
int yyparse();
void yyerror(const char *s);

char *file_name;
int opened = 0;

extern char *yytext;
#define YYDEBUG_LEXER_TEXT yytext

%}

%union
{
	int integer;
	char *string;
	float decimal;
	int boolean;
}
%type<string> quoted_argument

%token OBRACE CBRACE QUOTE DOT NUMBER
%token <string> WORD
%token TOK_OPEN TOK_CREATE TOK_CLOSE
%token TOK_ADD_SCHEMA TOK_DELETE_SCHEMA
%token TOK_ADD_NODE TOK_NODES TOK_SELECT
%token TOK_GREATER TOK_GREATER_EQUAL TOK_LESS TOK_LESS_EQUAL TOK_NOT_EQUAL TOK_LIKE
%token TOK_VALUES TOK_DELETE

%start commands

%%

commands: /* empty */
	| commands command
	;


command:
	open_file
	|
	create_file
	|
	close_file
	;

open_file:
	TOK_OPEN OBRACE quoted_argument CBRACE
	{
		printf("File %s opened\n", $3);
		opened = 1;
		file_name = malloc(sizeof(char) * strlen($3));
		strcpy(file_name, $3);
	};
create_file:
	TOK_CREATE OBRACE quoted_argument CBRACE
	{
		printf("File %s created and opened\n", $3);
		opened = 1;
		file_name = malloc(sizeof(char) * strlen($3));
		strcpy(file_name, $3);
	};

close_file:
	TOK_CLOSE OBRACE CBRACE
	{
		if (opened) {
		    printf("File %s closed\n", file_name);
		    free(file_name);
		    opened = 0;
		} else
		    printf("Nothing to close\n");

	};

add_schema:
	TOK_ADD_SCHEMA OBRACE quoted_argument CBRACE
	;

quoted_argument:
	QUOTE WORD QUOTE
	{
		$$ = $2;
	}
	;
%%

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n%s\n",str, yytext);
}

int yywrap()
{
	return 1;
}
