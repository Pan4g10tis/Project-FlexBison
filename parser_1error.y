%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;

void yyerror(const char *s);
extern int yylex();
extern int yylineno;
int yyerror_flag = 0;

typedef struct {
    char name[256]; 
    int declared;  
} VariableInfo;

typedef struct {
    char name[256]; 
    int declared;  
} MethodInfo;

VariableInfo symbol_table[100];
int symbol_count = 0;
MethodInfo method_table[100];
int method_count = 0;

int is_variable_declared(const char *name) {
    int i;
    for (i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].declared == 1) {
            return 1;
        }
    }
    return 0;
}

int is_method_declared(const char *name) {
    int i;
    for (i = 0; i < method_count; i++) {
        if (strcmp(method_table[i].name, name) == 0 && method_table[i].declared == 1) {
            return 1;
        }
    }
    return 0;
}

%}

%union {
    int ival;
    char cval;
    double dval;
    char* sval;
}

%token LEFT_BRACKET RIGHT_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS SEMICOLON COLON COMMA DOT
%token PLUS MINUS TIMES DIVIDE LESS GREATER ASSIGN AND OR EQUAL NOT_EQUAL
%token PUBLIC PRIVATE CLASS INT CHAR DOUBLE BOOLEAN STRING VOID
%token IF ELSE WHILE DO FOR SWITCH CASE DEFAULT BREAK TRUE FALSE PRINT RETURN NEW
%token IDENTIFIER INTEGER_LITERAL CHAR_LITERAL DOUBLE_LITERAL STRING_LITERAL CLASS_NAME

%type <sval> IDENTIFIER STRING_LITERAL CLASS_NAME
%type <ival> INTEGER_LITERAL
%type <cval> CHAR_LITERAL
%type <dval> DOUBLE_LITERAL

%%

program : class_declaration  
        | class_declaration program
        ;

class_declarations : /* empty */
                   | class_declaration class_declarations

class_declaration : PUBLIC CLASS CLASS_NAME LEFT_BRACKET variable_declarations method_declarations class_declarations RIGHT_BRACKET 
                  ;

variable_declarations : /* empty */
                      | variable_declarations variable_declaration
                      | variable_declarations new_class_member
                      ;

variable_declaration : modifier data_type variable_list SEMICOLON
                     ;

variable_list : IDENTIFIER { strcpy(symbol_table[symbol_count].name, $1);
                             symbol_table[symbol_count].declared = 1;
                             symbol_count++;
                           }
              | IDENTIFIER ASSIGN expression { strcpy(symbol_table[symbol_count].name, $1);
                             		       symbol_table[symbol_count].declared = 1;
                             		       symbol_count++;
                          		     }
              | variable_list COMMA IDENTIFIER { strcpy(symbol_table[symbol_count].name, $3);
                             		         symbol_table[symbol_count].declared = 1;
                             		         symbol_count++;
                          		       }
              | variable_list COMMA IDENTIFIER ASSIGN expression { strcpy(symbol_table[symbol_count].name, $3);
                             		                           symbol_table[symbol_count].declared = 1;
                             		                           symbol_count++;
                          		                         }
              ;

new_class_member : CLASS_NAME IDENTIFIER ASSIGN NEW CLASS_NAME LEFT_PARENTHESIS RIGHT_PARENTHESIS SEMICOLON { strcpy(symbol_table[symbol_count].name, $2);
                             		                           					      symbol_table[symbol_count].declared = 1;
                             		                           				              symbol_count++;
                          		                         					    }
		 ;

method_declarations : /* empty */
                    | method_declaration method_declarations
                    ;

method_declaration : modifier data_type IDENTIFIER LEFT_PARENTHESIS optional_parameter_list RIGHT_PARENTHESIS LEFT_BRACKET variable_declarations statements RIGHT_BRACKET { strcpy(method_table[method_count].name, $3);
                             		         														            method_table[method_count].declared = 1;
                             		         															    method_count++;
                          		       																  } 
                   | modifier VOID IDENTIFIER LEFT_PARENTHESIS optional_parameter_list RIGHT_PARENTHESIS LEFT_BRACKET variable_declarations statements RIGHT_BRACKET { strcpy(method_table[method_count].name, $3);
                             		         														       method_table[method_count].declared = 1;
                             		         														       method_count++;
                          		       															     }
                   ;


optional_parameter_list : /* empty */
                        | parameter_list
                        ;

parameter_list : data_type IDENTIFIER { strcpy(symbol_table[symbol_count].name, $2);
                             	        symbol_table[symbol_count].declared = 1;
                             	        symbol_count++
       			              }
               | data_type IDENTIFIER COMMA parameter_list { strcpy(symbol_table[symbol_count].name, $2);
                             	       			     symbol_table[symbol_count].declared = 1;
                             	       			     symbol_count++
       			             			   }	       
               ;

statements : /* empty */
           | statements statement
           ;

