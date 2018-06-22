%option noyywrap
%option yylineno

%x COMMENT
%x CHAR_ERR

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	#include "1505019_SymbolTable.h"
	
	int linecount = 1;
	int comLine ;
	int errcnt = 0;
	char comment[1000];
	extern FILE * log;
	//FILE *logout = log;
	FILE *tokenout;
	extern SymbolTable *table;
	extern YYSTYPE yylval;
	
	void yyerror(const char *s)
    {
        //write your code
		fprintf(log,"At line no:%d , %s at '%s'\n",linecount,s,yytext);
    }
	
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
	char * stringProcessor(char *s){
		int l = strlen(s);
		char *t = (char *)malloc(sizeof(char)*l);
		int i,j;
		for(i = 1,j=0;i<l;i++,j++){

		    if(s[i] == '\\'){

		        if(s[i+1] == 'n'){
		            t[j] = '\n';
		        }
		        else if(s[i+1] == 'a'){
		            t[j] = '\a';
		        }
		        else if(s[i+1] == 'b'){t[j] = '\b';}
		        else if(s[i+1] == 't'){t[j] = '\t';}
		        else if(s[i+1] == 'v'){t[j] = '\v';}
		        else if(s[i+1] == 'r'){t[j] = '\r';}
		        else if(s[i+1] == 'f'){t[j] = '\f';}
		        else if(s[i+1] == '0'){t[j] = '\0';}
		        else if(s[i+1] == '"'){t[j] = '"';}
		        else if(s[i+1] == '\n'){linecount++;j--;}
				else if(s[i+1]=='"'){t[j] = '"';}
		        else{}
		        i++;
		    }
		    else{
		        t[j] = s[i];
		    }
		    //printf("%c",t[j]);
		}
		t[j-1]='\0';
		return t;

	}

	
	 

%}

