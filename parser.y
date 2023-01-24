%{
#include "request_tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int yylex();
int yyparse();
void yyerror(const char *s);

request_tree tree = {.type = UNDEFINED};
bool array_list_created = false;

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
	int attribute_type;
}

%type<string> quoted_argument
%type<attribute_type> attribute_type

%token OBRACE CBRACE QUOTE DOT COMMA SEMICOLON

%token TOK_OPEN TOK_CREATE TOK_CLOSE
%token TOK_ADD_SCHEMA TOK_DELETE_SCHEMA
%token TOK_ADD_NODE TOK_NODES TOK_SELECT
%token TOK_GREATER TOK_GREATER_EQUAL TOK_LESS TOK_LESS_EQUAL TOK_NOT_EQUAL TOK_LIKE
%token TOK_VALUES TOK_DELETE
%token TOK_OUT
%token <string> FILENAME

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
	| commands command {
	YYACCEPT;
	}
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
	|
	select_nodes_condition
	|
	join_command
	|
	delete_command
	;

open_file:
	TOK_OPEN OBRACE QUOTE FILENAME QUOTE CBRACE
	{
		tree.type = REQUEST_OPEN;
		tree.file_work.filename = malloc(sizeof(char) * strlen($4));
		strcpy(tree.file_work.filename, $4);
	};
create_file:
	TOK_CREATE OBRACE QUOTE FILENAME QUOTE CBRACE
	{
		tree.type = REQUEST_CREATE;
		tree.file_work.filename = malloc(sizeof(char) * strlen($4));
		strcpy(tree.file_work.filename, $4);
	};

close_file:
	TOK_CLOSE OBRACE CBRACE
	{
		tree.type = REQUEST_CLOSE;
	};

add_schema:
	TOK_ADD_SCHEMA OBRACE quoted_argument attribute_pairs CBRACE
	{
		tree.type = REQUEST_ADD_SCHEMA;
		tree.add_schema.schema_name = malloc(sizeof(char) * strlen($3));
		strcpy(tree.add_schema.schema_name, $3);
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

select_nodes:
	TOK_NODES OBRACE quoted_argument CBRACE
	{
		printf("select statement on %s\n", $3);
	}
	;

select_nodes_condition:
	select_nodes select_condition
	;

select_condition:
	| DOT TOK_SELECT OBRACE select_statements CBRACE
	{
		printf("condition of select\n");
	}
	;

join_command:
	select_nodes joins{
		printf("join_command\n");
	}
	|
	select_nodes_condition joins{
		printf("join_command\n");
	}
	;

joins:
	join | joins
	;

join:
	DOT TOK_OUT OBRACE quoted_argument CBRACE
	{
		printf("join %s\n", $4);
	}
	;

delete_command:
	join_command DOT TOK_DELETE {
		printf("delete command\n");
	}
	|
	select_nodes DOT TOK_DELETE {
		printf("delete command\n");
	}
	|
	select_nodes_condition DOT TOK_DELETE {
		printf("delete command\n");
	}
	;

select_statements:
	| select_statements select_statement COMMA {

	}
	| select_statements select_statement {

	}
	;

select_statement:
	quoted_argument COMMA select_option {

	}
	;

select_option:
	option_compare 
	| option_greater
	| option_greater_equal
	| option_less
	| option_less_equal
	| option_not_equal
	| option_like
	;

option_compare:
	INTEGER | DECIMAL | BOOLEAN | quoted_argument
	;

option_greater:
	TOK_GREATER OBRACE INTEGER CBRACE
	| TOK_GREATER OBRACE DECIMAL CBRACE
	| TOK_GREATER OBRACE BOOLEAN CBRACE
	| TOK_GREATER OBRACE quoted_argument CBRACE
	;
option_greater_equal:
	TOK_GREATER_EQUAL OBRACE INTEGER CBRACE
	| TOK_GREATER_EQUAL OBRACE DECIMAL CBRACE
	| TOK_GREATER_EQUAL OBRACE BOOLEAN CBRACE
	| TOK_GREATER_EQUAL OBRACE quoted_argument CBRACE
	;

option_less:
	TOK_LESS OBRACE INTEGER CBRACE
	| TOK_LESS OBRACE DECIMAL CBRACE
	| TOK_LESS OBRACE BOOLEAN CBRACE
	| TOK_LESS OBRACE quoted_argument CBRACE
	;
option_less_equal:
	TOK_LESS_EQUAL OBRACE INTEGER CBRACE
	| TOK_LESS_EQUAL OBRACE DECIMAL CBRACE
	| TOK_LESS_EQUAL OBRACE BOOLEAN CBRACE
	| TOK_LESS_EQUAL OBRACE quoted_argument CBRACE
	;
option_not_equal:
	TOK_NOT_EQUAL OBRACE INTEGER CBRACE
	| TOK_NOT_EQUAL OBRACE DECIMAL CBRACE
	| TOK_NOT_EQUAL OBRACE BOOLEAN CBRACE
	| TOK_NOT_EQUAL OBRACE quoted_argument CBRACE
	;
option_like:
	TOK_LIKE OBRACE quoted_argument CBRACE
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
	;

attribute_pairs:
	| attribute_pairs COMMA attribute_pair {
	}
	;

attribute_type:
	TOK_INTEGER {
		$$ = ATTR_TYPE_INTEGER;
	}
	| TOK_STRING {
		$$ = ATTR_TYPE_STRING;
	}
	| TOK_FLOAT {
		$$ = ATTR_TYPE_FLOAT;
	}
	| TOK_BOOLEAN {
		$$ = ATTR_TYPE_BOOLEAN;
	}
	| TOK_REFERENCE {
		$$ = ATTR_TYPE_REFERENCE;
	}
	
	;
attribute_pair:
	quoted_argument COMMA attribute_type {
		if (!array_list_created) {
		tree.add_schema.attribute_declarations = arraylist_create();
		printf("arraylist created\n");
		array_list_created = true;
		}
		attribute_declaration *attr_decl = malloc(sizeof(attribute_declaration));
		*attr_decl = (attribute_declaration) {
		.attr_name = malloc(sizeof(char) * strlen($1)),
		.type = $3,
		};
		strcpy(attr_decl->attr_name, $1);
		arraylist_add(tree.add_schema.attribute_declarations, attr_decl);
	}
	| quoted_argument COMMA TOK_REFERENCE OBRACE quoted_argument CBRACE {
		if (!array_list_created) {
		tree.add_schema.attribute_declarations = arraylist_create();
		printf("arraylist created\n");
		array_list_created = true;
		}
		attribute_declaration *attr_decl = malloc(sizeof(attribute_declaration));
		*attr_decl = (attribute_declaration) {
		.attr_name = malloc(sizeof(char) * strlen($1)),
		.type = ATTR_TYPE_REFERENCE,
		.schema_ref_name = malloc(sizeof(char) * strlen($5))
		};
		strcpy(attr_decl->attr_name, $1);
		strcpy(attr_decl->schema_ref_name, $5);
		arraylist_add(tree.add_schema.attribute_declarations, attr_decl);
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

request_tree get_request_tree(){
	return tree;
}
