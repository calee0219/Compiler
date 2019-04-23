%{
#include <stdio.h>
#include <stdlib.h>

#ifdef DEBUG
int debug = 1;
#else
int debug = 0;
#endif

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
    | decl_and_def_list definition
    ;

declaration_list
    : empty
    | declaration_list const_decl
    | declaration_list var_decl
    | declaration_list funct_decl
    ;

/*
definition_list
    : definition_list definition
    | definition
    ;
*/
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
    | compound_statement
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
    | empty
    ;
control_expression
    : expression
    | identifier_assignment
    | array_reference_assignment
    | empty
    ;
increment_expression
    : expression
    | identifier_assignment
    | array_reference_assignment
    | empty
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
    : expression_2
    | expression_2 OR expression
    ;
expression_2
    : expression_3
    | expression_3 AND expression_2
    ;
expression_3
    : boolean_expression
    | NOT expression_3
    ;
expression_5
    : expression_6
    | expression_6 POS expression_5
    | expression_6 NEG expression_5
    ;
expression_6
    : expression_7
    | expression_7 MUL expression_6
    | expression_7 DIV expression_6
    | expression_7 MOD expression_6
    ;
expression_7
    : expression_terminal
    | NEG expression_7 %prec UMINUS
    ;
boolean_expression
    : expression_5
    | expression_5 LT boolean_expression
    | expression_5 LE boolean_expression
    | expression_5 EQ boolean_expression
    | expression_5 GE boolean_expression
    | expression_5 GT boolean_expression
    | expression_5 NEQ boolean_expression
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
    : type var_del_all_list SEMICOLON
    ;
var_del_all_list
    : var_del_all { if(debug) printf("empty\n"); }
    | var_del_all_list ',' var_del_all { if(debug) printf("id_list\n"); }
    ;
var_del_all
    : identifier { if(debug) printf("id\n"); }
    | identifier_assignment { if(debug) printf("id_ass\n"); }
    | array_reference { if(debug) printf("array\n"); }
    | array_reference_assignment { if(debug) printf("array ass\n"); }
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
/*
identifier_assignment_list
    : identifier_assignment_list ',' identifier_assignment
    | identifier_assignment
    ;
*/
identifier_assignment
    : identifier '=' expression
    ;

/* variable */
variable_reference
    : identifier
    | array_reference
    ;
/*
array_reference_list
    : array_reference_list ',' array_reference
    | array_reference
    ;
*/
array_reference
    : identifier array_bracket_list { if(debug) printf("array list\n"); }
    ;
/*
array_reference_assignment_list
    : array_reference_assignment_list ',' array_reference_assignment
    | array_reference_assignment { if(debug) printf("array_ref ass not list\n"); }
    ;
*/
array_reference_assignment
    : array_reference '=' initial_array { if(debug) printf("arr assignment\n"); }
    ;
initial_array
    : '{' argu_expression_list '}'
    | '{' '}'
    ;
array_bracket_list
    : array_bracket_list array_bracket { if(debug) printf("list of array bracket\n"); }
    | array_bracket { if(debug) printf("[]\n"); }
    ;
array_bracket
    : '[' expression ']' { if(debug) printf("bracket\n"); }
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
/*
identifier_list
    : identifier_list ',' identifier
    | identifier
    ;
*/
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