WHITESPACE [ \t\f\r\v]+ 
NEWLINE \n
LETTER [A-Za-z]
DIGIT [0-9]
KEYWORD "if"|"for"|"while"|"do"|"int"|"float"|"void"|"switch"|"default"|"break"|"char"|"double"|"continue"|"return"|"case"|"else"
CHAR_LITERAL "'.'"|"'\\\\'"|"'\\a'"|"'\\f'"|"'\\r'"|"'\\b'"|"'\\v'"|"'\\0'"|"'\\''"|"'\\n'"|"'\\t'" 
CHAR_LIT [\']([^'\\\n\t]|(\\[aftrbvn0\'\\]))[\']
BITOP "&"|"|"|">>"|"<<"|"^"
ID [A-Za-z_][A-Za-z_0-9]*
STRING [\"]([^"\n]|\\.|(\\\n))*[\"]
SINGLE_COMMENT ("//")[^\n]*((\\\n)[^\n]*)*[\n<<EOF>>]
UNTERM_STRING [\"]([^"\n]|[\\.]|(\\\n))*[\n<<EOF>>]
EXP_ERR ({DIGIT}*\.?{DIGIT}+?|{DIGIT}+\.?)(E{DIGIT}*(\.)+{DIGIT}+)
%%

{NEWLINE}    {
				linecount++;
			 }
{WHITESPACE} {
				//do nothing
			 }

"if" 	{SymbolInfo *s = new SymbolInfo("if","KEYWORD",linecount);yylval = (YYSTYPE)s;return IF;}
"for" 	{SymbolInfo *s = new SymbolInfo("for","KEYWORD",linecount);yylval = (YYSTYPE)s;return FOR;}
"while" 	{SymbolInfo *s = new SymbolInfo("while","KEYWORD",linecount);yylval = (YYSTYPE)s;return WHILE;}
"do" 	{SymbolInfo *s = new SymbolInfo("do","KEYWORD",linecount);yylval = (YYSTYPE)s;return DO;}
"int" 	{SymbolInfo *s = new SymbolInfo("int","KEYWORD",linecount);yylval = (YYSTYPE)s;return INT;}
"float" 	{SymbolInfo *s = new SymbolInfo("float","KEYWORD",linecount);yylval = (YYSTYPE)s;return FLOAT;}
"void" 	{SymbolInfo *s = new SymbolInfo("void","KEYWORD",linecount);yylval = (YYSTYPE)s;return VOID;}
"switch" 	{SymbolInfo *s = new SymbolInfo("switch","KEYWORD",linecount);yylval = (YYSTYPE)s;return SWITCH;}
"default" 	{SymbolInfo *s = new SymbolInfo("default","KEYWORD",linecount);yylval = (YYSTYPE)s;return DEFAULT;}
"break" 	{SymbolInfo *s = new SymbolInfo("break","KEYWORD",linecount);yylval = (YYSTYPE)s;return BREAK;}
"char" 	{SymbolInfo *s = new SymbolInfo("char","KEYWORD",linecount);yylval = (YYSTYPE)s;return CHAR;}
"double" 	{SymbolInfo *s = new SymbolInfo("double","KEYWORD",linecount);yylval = (YYSTYPE)s;return DOUBLE;}
"continue" 	{SymbolInfo *s = new SymbolInfo("continue","KEYWORD",linecount);yylval = (YYSTYPE)s;return CONTINUE;}
"return" 	{SymbolInfo *s = new SymbolInfo("return","KEYWORD",linecount);yylval = (YYSTYPE)s;return RETURN;}
"case" 	{SymbolInfo *s = new SymbolInfo("case","KEYWORD",linecount);yylval = (YYSTYPE)s;return CASE;}
"else" 	{SymbolInfo *s = new SymbolInfo("else","KEYWORD",linecount);yylval = (YYSTYPE)s;return ELSE;}

{DIGIT}+     {
				SymbolInfo *s = new SymbolInfo(yytext,"CONST_INT",linecount);		 
				yylval = (YYSTYPE)s;
				return CONST_INT;
			 }

({DIGIT}*\.?{DIGIT}+?|{DIGIT}+\.?)(E[-+]?{DIGIT}+)? {
				SymbolInfo *s = new SymbolInfo(yytext,"CONST_FLOAT",linecount);		 
				yylval = (YYSTYPE)s;
				return CONST_FLOAT;
			}
{CHAR_LIT}  {
					char str[2];
				 	str[0] = trim(yytext);					
					str[1] = '\0';
					SymbolInfo *s = new SymbolInfo(yytext,"CONST_CHAR",linecount);		 
					yylval = (YYSTYPE)s;
					return CONST_INT;
					
			}

[-+]           {
						SymbolInfo *s = new SymbolInfo(yytext,"ADDOP",linecount);		 
						yylval = (YYSTYPE)s;
						return ADDOP;
				}
"*"|"/"|"%"          {
						SymbolInfo *s = new SymbolInfo(yytext,"MULOP",linecount);		 
						yylval = (YYSTYPE)s;
						return MULOP;

					}
"++"      		{
					SymbolInfo *s = new SymbolInfo(yytext,"INCOP",linecount);		 
					yylval = (YYSTYPE)s;
					return INCOP;
				}

"--"            {
					SymbolInfo *s = new SymbolInfo(yytext,"DECOP",linecount);		 
					yylval = (YYSTYPE)s;
					return DECOP;
				}				

"<"|"<="|">"|">="|"=="|"!=" {
								SymbolInfo *s = new SymbolInfo(yytext,"RELOP",linecount);		 
								yylval = (YYSTYPE)s;
								return RELOP;
							}
"="               {
						SymbolInfo *s = new SymbolInfo(yytext,"ASSIGNOP",linecount);		 
						yylval = (YYSTYPE)s;
						return ASSIGNOP;

				   }   
"&&"|"||"         {
						SymbolInfo *s = new SymbolInfo(yytext,"LOGICOP",linecount);		 
						yylval = (YYSTYPE)s;
						return LOGICOP;
				  }
{BITOP}           {
						SymbolInfo *s = new SymbolInfo(yytext,"BITOP",linecount);		 
						yylval = (YYSTYPE)s;
						return BITOP;
			   	  }
"!"				 {
						SymbolInfo *s = new SymbolInfo(yytext,"NOT",linecount);		 
						yylval = (YYSTYPE)s;
						return NOT;
				 }
"("			    {
						SymbolInfo *s = new SymbolInfo(yytext,"LPAREN",linecount);		 
						yylval = (YYSTYPE)s;
						return LPAREN;
				}
")"             {
					SymbolInfo *s = new SymbolInfo(yytext,"RPAREN",linecount);		 
					yylval = (YYSTYPE)s;
					return RPAREN;
				}
"{"             {
					SymbolInfo *s = new SymbolInfo(yytext,"LCURL",linecount);		 
					yylval = (YYSTYPE)s;
					return LCURL;
				}
"}"             {
					SymbolInfo *s = new SymbolInfo(yytext,"RCURL",linecount);		 
					yylval = (YYSTYPE)s;
					return RCURL;
				}
"["             {
					SymbolInfo *s = new SymbolInfo(yytext,"LTHIRD",linecount);		 
					yylval = (YYSTYPE)s;
					return LTHIRD;

				}
"]"             {
					SymbolInfo *s = new SymbolInfo(yytext,"RTHIRD",linecount);		 
					yylval = (YYSTYPE)s;
					return RTHIRD;
				}
","             {
					SymbolInfo *s = new SymbolInfo(yytext,"COMMA",linecount);		 
					yylval = (YYSTYPE)s;
					return COMMA;

				} 
";"             {
					SymbolInfo *s = new SymbolInfo(yytext,"SEMICOLON",linecount);		 
					//yylval = (YYSTYPE)s;
					return SEMICOLON;

				}
{ID}			{
					SymbolInfo *s= table->lookup(yytext);
					
										
					s= new SymbolInfo(yytext, "ID",linecount);
					
					yylval = (YYSTYPE)s;
								
					return ID;
				}
{STRING}        {
					int tmp = linecount;
					char *str = stringProcessor(yytext);
					SymbolInfo *s = new SymbolInfo(str,"STRING",linecount);		 
					yylval = (YYSTYPE)s;
					return STRING;		
				}
"/*"            {
					comLine = linecount;
					strcpy(comment,"");
					BEGIN(COMMENT);
				}
<COMMENT>"*/"    {
					fprintf(log,"\nLine No:%d,Token <COMMENT> Lexeme %s found\n",comLine,comment);			
					BEGIN(INITIAL);	
			     }


<COMMENT>([^*]|\n)+|. {
						//fprintf(log,"\nLine No:%d,Token <COMMENT> Lexeme %s found\n",linecount,yytext);			
						strcat(comment,yytext);
						for(int i=0;i<strlen(yytext);i++){
							if(yytext[i] == '\n')linecount++;
						}
					  }
<COMMENT><<EOF>>      {
						errcnt++;
						fprintf(log,"\n Error at Line %d: Unterminated comment %s\n",comLine,comment);
						BEGIN(INITIAL);
					  }

{SINGLE_COMMENT}     {
						fprintf(log,"\nLine No:%d,Token <COMMENT> Lexeme %s found\n",linecount,yytext);
						for(int i=0;i<strlen(yytext);i++){
							if(yytext[i] == '\n')linecount++;
						}
					 }
{DIGIT}*\.({DIGIT}*(\.)+{DIGIT}*)* 		{
											errcnt++;
											fprintf(log,"\n Error at Line %d: Too many decimal points %s\n",linecount,yytext);
									 	}
{EXP_ERR}                               {
											errcnt++;
											fprintf(log,"\n Error at Line %d: Ill formed number %s\n",linecount,yytext);
										}
{DIGIT}+[A-Za-z_]+[A-Za-z0-9]*    {
									errcnt++;
								  	fprintf(log,"\n Error at line %d: Invalid prefix on ID or invalid suffix on Number %s\n",linecount,yytext);
								  }

\'..+\'               {
					    errcnt++;
						fprintf(log,"\n Error at line %d: Multi character constant error %s\n",linecount,yytext);

					   }
