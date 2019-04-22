%{
#include <string.h>
#include <stdio.h>
#include <y.tab.h>

#define MAX_LINE_LENGTH 256
#define MAX_ID_LENGTH 256
#define MAX_STRING_LENGTH 256
#define LIST                { strncat(buf, yytext, MAX_LINE_LENGTH); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }
int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic =1;
int linenum = 1;
int Last_State = 0;
char buf[MAX_LINE_LENGTH];
char strContent[MAX_STRING_LENGTH];
typedef struct ids{
    char id_name[MAX_ID_LENGTH];
    int freq;
    struct ids *next;
} id;
id *id_head;
void set(id **, char *);
id *new_id();
%}

%x PRAGMA
%x SOURCE
%x TOKEN
%x STATISTIC
%x OTHER
%x STR
%x STR_ESCAPE
%x COMMENT

%%
<INITIAL>[\t ]+ {
    LIST;
}
^#pragma[\t ]+ {
    LIST;
    BEGIN PRAGMA;
}
<PRAGMA>"source"[\t ]+ {
    LIST;
    BEGIN SOURCE;
}
<PRAGMA>"token"[\t ]+ {
    LIST;
    BEGIN TOKEN;
}
<PRAGMA>"statistic"[\t ]+ {
    LIST;
    BEGIN STATISTIC;
}

<SOURCE>"on"[\t ]* {
    LIST;
    Opt_Source = 1;
    BEGIN OTHER;
}
<SOURCE>"off"[\t ]* {
    LIST;
    Opt_Source = 0;
    BEGIN OTHER;
}

<SOURCE>[^\t ] {
    fprintf(stderr,"Error at line %d: %s\n",linenum,yytext);
    exit(1);
}
<TOKEN>"on"[\t ]* {
    LIST;
    Opt_Token = 1;
    BEGIN OTHER;
}
<TOKEN>"off"[\t ]* {
    LIST;
    Opt_Token = 0;
    BEGIN OTHER;
}

<TOKEN>[^\t ] {
    fprintf(stderr,"Error at line %d: %s\n",linenum,yytext);
    exit(1);
}

<STATISTIC>"on"[\t ]* {
    LIST;
    Opt_Statistic = 1;
    BEGIN OTHER;
}
<STATISTIC>"off"[\t ]* {
    LIST;
    Opt_Statistic = 0;
    BEGIN OTHER;
}

<STATISTIC>[^\t ] {
    fprintf(stderr,"Error at line %d: %s\n",linenum,yytext);
    exit(1);
}
<OTHER>\/\/[^\n]* {
    LIST;
}
<OTHER>"/*" {
    LIST;
    Last_State = OTHER;
    BEGIN COMMENT;
}

<OTHER>\n {
    LIST;
    if (Opt_Source){
        printf("%d:%s\n", linenum, buf);
    }
    linenum++;
    buf[0] = '\0';
    BEGIN INITIAL;
}
<OTHER>[\t ]+ { //tab and space after comment
    LIST;
}

<OTHER>[^\n] {
    fprintf(stderr,"Error at line %d: %s\n",linenum,yytext);
    exit(1);
}

<PRAGMA>[^\t ] {
    fprintf(stderr,"Error at line %d: %s\n",linenum,yytext);
    exit(1);
}
"(" {
    tokenString("delim", "(");
    return('(');
}
")" {
    tokenString("delim", ")");
    return(')');
}
"," {
    tokenString("delim", ",");
    return(',');
}
";" {
    tokenString("delim", ";");
    return(SEMICOLON);
}
"[" {
    tokenString("delim", "[");
    return('[');
}
"]" {
    tokenString("delim", "]");
    return(']');
}
"{" {
    tokenString("delim", "{");
    return('{');
}
"}" {
    tokenString("delim", "}");
    return('}');
}
"+" {
    tokenString("op", "+");
    return(POS);
}
"-" {
    tokenString("op", "-");
    return(NEG);
}
"*" {
    tokenString("op", "*");
    return(MUL);
}
"/" {
    tokenString("op", "/");
    return(DIV);
}
"%" {
    tokenString("op", "%");
    return(MOD);
}
"=" {
    tokenString("op", "=");
    return('=');
}
"<" {
    tokenString("op", "<");
    return(LT);
}
"<=" {
    tokenString("op", "<=");
    return(LE);
}
"!=" {
    tokenString("op", "!=");
    return(NEQ);
}
">=" {
    tokenString("op", ">=");
    return(GE);
}
">" {
    tokenString("op", ">");
    return(GT);
}
"==" {
    tokenString("op", "==");
    return(EQ);
}
"&&" {
    tokenString("op", "&&");
    return(AND);
}
"||" {
    tokenString("op", "||");
    return(OR);
}
"!" {
    tokenString("op", "!");
    return(NOT);
}
read {
    tokenString("kw", yytext);
    return(READ);
}
boolean {
    tokenString("kw", yytext);
    return(BOOLEAN);
}
while {
    tokenString("kw", yytext);
    return(WHILE);
}
do {
    tokenString("kw", yytext);
    return(DO);
}
if {
    tokenString("kw", yytext);
    return(IF);
}
else {
    tokenString("kw", yytext);
    return(ELSE);
}
true {
    tokenString("kw", yytext);
    return(TRUE);
}
false {
    tokenString("kw", yytext);
    return(FALSE);
}
for {
    tokenString("kw", yytext);
    return(FOR);
}
const {
    tokenString("kw", yytext);
    return(CONST);
}
int {
    tokenString("kw", yytext);
    return(INT);
}
print {
    tokenString("kw", yytext);
    return(PRINT);
}
bool {
    tokenString("kw", yytext);
    return(BOOL);
}
void {
    tokenString("kw", yytext);
    return(VOID);
}
float {
    tokenString("kw", yytext);
    return(FLOAT);
}
double {
    tokenString("kw", yytext);
    return(DOUBLE);
}
string {
    tokenString("kw", yytext);
    return(STRING);
}
continue {
    tokenString("kw", yytext);
    return(CONTINUE);
}
break {
    tokenString("kw", yytext);
    return(BREAK);
}
return  {
    tokenString("kw", yytext);
    return(RETURN);
}

