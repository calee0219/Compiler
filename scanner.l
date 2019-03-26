%{
#define MAX_LINE_LENGTH 256
#define MAX_ID_LENGTH 256
#define MAX_STRING_LENGTH 256
#define ID_MAX 10000
#define LIST                { strncat(buf, yytext, MAX_LINE_LENGTH); }
#define tokenString(t, s)   { LIST; if (Opt_Token) printf("<%s:%s>\n", t, s); }

int Opt_Source = 1;
int Opt_Token = 1;
int Opt_Statistic = 1;
int linenum = 1;
char buf[MAX_LINE_LENGTH+1];

int id_sz = 0;
char id_syn[ID_MAX][MAX_LINE_LENGTH+1];
int id_count[ID_MAX];
%}

%%

#pragma[\ \t]+(source|token|statistic)[\ \t]+(off|on) {
    LIST;
    char target[15];
    char onoff[5];
    int ison = 1;
    sscanf(yytext, "#pragma %s %s", target, onoff);
    if (!strcmp(onoff, "on")) {
        ison = 1;
    } else if (!strcmp(onoff, "off")) {
        ison = 0;
    } else {
        fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
        exit(1);
    }

    if (!strcmp(target, "source")) {
        Opt_Source = ison;
    } else if (!strcmp(target, "token")) {
        Opt_Token = ison;
    } else if (!strcmp(target, "statistic")) {
        Opt_Statistic = ison;
    } else {
        fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
        exit(1);
    }
}

\/\/.*\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}

\/\*(.|\n)*\*\/ {
    LIST;
    char * tok = strtok(buf, "\n");
    while(tok != NULL) {
        char * tmptok = tok;
        tok = strtok(NULL, "\n");
        if (tok == NULL) {
            strcpy(buf, tmptok);
            break;
        }
        if (Opt_Source) {
            printf("%d:%s\n\n", linenum, tmptok);
        }
        ++linenum;
    }
}

"(" {
    tokenString("delim", "(");
}

")" {
    tokenString("delim", ")");
}

"{" {
    tokenString("delim", "{");
}

"}" {
    tokenString("delim", "}");
}

"[" {
    tokenString("delim", "[");
}

"]" {
    tokenString("delim", "]");
}

; {
    tokenString("delim", ";");
}

, {
    tokenString("delim", ",");
}

"+" {
    tokenString("op", "+");
}

"-" {
    tokenString("op", "-");
}

"*" {
    tokenString("op", "*");
}

"/" {
    tokenString("op", "/");
}

"%" {
    tokenString("op", "%");
}

"=" {
    tokenString("op", "=");
}

"<" {
    tokenString("op", "<");
}

"<=" {
    tokenString("op", "<=");
}

"!=" {
    tokenString("op", "!=");
}

">=" {
    tokenString("op", ">=");
}

">" {
    tokenString("op", ">");
}

"==" {
    tokenString("op", "==");
}

"&&" {
    tokenString("op", "&&");
}

"||" {
    tokenString("op", "||");
}

"!" {
    tokenString("op", "!");
}

while {
    tokenString("kw", yytext);
}

do {
    tokenString("kw", yytext);
}

if {
    tokenString("kw", yytext);
}

else {
    tokenString("kw", yytext);
}

true {
    tokenString("kw", yytext);
}

false {
    tokenString("kw", yytext);
}

for {
    tokenString("kw", yytext);
}

int {
    tokenString("kw", yytext);
}

print {
    tokenString("kw", yytext);
}

const {
    tokenString("kw", yytext);
}

read {
    tokenString("kw", yytext);
}

boolean {
    tokenString("kw", yytext);
}

bool {
    tokenString("kw", yytext);
}

void {
    tokenString("kw", yytext);
}

float {
    tokenString("kw", yytext);
}

double {
    tokenString("kw", yytext);
}

string {
    tokenString("kw", yytext);
}

continue {
    tokenString("kw", yytext);
}

break {
    tokenString("kw", yytext);
}

return {
    tokenString("kw", yytext);
}

[0-9]+(\.[0-9]+)?[eE][-+]?[0-9]+ {
    tokenString("sci", yytext);
}

[0-9]+.[0-9]+ {
    tokenString("float", yytext);
}

[0-9]+ {
    tokenString("int", yytext);
}

[a-zA-Z][a-zA-Z0-9]* {
    tokenString("id", yytext);
    size_t idx;
    int hit = 0;
    for (idx = 0; idx < id_sz; ++idx) {
        if (!strcmp(id_syn[idx], yytext)) {
            hit = 1;
            id_count[idx] += 1;
        }
    }
    if (!hit) {
        strcpy(id_syn[id_sz], yytext);
        id_count[id_sz++] = 1;
    }
}

\"[^"]*\" {
    tokenString("string", yytext);
}

\n {
    LIST;
    if (Opt_Source)
        printf("%d:%s\n", linenum, buf);
    ++linenum;
    buf[0] = '\0';
}

[\ |\t] {
    LIST;
}

. { // Unrecognized character
    fprintf(stderr, "Error at line %d: %s\n", linenum, yytext);
    exit(1);
}

%%

int main( int argc, char **argv )
{
    if (argc >= 2)
    {
        yyin = fopen( argv[1], "r" );
        if ( NULL == yyin ) {
            fprintf( stderr, "Cannot open: %s\n", argv[1] );
            exit(-1);
        }
    }
    else
    {
        yyin = stdin;
    }

    yylex();

    if (Opt_Statistic)
    {
        printf("frequencies of identifiers:\n");
        size_t idx;
        for (idx = 0; idx < id_sz; ++idx) {
            printf("%s\t%d\n", id_syn[idx], id_count[idx]);
        }
        //format :  printf("%s\t%d\n");
    }

    exit(0);
}

/*int yywrap() {*/
    /*return 1;*/
/*}*/
