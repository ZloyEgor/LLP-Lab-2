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
	char *ref_name;
}
%type<string> quoted_argument

%token OBRACE CBRACE QUOTE DOT COMMA

%token TOK_OPEN TOK_CREATE TOK_CLOSE
%token TOK_ADD_SCHEMA TOK_DELETE_SCHEMA
%token TOK_ADD_NODE TOK_NODES TOK_SELECT
%token TOK_GREATER TOK_GREATER_EQUAL TOK_LESS TOK_LESS_EQUAL TOK_NOT_EQUAL TOK_LIKE
%token TOK_VALUES TOK_DELETE

%token <integer> INTEGER
%token <decimal> DECIMAL
%token <boolean> BOOLEAN
%token <string> WORD

%token TOK_INTEGER 
%token TOK_FLOAT 
%token TOK_STRING
%token TOK_BOOLEAN 
%token TOK_REFERENCE

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
	|
	add_schema
	|
	delete_schema
	|
	add_vertex
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
	TOK_ADD_SCHEMA OBRACE quoted_argument attribute_pairs CBRACE
	{
		printf("schema %s added successfully\n", $3);
	};

delete_schema:
	TOK_DELETE_SCHEMA OBRACE quoted_argument CBRACE
	{
		printf("schema %s deleted\n", $3);
	};

add_vertex:
	TOK_ADD_NODE OBRACE quoted_argument attribute_value_pairs CBRACE 
	{
		printf("node %s added successfully\n", $3);
	}
	;

attribute_value_pairs:
	| attribute_value_pairs COMMA attribute_value_pair {

	};

attribute_value_pair:
	quoted_argument COMMA INTEGER {
		printf("%s (integer): %d\n", $1, $3);
	}
	| quoted_argument COMMA DECIMAL{
		printf("%s (decimal): %.4f\n", $1, $3);
	}
	| quoted_argument COMMA BOOLEAN{
		printf("%s (boolean): %s\n", $1, $3? "true" : "false")
	}
	| quoted_argument COMMA WORD{
		
	}

attribute_pairs:
	| attribute_pairs COMMA attribute_pair {
	}
	;

attribute_pair:
	quoted_argument COMMA TOK_INTEGER {
		printf("%s: integer\n", $1);
	}
	| quoted_argument COMMA TOK_STRING {
		printf("%s: string\n", $1);
	}
	| quoted_argument COMMA TOK_FLOAT {
		printf("%s: float\n", $1);
	}
	| quoted_argument COMMA TOK_BOOLEAN {
		printf("%s: boolean\n", $1);
	}
	| quoted_argument COMMA TOK_REFERENCE OBRACE quoted_argument CBRACE{
		printf("%s: reference to %s\n", $1, $5);
	}
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
