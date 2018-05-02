%option noyywrap

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	
	int linecount = 1;
	FILE *logout;
	FILE *tokenout;
	
	char *upString(char *s){
		char *t = s;
		
		while(*s != '\0'){
			if(*s >= 'a' && *s <= 'z'){
				*s = *s - 32;			
			}
			s++;
		}
		
		return t;
	} 

%}
WHITESPACE [ \t\f\r\v]+ 
NEWLINE \n
LETTER [A-Za-z]
DIGIT [0-9]
KEYWORD "if"|"else"|"for"|"while"
%%
{KEYWORD}    {
				fprintf(logout,"<%s> token found in line no:%d\n",upString(yytext),linecount);
				fprintf(tokenout,"<%s>",upString(yytext));

			 }


{NEWLINE}      {
				linecount++;
			 }
WHITESPACE   {
				//do nothing
			 }
 

%%

int main(int argc,char *argv[]){
	FILE *input = fopen("input.txt","r");
	if(input == NULL){
		printf("Cannot open file");
	}
	tokenout = fopen("token.txt","w+");
	logout = fopen("log.txt","w+");
	
	yyin = input;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
}

