%option noyywrap
%x COMMENT
%x CHAR_ERR

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "SymbolTable.h"
	
	int linecount = 1;
	int comLine ;
	int errcnt = 0;
	char comment[1000];
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
CHAR_LIT [\']([^'\\]|(\\[aftrbvn0\'\\]))[\']
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

{KEYWORD}    {
				fprintf(logout,"\nLine no:%d,Token <%s> found\n",linecount,upString(yytext));
				fprintf(tokenout,"<%s> ",upString(yytext));

			 }
{DIGIT}+     {
				fprintf(logout,"\nLine No:%d,Token <CONST_INT> Lexeme %s found\n",linecount,yytext);			
				fprintf(tokenout,"<CONST_INT, %s> ",yytext);	
				st.insert(yytext,"CONST_INT");
				st.printAll();		 
			 }

({DIGIT}*\.?{DIGIT}+?|{DIGIT}+\.?)(E[-+]?{DIGIT}+)? {
				fprintf(logout,"\nLine No:%d,Token <CONST_FLOAT> Lexeme %s found\n",linecount,yytext);			
				fprintf(tokenout,"<CONST_FLOAT, %s> ",yytext);	
				st.insert(yytext,"CONST_FLOAT");
				st.printAll();
			}
{CHAR_LIT}  {
					char str[2];
				 	fprintf(logout,"\nLine No:%d,Token <CONST_CHAR> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<CONST_CHAR, %c> ",trim(yytext));	
					str[0] = trim(yytext);					
					str[1] = '\0';
					st.insert(str,"CONST_CHAR");
					st.printAll();			

			   }
[-+]           {
					fprintf(logout,"\nLine No:%d,Token <ADDOP> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<ADDOP, %s> ",yytext);
				}
"*"|"/"|"%"          {
					fprintf(logout,"\nLine No:%d,Token <MULOP> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<MULOP, %s> ",yytext);

				}
"++"|"--"      {
					fprintf(logout,"\nLine No:%d,Token <INCOP> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<INCOP, %s> ",yytext);

				}

"<"|"<="|">"|">="|"=="|"!=" {
								fprintf(logout,"\nLine No:%d,Token <RELOP> Lexeme %s found\n",linecount,yytext);			
								fprintf(tokenout,"<RELOP, %s> ",yytext);

							}
"="               {
						fprintf(logout,"\nLine No:%d,Token <ASSIGNOP> Lexeme %s found\n",linecount,yytext);			
						fprintf(tokenout,"<ASSIGNOP, %s> ",yytext);

				   }   
"&&"|"||"         {
					fprintf(logout,"\nLine No:%d,Token <LOGICOP> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<LOGICOP, %s> ",yytext);
				  }
{BITOP}           {
					fprintf(logout,"\nLine No:%d,Token <BITOP> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<BITOP, %s> ",yytext);
			   	  }
"!"				 {
					fprintf(logout,"\nLine No:%d,Token <NOT> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<NOT, %s> ",yytext);
				 
				 }
"("				{
					fprintf(logout,"\nLine No:%d,Token <LPAREN> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<LPAREN, %s> ",yytext);
				}
")"             {
					fprintf(logout,"\nLine No:%d,Token <RPAREN> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<RPAREN, %s> ",yytext);
				}
"{"             {
					fprintf(logout,"\nLine No:%d,Token <LCURL> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<LCURL, %s> ",yytext);
				}
"}"             {
					fprintf(logout,"\nLine No:%d,Token <RCURL> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<RCURL, %s> ",yytext);

				}
"["             {
					fprintf(logout,"\nLine No:%d,Token <LTHIRD> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<LTHIRD, %s> ",yytext);

				}
"]"             {
					fprintf(logout,"\nLine No:%d,Token <RTHIRD> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<RTHIRD, %s> ",yytext);

				}
","             {
					fprintf(logout,"\nLine No:%d,Token <COMMA> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<COMMA, %s> ",yytext);


				} 
";"             {
					fprintf(logout,"\nLine No:%d,Token <SEMICOLON> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<SEMICOLON, %s> ",yytext);

				}
{ID}			{
					fprintf(logout,"\nLine No:%d,Token <ID> Lexeme %s found\n",linecount,yytext);			
					fprintf(tokenout,"<ID, %s> ",yytext);
					st.insert(yytext,"ID");
					st.printAll();
				}
{STRING}        {
					int tmp = linecount;
					char *s = stringProcessor(yytext);
					fprintf(logout,"\nLine No:%d,Token <STRING> Lexeme %s found\n",tmp,yytext);			
					fprintf(tokenout,"<STRING, %s> ",s);		
				}
"/*"            {
					comLine = linecount;
					strcpy(comment,"");
					BEGIN(COMMENT);
				}
<COMMENT>"*/"    {
					fprintf(logout,"\nLine No:%d,Token <COMMENT> Lexeme %s found\n",comLine,comment);			
					BEGIN(INITIAL);	
			     }


<COMMENT>([^*]|\n)+|. {
						//fprintf(logout,"\nLine No:%d,Token <COMMENT> Lexeme %s found\n",linecount,yytext);			
						strcat(comment,yytext);
						for(int i=0;i<strlen(yytext);i++){
							if(yytext[i] == '\n')linecount++;
						}
					  }
<COMMENT><<EOF>>      {
						errcnt++;
						fprintf(logout,"\n Error at Line %d: Unterminated comment %s\n",comLine,comment);
						BEGIN(INITIAL);
					  }

{SINGLE_COMMENT}     {
						fprintf(logout,"\nLine No:%d,Token <COMMENT> Lexeme %s found\n",linecount,yytext);
						for(int i=0;i<strlen(yytext);i++){
							if(yytext[i] == '\n')linecount++;
						}
					 }
{DIGIT}*\.({DIGIT}*(\.)+{DIGIT}*)* 		{
											errcnt++;
											fprintf(logout,"\n Error at Line %d: Too many decimal points %s\n",linecount,yytext);
									 	}
{EXP_ERR}                               {
											errcnt++;
											fprintf(logout,"\n Error at Line %d: Ill formed number %s\n",linecount,yytext);
										}
{DIGIT}+[A-Za-z_]+[A-Za-z0-9]*    {
									errcnt++;
								  	fprintf(logout,"\n Error at line %d: Invalid prefix on ID or invalid suffix on Number %s\n",linecount,yytext);
								  }

\'..+\'               {
					    errcnt++;
						fprintf(logout,"\n Error at line %d: Multi character constant error %s\n",linecount,yytext);

					   }
(\'\\\')|(\'[^\']*[{WHITESPACE}\n]) {
								errcnt++;
								fprintf(logout,"\n Error at line %d: Unterminated character %s\n",linecount,yytext);
								for(int i=0;i<strlen(yytext);i++){
									if(yytext[i] == '\n')linecount++;
								}	
							  }

\'\'                          {
								 errcnt++;
								 fprintf(logout,"\n Error at line %d: Empty character constant error %s\n",linecount,yytext);	
							  }
{UNTERM_STRING}               {
								 errcnt++;
								 fprintf(logout,"\n Error at line %d: Unterminated string %s\n",linecount,yytext);
								 for(int i=0;i<strlen(yytext);i++){
								 	if(yytext[i] == '\n')linecount++;
								 }	
								 
							   }
	    												
.                              {
								 errcnt++;
								 fprintf(logout,"\n Error at line %d: Unrecognized character %s\n",linecount,yytext);	
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
	fprintf(logout,"Total lines: %d\n",linecount-1);
	fprintf(logout,"Total errors: %d\n",errcnt);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
}