(\'\\\')|(\'[^\']*[{WHITESPACE}\n]) {
								errcnt++;
								fprintf(log,"\n Error at line %d: Unterminated character %s\n",linecount,yytext);
								for(int i=0;i<strlen(yytext);i++){
									if(yytext[i] == '\n')linecount++;
								}	
							  }

\'\'                          {
								 errcnt++;
								 fprintf(log,"\n Error at line %d: Empty character constant error %s\n",linecount,yytext);	
							  }
{UNTERM_STRING}               {
								 errcnt++;
								 fprintf(log,"\n Error at line %d: Unterminated string %s\n",linecount,yytext);
								 for(int i=0;i<strlen(yytext);i++){
								 	if(yytext[i] == '\n')linecount++;
								 }	
								 
							   }
	    												
.                              {
								 errcnt++;
								 fprintf(log,"\n Error at line %d: Unrecognized character %s\n",linecount,yytext);	
					   		   }									

%%

/*
int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *input = fopen("input.txt","r");
	if(input == NULL){
		printf("Cannot open file");
		return 0;
	}
	tokenout = fopen("1505019_token.txt","w+");
	logout = fopen("1505019_log.txt","w+");
	
	yyin = input;
	yylex();
	fprintf(logout,"Total lines: %d\n",linecount-1);
	fprintf(logout,"Total errors: %d\n",errcnt);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
}

*/