statement : assignment_statement
          | loop_statement
          | conditional_statement
          | print_statement
          | return_statement
          | break_statement
          ;

assignment_statement : IDENTIFIER ASSIGN expression SEMICOLON { if (!is_variable_declared($1)) {
                                                                    yyerror("Variable not declared");
                                                                }
                                                              }
                     | class_variable ASSIGN expression SEMICOLON
                     ;

loop_statement : DO LEFT_BRACKET statements RIGHT_BRACKET WHILE LEFT_PARENTHESIS conditions RIGHT_PARENTHESIS SEMICOLON 
               | FOR LEFT_PARENTHESIS assignment_statement SEMICOLON conditions SEMICOLON assignment_statement RIGHT_PARENTHESIS LEFT_BRACKET statements RIGHT_BRACKET 
               ;

conditional_statement : IF LEFT_PARENTHESIS conditions RIGHT_PARENTHESIS LEFT_BRACKET statements RIGHT_BRACKET 
                      | IF LEFT_PARENTHESIS conditions RIGHT_PARENTHESIS LEFT_BRACKET statements RIGHT_BRACKET ELSE LEFT_BRACKET statements RIGHT_BRACKET 
                      | SWITCH LEFT_PARENTHESIS IDENTIFIER RIGHT_PARENTHESIS LEFT_BRACKET case_statements RIGHT_BRACKET 
                      ;

case_statements : /* empty */
                | case_statements CASE literals COLON statements
                | case_statements DEFAULT COLON statements
                ;

print_statement : PRINT LEFT_PARENTHESIS STRING_LITERAL COMMA variables RIGHT_PARENTHESIS SEMICOLON 
                | PRINT LEFT_PARENTHESIS STRING_LITERAL RIGHT_PARENTHESIS SEMICOLON 
                ;

return_statement : RETURN expression SEMICOLON 
                 ;

break_statement : BREAK SEMICOLON 
                ;

conditions : condition
           | condition AND conditions
           | condition OR conditions
           ;

condition : expression LESS expression
          | expression GREATER expression
          | expression EQUAL expression
          | expression NOT_EQUAL expression
          ;

expression : term
           | expression PLUS term
           | expression MINUS term
           ;

term : factor
     | term TIMES factor
     | term DIVIDE factor
     ;

factor : IDENTIFIER { if (!is_variable_declared($1)) {
                          yyerror("Variable not declared");
                      }
                    }
       | class_item
       | literals
       | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS
       ;

variables : IDENTIFIER { if (!is_variable_declared($1)) {
                             yyerror("Variable not declared");
                         }
                       }
	  | class_variable
	  | variables COMMA IDENTIFIER { if (!is_variable_declared($3)) {
                                             yyerror("Variable not declared");
                                         }
                                       }
	  | variables COMMA class_variable
	  ;

literals : INTEGER_LITERAL
         | CHAR_LITERAL
         | DOUBLE_LITERAL
         | STRING_LITERAL
         | TRUE
         | FALSE
         ;

class_item : class_variable
           | class_method
           ;

class_method : IDENTIFIER DOT IDENTIFIER LEFT_PARENTHESIS RIGHT_PARENTHESIS { if (!is_method_declared($3)) {
                                             					yyerror("Method not declared");
                                         				      }
									      if (!is_variable_declared($1)) {
                                               					yyerror("Class not declared");
                                             				      }
                                       				            }
	     | IDENTIFIER DOT IDENTIFIER LEFT_PARENTHESIS variables RIGHT_PARENTHESIS { if (!is_method_declared($3)) {
                                               					            yyerror("Method not declared");
                                             				                }
			  						                if (!is_variable_declared($1)) {
                                               					          yyerror("Class not declared");
                                             				                }
										      }
               
	     ;

class_variable : IDENTIFIER DOT IDENTIFIER { if (!is_variable_declared($3)) {
                                               yyerror("Variable not declared");
                                             }
					     if (!is_variable_declared($1)) {
                                               yyerror("Class not declared");
                                             }
                                           }
	       ;

modifier : PUBLIC
         | PRIVATE
         | /* empty */
         ;

data_type : INT
          | CHAR
          | DOUBLE
          | BOOLEAN
          | STRING
          ;

%%

void yyerror(const char *s) {
    printf("Syntax error at line %d: %s\n", yylineno, s);
    yyerror_flag = 1;
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {

    printf("START\n");

    if (argc != 2) {
        printf("Usage: %s <file_name>\n", argv[0]);
        return 1;
    }
    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("Error opening file");
        return 1;
    }

    char line[1024];
    while (fgets(line, sizeof(line), fp) != NULL) {
        printf("%s", line);
    }
    printf("\n");
    fseek(fp, 0, SEEK_SET);

    yyin = fp;
    yyparse();
    fclose(fp);

    if (yyerror_flag == 0) {
        printf("Parsing completed successfully.\n");
    }

    return 0;
}
