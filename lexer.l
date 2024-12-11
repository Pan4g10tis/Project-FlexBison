%{
#include </home/Panagiotis/project/syntax.tab.h>
extern FILE *yyin;
%}

%%

"public" { return PUBLIC; }
"private" { return PRIVATE; }
"class" { return CLASS; }
"void" { return VOID; }
"int" { return INT; }
"char" { return CHAR; }
"double" { return DOUBLE; }
"boolean" { return BOOLEAN; }
"String" { return STRING; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"do" { return DO; }
"for" { return FOR; }
"switch" { return SWITCH; }
"case" { return CASE; }
"default" { return DEFAULT; }
"return" { return RETURN; }
"out\.print" { return PRINT; }
"break" { return BREAK; }
"new" { return NEW; }
"true" { return TRUE; }
"false" { return FALSE; }
"&&" { return AND; }
"||" { return OR; }
"==" { return EQUAL; }
"!=" { return NOT_EQUAL; }
";" { return SEMICOLON; }
":" { return COLON; }
"," { return COMMA; }
"{" { return LEFT_BRACKET; }
"}" { return RIGHT_BRACKET; }
"(" { return LEFT_PARENTHESIS; }
")" { return RIGHT_PARENTHESIS; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"/" { return DIVIDE; }
">" { return GREATER; }
"<" { return LESS; }
"=" { return ASSIGN; }
[A-Z][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return CLASS_NAME; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
[0-9]+ { yylval.ival = atoi(yytext); return INTEGER_LITERAL; }
\"([^\\\n]|(\\.))*\" { yylval.sval = strdup(yytext); return STRING_LITERAL; }
'.' { yylval.cval = yytext[1]; return CHAR_LITERAL; }
[0-9]+\.[0-9]+d { yylval.dval = atof(yytext); return DOUBLE_LITERAL; }
"//".*
"/*"([^*]|[\r\n]|"*"+([^*/]|[\r\n]))*"*/"
"\." { return DOT; }
[ \t] { /* ignore whitespace */ }
"\n" {yylineno++;}
. { return yytext[0]; }
