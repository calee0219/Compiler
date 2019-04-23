%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}

/* value */
%token INT_NUMBER FLOAT_NUMBER SCI_NUMBER
%token TRUE FALSE
%token STRVAR
/* delim */
%token SEMICOLON
/* op */
%token POS NEG MUL DIV MOD OR AND NOT LT LE EQ GE GT NEQ
/* id */
%token ID      /* identifier */
/* kw */
%token INT DOUBLE FLOAT STRING VOID CONST PRINT READ IF ELSE WHILE DO FOR RETURN BREAK CONTINUE BOOL BOOLEAN

%nonassoc UMINUS
%left MUL DIV MOD
%left POS NEG
%left LT LE EQ GE GT NEQ
%right NOT
%left OR AND

%%

program
    : declaration_list definition decl_and_def_list
    ;

empty : ;

decl_and_def_list
    : empty
    | decl_and_def_list const_decl
    | decl_and_def_list var_decl
    | decl_and_def_list funct_decl
    | decl_and_def_list definition_list
    ;

declaration_list
    : empty
    | declaration_list const_decl
    | declaration_list var_decl
    | declaration_list funct_decl
    ;

definition_list
    : definition_list definition
    | definition
    ;
definition
    : type identifier '(' argu_decl_list ')' compound_statement
    | type identifier '(' ')' compound_statement
    ;
/* statement */
compound_statement
    : '{' statement_list '}'
    | '{' '}'
    ;
statement_list
    : statement_list statement
    | statement
    ;
statement
    : var_decl
    | const_decl
    | simple_statement
    | conditional_statement
    | while_statement
    | for_statement
    | jump_statement
    | func_statement
    ;
simple_statement
    : variable_reference '=' expression SEMICOLON
    | PRINT variable_reference SEMICOLON
    | PRINT expression SEMICOLON
    | READ variable_reference SEMICOLON
    ;
conditional_statement
    : IF '(' boolean_expression ')' compound_statement else_statement
    ;
else_statement
    : empty
    | ELSE compound_statement
    ;

while_statement
    : DO compound_statement WHILE '(' boolean_expression ')' SEMICOLON
    | WHILE '(' boolean_expression ')' compound_statement
    ;
for_statement
    : FOR '(' initial_expression SEMICOLON control_expression SEMICOLON increment_expression ')' compound_statement
    ;
initial_expression
    : expression
    | identifier_assignment
    | array_reference_assignment
    ;
control_expression
    : expression
    | identifier_assignment
    | array_reference_assignment
    ;
increment_expression
    : expression
    | identifier_assignment
    | array_reference_assignment
    ;

jump_statement
    : RETURN expression SEMICOLON
    | BREAK SEMICOLON
    | CONTINUE SEMICOLON
    ;
func_statement
    : identifier '(' argu_expression_list ')' SEMICOLON
    ;

/* expression */
expression_terminal
    : '(' expression ')'
    | identifier
    | array_reference
    | INT_NUMBER
    | FLOAT_NUMBER
    | SCI_NUMBER
    | STRVAR
    | TRUE
    | FALSE
    | funct_expression
    ;
expression
    : expression OR expression
    | expression AND expression
    | NOT expression
    | expression LT expression
    | expression LE expression
    | expression EQ expression
    | expression GE expression
    | expression GT expression
    | expression NEQ expression
    | expression POS expression
    | expression NEG expression
    | expression MUL expression
    | expression DIV expression
    | expression MOD expression
    | NEG expression %prec UMINUS
    | expression_terminal
    ;
boolean_expression
    : expression LT expression
    | expression LE expression
    | expression EQ expression
    | expression GE expression
    | expression GT expression
    | expression NEQ expression
    | expression_terminal
    ;
funct_expression
    : identifier '(' ')'
    | identifier '(' argu_expression_list ')'
    ;
argu_expression_list
    : argu_expression_list ',' argu_expression
    | argu_expression
    ;
argu_expression
    : expression
    ;

/* declaration defined here */
var_decl
    : type identifier_list SEMICOLON
    | type identifier_assignment_list SEMICOLON
    | type array_reference_list SEMICOLON
    | type array_reference_assignment_list SEMICOLON
    ;
const_decl
    : CONST var_decl
    ;
funct_decl
    : type identifier '(' argu_decl_list ')' SEMICOLON
    | type identifier '(' ')' SEMICOLON
    ;

/* argument declaration list */
argu_decl_list
    : argu_decl_list ',' argu_decl
    | argu_decl
    ;
argu_decl
    : type identifier
    ;

/* identifier initialized */
identifier_assignment_list
    : identifier_assignment_list ',' identifier_assignment
    | identifier_assignment
    ;
identifier_assignment
    : identifier '=' expression
    ;

/* variable */
variable_reference
    : identifier
    | array_reference
    ;
array_reference_list
    : array_reference_list ',' array_reference
    | array_reference
    ;
array_reference
    : identifier array_bracket_list
    ;
array_reference_assignment_list
    : array_reference_assignment_list ',' array_reference_assignment
    | array_reference_assignment
    ;
array_reference_assignment
    : array_reference '=' initial_array
    ;
initial_array
    : '{' argu_expression_list '}'
    ;
array_bracket_list
    : array_bracket_list array_bracket
    | array_bracket
    ;
array_bracket
    : '[' expression ']'
    ;

type
    : INT
    | DOUBLE
    | FLOAT
    | STRING
    | VOID
    | BOOL
    ;

/* id */
identifier_list
    : identifier_list ',' identifier
    | identifier
    ;
identifier
    : ID
    ;

%%

int yyerror( char *msg )
{
  fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
  fprintf( stderr, "|--------------------------------------------------------------------------\n" );
  exit(-1);
}

int  main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );

	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}

	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}