0 |
[1-9][0-9]* {
    tokenString("int", yytext);
    return(INT_NUMBER);
}
[0-9]+\.[0-9]+  {
    tokenString("float", yytext);
    return(FLOAT_NUMBER);
}

([0-9]+(\.[0-9]+)?)([eE][-+]?[0-9]+)  {
    tokenString("sci", yytext);
    return(SCI_NUMBER);
}
"\"" {
    LIST;
    strContent[0] = '\0';
    BEGIN STR;
}
<STR>"\\" {
    LIST;
    BEGIN STR_ESCAPE;
}
<STR_ESCAPE>\" {
    LIST;
    strncat (strContent, "\"", MAX_STRING_LENGTH);
    BEGIN STR;
}
<STR_ESCAPE>n {
    LIST;
    strncat( strContent, "\\n", MAX_STRING_LENGTH);
    BEGIN STR;
}
<STR_ESCAPE>t {
    LIST;
    strncat( strContent, "\\t", MAX_STRING_LENGTH);
    BEGIN STR;
}
<STR_ESCAPE>\\ {
    LIST;
    strncat( strContent, "\\", MAX_STRING_LENGTH);
    BEGIN STR;
}
<STR_ESCAPE>\n {
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}
<STR_ESCAPE>[^\"nt\\] {
    LIST;
    strncat( strContent, "\\", MAX_STRING_LENGTH);
    strncat( strContent, yytext, MAX_STRING_LENGTH);
    BEGIN STR;
}
<STR>"\n" {
    fprintf(stderr,"Error at line %d: %s\n",linenum,yytext);
    exit(1);
}
<STR>\" {
    tokenString("string", strContent);
    BEGIN INITIAL;
    return(STRVAR);
}
<STR>[^\\\n\"]  {
    LIST;
    strncat( strContent, yytext, MAX_STRING_LENGTH);
}

"/*" {
    LIST;
    Last_State = INITIAL;
    BEGIN COMMENT;
}

<COMMENT>"\n" {
    LIST;
    if(Last_State == OTHER)Last_State = INITIAL;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    linenum++;
    buf[0] = '\0';
}


<COMMENT>. {
    LIST;
}

<COMMENT>"*/" {
    LIST;
    BEGIN Last_State;
}

\/\/.* {
    LIST;
}

\n {
  LIST;
  if (Opt_Source)
    printf("%d:%s\n", linenum, buf);
  linenum++;
  buf[0] = '\0';
}

[a-zA-Z_][a-zA-Z0-9_]{0,255} {
    if(Opt_Statistic){
        set(&id_head,yytext);
    }
    tokenString("id",yytext);
    return(ID);
}

. {
    fprintf(stderr,"Error at line %d: %s\n",linenum, yytext);
    exit(1);
}
%%

/*
int main( int argc, char **argv )
{

    if( argc == 1 )
    {
        yyin = stdin;
    }
    else if( argc == 2 )
    {
        FILE *fp = fopen( argv[1], "r" );
        if( fp == NULL ) {
            fprintf( stderr, "Open file error\n" );
            exit(-1);
        }
        yyin = fp;
    }
    else
    {
        fprintf( stderr, "Usage: ./scanner [filename]\n" );
        exit(0);
    }


    id_head = NULL;
    yylex();

    if(Opt_Statistic){
        printf("frequencies of identifiers:\n");
        id *offset = id_head;
        id *tobefree = id_head;
        while(offset){
                printf("%s\t%d\n",offset->id_name, offset->freq);
                offset = offset->next;
        }
        //free linked list
        while(tobefree){
            offset = tobefree;
            tobefree = tobefree->next;
            free(offset);
        }
    }

    exit(0);
}
*/

void set(id **head, char *yytext)
{
    id *offset = *head;
    id *prev = NULL;
    if(offset == NULL){
        *head = new_id();
        strncpy((*head)->id_name, yytext,strlen(yytext));
        (*head)->freq = 1;
    }else{
        while(offset){
            if(!strncmp(offset->id_name, yytext, (strlen(yytext)>=strlen(offset->id_name)?strlen(yytext):strlen(offset->id_name)))){
                offset->freq+=1;
                break;
            }
            prev = offset;
            offset = offset -> next;
        }
        if(!offset){
            prev->next = new_id();
            strncpy(prev->next->id_name, yytext, strlen(yytext));
            prev->next->freq+=1;
        }
    }
}
id *new_id()
{
    id *temp = (id *)malloc(sizeof(id));
    temp->next = NULL;
    memset(temp->id_name, 0, 256);
    temp->freq = 0;
    return temp;
}

