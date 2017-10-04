%{
#include <stdio.h>
void show(char* text);
extern FILE *yyin;
%}

%option yylineno

delimitador     [ \t\n]
comentario      \/\/.*
letra           [a-zA-Z]
digito          [0-9]
constante       {digito}+
identificador   {letra}({letra}|{digito}|\_)*

%%

{delimitador}   {  }
{comentario}    {  }

"read"          { show("Reserved word: "); }
"print"         { show("Reserved word: "); }
"if"            { show("Reserved word: "); }
"else"          { show("Reserved word: "); }
"elseif"        { show("Reserved word: "); }
"while"         { show("Reserved word: "); }
"do"            { show("Reserved word: "); }
"int"           { show("Reserved word: "); }
"bool"          { show("Reserved word: "); }
"true"          { show("Reserved word: "); }
"false"         { show("Reserved word: "); }

"="             { show("operator:      "); }
"+"             { show("operator:      "); }
"-"             { show("operator:      "); }
"*"             { show("operator:      "); }
"/"             { show("operator:      "); }
"%"             { show("operator:      "); }
"("             { show("delimiter:     "); }
")"             { show("delimiter:     "); }
";"             { show("delimiter:     "); }

{constante}     { show("cte:           "); }
{identificador} { show("id:            "); }
.               { show("invalid char:  "); }

%%

void show(char* text) {
    printf("%3d-%s %s\n", yylineno, text, yytext);
}

int main () {
    printf("%2d.- ", yylineno);
    yylex();
}
