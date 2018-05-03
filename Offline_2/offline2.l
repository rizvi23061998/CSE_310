%option noyywrap

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "SymbolTable.h"
	
	int linecount = 1;
	FILE *logout;
	FILE *tokenout;
	SymbolTable st(70);

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
	
	char trim(char *s){
		if(s[1] == '\\'){
		    switch(s[2]){
		    case '\'':
		        return '\'';
		        break;
		    case '\\':
		        return '\\';
		        break;
		    case 'n':
		        return '\n';
		        break;
		    case 't':
		        return '\t';
		        break;
		    case 'a':
		        return '\a';
		    case 'f':
		        return '\f';
		        break;
		    case 'r':
		        return '\r';
		        break;
		    case 'b':
		        return '\b';
		        break;
		    case 'v':
		        return '\v';
		        break;
		    case '0':
		        return '\0';
		    }

		}
		return s[1];

	}

	
	 

%}
WHITESPACE [ \t\f\r\v]+ 
NEWLINE \n
LETTER [A-Za-z]
DIGIT [0-9]
KEYWORD "if"|"n"|"for"|"while"|"do"|"int"|"float"|"void"|"switch"|"default"|"break"|"char"|"double"|"continue"|"return"|"case"
CHAR_LITERAL "'.'"|"'\\\\'"|"'\\a'"|"'\\f'"|"'\\r'"|"'\\b'"|"'\\v'"|"'\\0'"|"'\\''"|"'\\n'"|"'\\t'" 
%%

{NEWLINE}    {
				linecount++;
			 }
WHITESPACE   {
				//do nothing
			 }

{KEYWORD}    {
				fprintf(logout,"<%s> token found in line no:%d\n",upString(yytext),linecount);
				fprintf(tokenout,"<%s>",upString(yytext));

			 }
{DIGIT}+     {
				fprintf(logout,"\nLine No:%d,Token <CONST_INT> Lexeme %s found\n",linecount,yytext);			
				fprintf(tokenout,"<CONST_INT,%s>",yytext);	
				st.insert(yytext,"CONST_INT");
				st.printAll();		 
			 }

({DIGIT}*\.?{DIGIT}+?|{DIGIT}+\.?)(E[-+]?{DIGIT}+)? {
				fprintf(logout,"\nLine No:%d,Token <CONST_FLOAT> Lexeme %s found\n",linecount,yytext);			
				fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);	
				st.insert(yytext,"CONST_FLOAT");
				st.printAll();
			}
{CHAR_LITERAL}  {
					char str[2];
				 	fprintf(logout,"\nLine No:%d,Token <CONST_CHAR> Lexeme %c found\n",linecount,trim(yytext));			
					fprintf(tokenout,"<CONST_CHAR,%c>",trim(yytext));	
					str[0] = trim(yytext);					
					str[1] = '\0';
					st.insert(str,"CONST_CHAR");
					st.printAll();			

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

