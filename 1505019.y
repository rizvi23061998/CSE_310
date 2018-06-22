%error-verbose
%nonassoc THEN
%nonassoc ELSE

%{

    #include <string>
	#include <iostream>
	#include <sstream>
	#include <cstdlib>
	#include <utility>
    #include "1505019_SymbolTable.h"
    #define YYSTYPE SymbolInfo*
	using namespace std;
    SymbolTable *table;	

    int yylex(void);
    int yyparse(void);
    extern FILE *yyin;
	FILE * log;
	FILE * ferr;
	int errors = 0;
    vector<pair<string,string> > paramList;
	vector <string> argTypes;
	string returnType = "";
	int retLine = 0;
	void yyerror(const char * s);
	

	vector<string> split(const string &str,char delim){
		stringstream ss(str);
		vector<string> tokens;
		string item;
		while(getline(ss,item,delim)){
			tokens.push_back(item);
		}
		return tokens;
	}

	void pushParams(){
		for(int i=0;i<paramList.size();i++){
			pair<string,string> item = paramList.at(i);
			SymbolInfo * newSI = new SymbolInfo(item.first,item.second);
			table->insert(newSI);
		}
		
	}
	

%}
%token IF FOR WHILE DO INT FLOAT VOID SWITCH DEFAULT BREAK CHAR DOUBLE CONTINUE RETURN CASE ELSE CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP RELOP INCOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON STRING DECOP ID PRINTLN

%%
start : program
		{
			fprintf(log,"At line no : %d start : program \n\n",($1)->getLine());
			fprintf(log,"%s\n\n",($1)->getName().c_str());			
		}
		;

program : program unit 
		{
			($$)->setLine(($2)->getLine());
			($$)->setName(($1)->getName() + "\n" + ($2)->getName());
			fprintf(log,"At line no : %d program : program unit \n\n",($$)->getLine());
			fprintf(log,"%s\n\n",($$)->getName().c_str());
		}
	| unit
		{
			fprintf(log,"At line no : %d program : unit \n\n",($1)->getLine());
			fprintf(log,"%s\n\n",($1)->getName().c_str());
		}
	;
	
unit : var_declaration 
		{
			fprintf(log,"At line no : %d unit : var_declaration\n\n",($1)->getLine());
			fprintf(log,"%s\n\n",($1)->getName().c_str());
			
		}
     | func_declaration 
	 	{
			fprintf(log,"At line no : %d unit : func_declaration\n\n",($1)->getLine());
			fprintf(log,"%s\n\n",($1)->getName().c_str());
		}
     | func_definition
	 	{
			fprintf(log,"At line no : %d unit : func_definition\n\n",($1)->getLine());
			fprintf(log,"%s\n\n",($1)->getName().c_str());
		}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
			{
				string pString = ($4)->getName();
				string retype = ($1)->getName();
				string idName = ($2)->getName();

				($$)->setName(($1)->getName() +" "+ ($2)->getName() + "(" + ($4)->getName() + ");");
				($$)->setLine(($1)->getLine());
				fprintf(log,"At line no : %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",($1)->getLine());
				fprintf(log,"%s\n\n",($$)->getName().c_str());

				SymbolInfo *newSI = table->lookup(idName);
				if(newSI == NULL){
					vector<string> ptmp = split(pString,',');
					vector<pair<string,string> > tmpList;
					for(int i=0;i<ptmp.size();i++){
						vector<string> var = split(ptmp.at(i),' ');
						if(var.size() < 2)
							var.push_back("");
						pair <string,string> newPair = make_pair(split(var.at(1),'[').at(0),var.at(0));
						tmpList.push_back(newPair);
					}

					FunctionInfo * finfo = new FunctionInfo(retype,tmpList,true);
					newSI = new SymbolInfo(idName,retype,($$)->getLine());
					newSI->setFinfo(finfo);
					table->insert(newSI);
				}
				else{
					// errors++;
					// fprintf(ferr,"At line no : %d,Error : Multiple declaration of the function %s\n\n",($1)->getLine(),idName.c_str());
					FunctionInfo * finfo = newSI->getfinfo();
					if(finfo->is_declared == true){
						errors++;
						fprintf(ferr,"At line no : %d, Error : %s is declared multiple times\n\n",($1)->getLine(),idName.c_str());
					}
					else{
						vector<string> ptmp = split(pString,',');
						vector<pair<string,string> > pList;
						for(int i = 0;i<ptmp.size();i++){
							vector<string> tmp = split(ptmp.at(i),' ');
							pList.push_back( make_pair(split(tmp.at(1),'[').at(0),tmp.at(0)) );
						}
						FunctionInfo * newfinfo = new FunctionInfo(retype,pList);
						if(finfo->isEquals(newfinfo) == false){
							fprintf(ferr,"At line no : %d, Error : Function %s , definition and declaration does not match\n\n",($1)->getLine(),idName.c_str());
							errors++;
						}
					}
				}
				paramList.resize(0);
			}
		| type_specifier ID LPAREN RPAREN SEMICOLON
			{
				string retype = ($1)->getName();
				string idName = ($2)->getName();
				vector<pair<string,string> > tmpList;

				($$)->setName(($1)->getName() +" "+ ($2)->getName() + "();");
				($$)->setLine(($1)->getLine());
				fprintf(log,"At line no : %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",($1)->getLine());
				fprintf(log,"%s\n\n",($$)->getName().c_str());
				
				SymbolInfo *newSI = table->lookup(idName);
				if(newSI == NULL){
					FunctionInfo * finfo = new FunctionInfo(retype,tmpList,true);
					newSI = new SymbolInfo(idName,retype,($$)->getLine());
					newSI->setFinfo(finfo);
					table->insert(newSI);
				}
				else{
					// errors++;
					// fprintf(ferr,"At line no : %d,Error : Multiple declaration of the function %s\n\n",($1)->getLine(),idName.c_str());
					FunctionInfo * finfo = newSI->getfinfo();
					if(finfo->is_declared == true){
						errors++;
						fprintf(ferr,"At line no : %d, Error : %s is declared multiple times\n\n",($1)->getLine(),idName.c_str());
					}
					else{
						vector<pair<string,string> > pList;
						pList.resize(0);
						FunctionInfo * newfinfo = new FunctionInfo(retype,pList);
						if(finfo->isEquals(newfinfo) == false){
							fprintf(ferr,"At line no : %d, Error : Function %s , definition and declaration does not match\n\n",($1)->getLine(),idName.c_str());
							errors++;
						}
					}
				}
				paramList.resize(0);
			}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
			{
				string pString = ($4)->getName();
				string retype = ($1)->getName();
				string idName = ($2)->getName();
				
				if(returnType != retype){
					
					errors++;
					fprintf(ferr,"At line no : %d , Error : Return Type does not match\n\n",retLine);
				
				}
				($$)->setName(($1)->getName()  + " " +($2)->getName() + "(" + ($4)->getName() + ")" + ($6)->getName());
				($$)->setLine(($6)->getLine());
		 		fprintf(log,"At line no : %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",($6)->getLine());
				fprintf(log,"%s\n\n",($$)->getName().c_str());

				SymbolInfo *newSI = table->lookup(idName);
				if( newSI == NULL){
					FunctionInfo * finfo = new FunctionInfo(retype,paramList);
					SymbolInfo * newSI = new SymbolInfo(idName,retype,($$)->getLine());
					newSI->setFinfo(finfo);
					table->insert(newSI);

				}
				else{
					if(newSI->getfinfo()->is_declared){
						FunctionInfo * finfo = new FunctionInfo(retype,paramList);
						if(finfo->isEquals(newSI->getfinfo())){
							newSI = new SymbolInfo(idName,retype,($$)->getLine());
							finfo->is_declared = false;
							newSI->setFinfo(finfo);
							table->remove(idName);
							table->insert(newSI);
						}
						else{
							fprintf(ferr,"At line no : %d, Error : Function %s , definition and declaration does not match\n\n",($1)->getLine(),idName.c_str());
							errors++;
						}
					}
					else{
						fprintf(ferr,"At line no : %d, Error : Multiple definition of the same function %s()\n\n",($1)->getLine(),newSI->getName().c_str());
						errors++;
					}

				}
				retLine = 0;
				returnType = "";
				paramList.resize(0);
			}	
		| type_specifier ID LPAREN RPAREN compound_statement
			{
				string retype = ($1)->getName();
				string idName = ($2)->getName();

				if(returnType != retype){					
					errors++;
					fprintf(ferr,"At line no : %d , Error : Return Type does not match\n\n",retLine);
				
				}
				($$)->setName(($1)->getName()  + " " +($2)->getName() + "(" + ")" + ($5)->getName());
				($$)->setLine(($5)->getLine());
		 		fprintf(log,"At line no : %d func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",($$)->getLine());
				fprintf(log,"%s\n\n",($$)->getName().c_str());

				SymbolInfo *newSI = table->lookup(idName);
				if( newSI == NULL){
					FunctionInfo * finfo = new FunctionInfo(retype,paramList);
					SymbolInfo * newSI = new SymbolInfo(idName,retype,($$)->getLine());
					newSI->setFinfo(finfo);
					table->insert(newSI);

				}
				else{
					if(newSI->getfinfo()->is_declared){
						FunctionInfo * finfo = new FunctionInfo(retype,paramList);
						if(finfo->isEquals(newSI->getfinfo())){
							newSI = new SymbolInfo(idName,retype,($$)->getLine());
							finfo->is_declared = false;
							newSI->setFinfo(finfo);
							table->remove(idName);
							table->insert(newSI);
						}
						else{
							fprintf(ferr,"At line no : %d, Error : Function %s , definition and declaration does not match\n\n",($1)->getLine(),idName.c_str());
							errors++;
						}
					}
					else{
						fprintf(ferr,"At line no : %d, Error : Multiple definition of the same function %s()\n\n",($1)->getLine(),newSI->getName().c_str());
						errors++;
					}

				}
				returnType = "";
				retLine = 0;
				paramList.resize(0);
			}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		 {
			string type = ($3)->getName();
			string name = ($4)->getName();
			name = split(name,'[').at(0);
			
			($$)->setName(($1)->getName()  + "," + ($3)->getName() + " " +  ($4)->getName());
			($$)->setLine(($1)->getLine());
			fprintf(log,"At line no : %d parameter_list  : parameter_list COMMA type_specifier ID\n\n",($$)->getLine());
			fprintf(log,"%s\n\n\n",($$)->getName().c_str());

			paramList.push_back(make_pair(name,type));
		 }
		| parameter_list COMMA type_specifier
		 {
			($$)->setName(($1)->getName()  + "," + ($3)->getName());
			($$)->setLine(($1)->getLine());
			fprintf(log,"At line no : %d parameter_list  : parameter_list COMMA type_specifier\n\n",($$)->getLine());
			fprintf(log,"%s\n\n\n",($$)->getName().c_str());
		 }
 		| type_specifier ID
		 {
			string name = ($2)->getName();
			string type = ($1)->getName();

			($$)->setName(($1)->getName()  + " " + ($2)->getName());
			($$)->setLine(($1)->getLine());
			fprintf(log,"At line no : %d parameter_list  : type_specifier ID\n\n",($$)->getLine());
			fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			
			paramList.push_back(make_pair(name,type));
			
		 }
		| type_specifier
		 {
			fprintf(log,"At line no : %d parameter_list  : type_specifier\n\n",($1)->getLine());
			fprintf(log,"%s\n\n\n",($1)->getName().c_str());
		 }
 		;
 		
compound_statement : LCURL {table->enterScope();pushParams();} statements RCURL
				{
					($$)->setName("\n{\n" + ($3)->getName() +"\n}\n");
					($$)->setLine(($4)->getLine());
					fprintf(log,"At line no : %d compound_statement : LCURL statements RCURL\n\n",($$)->getLine());
					fprintf(log,"%s\n\n\n",($$)->getName().c_str());
					table->printAll();
					table->exitScope();
					
				}

 		    | LCURL {table->enterScope();pushParams();} RCURL 
			 {
				 ($$)->setName(($1)->getName() + ($3)->getName());
				 ($$)->setLine(($1)->getLine());
				 fprintf(log,"At line no : %d compound_statement : LCURL RCURL\n\n",($1)->getLine());
				 fprintf(log,"{}\n\n\n");
				 table->printAll();
				 table->exitScope();
				 
			 }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
			{
				string type = ($1)->getName();
				($$)->setName(($1)->getName() + " "+ ($2)->getName() + ";");
				($$)->setLine(($1)->getLine());

				fprintf(log,"At line no : %d var_declaration : type_specifier declaration_list SEMICOLON\n\n",($1)->getLine());
				fprintf(log,"%s\n\n",($$)->getName().c_str());
				vector<string> varList = split(($2)->getName(),',');
				for(int i = 0;i<varList.size();i++){
					vector <string> var = split(varList.at(i),'[');
					string varName;
					varName = var.at(0);
					
					SymbolInfo * tmp = new SymbolInfo(varName,type,($$)->getLine());

					if(var.size()>1){
						string ssize = split(var.at(1),']').at(0);
						int asize = atoi(ssize.c_str());
						//cout << asize;
						tmp->setArrSize(asize);
					}
					
					if(table->insert(tmp) == false){
						errors++;
						fprintf(ferr,"At line no : %d, Error : %s is redefined\n\n",($1)->getLine(),varName.c_str());
						
					}
				}
				
			}
 		 ;
 		 
type_specifier	: INT	{
							fprintf(log,"At line no : %d type_specifier : INT\n\n",($1)->getLine());
							fprintf(log,"%s\n\n",($1)->getName().c_str());
							//printf("%s %d\n",($1)->getName().c_str(),($1)->getLine());
						}
 		| FLOAT 		{
							fprintf(log,"At line no : %d type_specifier : FLOAT\n\n",($1)->getLine());
							fprintf(log,"%s\n\n",($1)->getName().c_str());
							//printf("%s %d\n",($1)->getName().c_str(),($1)->getLine());
						}
 		| VOID          {
							fprintf(log,"At line no : %d type_specifier : VOID\n\n",($1)->getLine());
							fprintf(log,"%s\n\n",($1)->getName().c_str());
							//printf("%s %d\n",($1)->getName().c_str(),($1)->getLine());
						}
 		;
 		
declaration_list : declaration_list COMMA ID 
			{
				($$)->setName(($1)->getName() + "," + ($3)->getName());
				fprintf(log,"At line no : %d declaration_list : declaration_list COMMA ID\n\n",($1)->getLine());
				fprintf(log,"%s\n\n",($$)->getName().c_str());
			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		   				{
							($$)->setName(($1)->getName() + "," + ($3)->getName() + "[" + ($5)->getName() + "]");
							($$)->setLine(($1)->getLine());
							fprintf(log,"At line no : %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",($1)->getLine());
							fprintf(log,"%s\n\n",($$)->getName().c_str());
						}
 		  | ID        	{
							fprintf(log,"At line no : %d declaration_list : ID\n\n",($1)->getLine());
							fprintf(log,"%s\n\n",($1)->getName().c_str());
							//printf("%s %d\n",($1)->getName().c_str(),($1)->getLine());
					  	}	
 		  | ID LTHIRD CONST_INT RTHIRD
		   				{
							($$)->setName(($1)->getName() + "[" + ($3)->getName() + "]");
							($$)->setLine(($1)->getLine());
							fprintf(log,"At line no : %d declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",($1)->getLine());
							fprintf(log,"%s\n\n",($$)->getName().c_str());
						}
 		  ;
 		  
statements : statement
			{
				fprintf(log,"At line no : %d statements : statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
	   | statements statement
	   		{
				($$)->setName(($1)->getName() + "\n" + ($2)->getName());
				($$)->setLine(($2)->getLine());
				fprintf(log,"At line no : %d statements : statements statement\n\n",($2)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	   ;
	   
statement : var_declaration
			{
				fprintf(log,"At line no : %d statement : var_declaration\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
	  | expression_statement
	  		{
				fprintf(log,"At line no : %d statement : expression_statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
	  | compound_statement
	  		{
				fprintf(log,"At line no : %d statement : compound_statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  		{
				($$)->setName(($1)->getName() + "(" + ($3)->getName() + ($4)->getName() + ($5)->getName() + ")   " + ($7)->getName());
				($$)->setLine(($1)->getLine());
				fprintf(log,"At line no : %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	  | IF LPAREN expression RPAREN statement %prec THEN
	  		{
				($$)->setName(($1)->getName() + "(" + ($3)->getName() + ")" + ($5)->getName());
				($$)->setLine(($5)->getLine());
				fprintf(log,"At line no : %d statement : IF LPAREN expression RPAREN statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	  | IF LPAREN expression RPAREN statement ELSE statement
	  		{	
				($$)->setName(($1)->getName() + "(" + ($3)->getName() + ")" + ($5)->getName() + "\nelse" + ($7)->getName());
				($$)->setLine(($7)->getLine());
				fprintf(log,"At line no : %d statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	  | WHILE LPAREN expression RPAREN statement
	  		{
				($$)->setName(($1)->getName() + "(" + ($3)->getName() + ")  " + ($5)->getName());
				($$)->setLine(($1)->getLine());
				fprintf(log,"At line no : %d statement : WHILE LPAREN expression RPAREN statement\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  		{
				($$)->setName(($1)->getName() + "(" + ($3)->getName() + ");" );
				($$)->setLine(($1)->getLine());
				fprintf(log,"At line no : %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	  | RETURN expression SEMICOLON
	  		{
				string expType = ($2)->getType();
				returnType = expType;
				retLine = ($1)->getLine();
				
				($$)->setName(($1)->getName() + + " " +  ($2)->getName() + ";" );
				($$)->setLine(($1)->getLine());
				fprintf(log,"At line no : %d statement : RETURN expression SEMICOLON\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	  ;
	  
expression_statement : SEMICOLON
				{
					fprintf(log,"At line no : %d expression_statement : SEMICOLON\n\n",($1)->getLine());
					fprintf(log,"%s\n\n\n",($1)->getName().c_str());
				}			
			| expression SEMICOLON 
				{
					($$)->setName(($1)->getName() +  ";");
					($$)->setLine(($1)->getLine());
					fprintf(log,"At line no : %d expression_statement : expression SEMICOLON\n\n",($1)->getLine());
					fprintf(log,"%s\n\n\n",($$)->getName().c_str());
				}
			;
	  
variable : ID 	
		{
			fprintf(log,"At line no : %d variable : ID\n\n",($1)->getLine());
			fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			string varName = ($1)->getName();
			SymbolInfo *var = table->lookup(varName);
			if(var!=NULL ){
				if(var->getArrSize()>0){
					errors++;
					fprintf(ferr,"At line no : %d, Error : Trying to use array like normal variable\n\n",($1)->getLine());
				}
			}
		}	
	 | ID LTHIRD expression RTHIRD 
	 	{
			 string varName = ($1)->getName();
			 string expType = ($3)->getType();
			($$)->setName(($1)->getName() + "[" + ($3)->getName() + "]");
			($$)->setLine(($1)->getLine());
			
			fprintf(log,"At line no : %d variable : ID LTHIRD expression RTHIRD\n\n",($1)->getLine());
			fprintf(log,"%s\n\n\n",($$)->getName().c_str());

			SymbolInfo * var = table->lookup(varName);
			if(var == NULL){
				errors++;
				fprintf(ferr,"At line no : %d, Error : Variable %s was not declared in this scope\n\n",($1)->getLine(),varName.c_str());

			}
			else if(var->getArrSize() == 0){
				errors++;
				fprintf(ferr,"At line no : %d , Error : variable %s is not an array\n\n",($1)->getLine(),varName.c_str());
			}
			else if(expType != "int"){
				errors++;
				fprintf(ferr,"At line no : %d , Error : Array index is not integer type.\n\n",($1)->getLine());
			}
			else{
				//do nothing
			}
		}
	 ;
	 
 expression : logic_expression	
			{
				fprintf(log,"At line no : %d  expression : logic_expression	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
				if(($1)->getType() == "void"){
					errors++;
					fprintf(ferr,"At line no : %d , Error : void type function can not be called as a part of an expression\n\n",($1)->getLine());
				}
			}
			
	   | variable ASSIGNOP logic_expression
			{
				string varName = split(($1)->getName(),'[').at(0);
				($$)->setName(($1)->getName() + "=" + ($3)->getName());
				($$)->setLine(($1)->getLine());
				($$)->setType("int");

				fprintf(log,"At line no : %d  expression : variable ASSIGNOP logic_expression	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
				SymbolInfo * var = table->lookup(varName);
				if(var == NULL){
					errors++;
					fprintf(ferr,"At line no : %d , Error : Variable %s is not declared in this scope.\n\n",($1)->getLine(),varName.c_str());
				}
				else{
					string varType = var->getType();

					string logType = ($3)->getType();
					if(logType == "void"){
						errors++;
						fprintf(ferr,"At line no : %d , Error : void type function can not be called as a part of an expression\n\n",($1)->getLine());
					}
					else if(varType == "int" && logType == "float"){
						errors++;
						fprintf(ferr,"At line no : %d, Warning : Float type variable is assigned to integer type variable.Data loss can occur\n\n",($1)->getLine());
					}
					else if(varType != logType){
						errors++;
						fprintf(ferr,"At line no : %d , Error : Type Mismatch \n\n",($1)->getLine());
					}
				}
			}
	   ;
			
logic_expression : rel_expression 	
			{
				fprintf(log,"At line no : %d  logic_expression : rel_expression	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
		 | rel_expression LOGICOP rel_expression 
		 	{
				($$)->setName(($1)->getName() + ($2)->getName() + ($3)->getName());
				($$)->setLine(($1)->getLine());
				($$)->setType("int");

				fprintf(log,"At line no : %d  logic_expression : rel_expression LOGICOP rel_expression\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}	
		 ;
			
rel_expression	: simple_expression 
			{
				fprintf(log,"At line no : %d  rel_expression : simple_expression	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
		| simple_expression RELOP simple_expression	
			{
				($$)->setName(($1)->getName() + ($2)->getName() + ($3)->getName());
				($$)->setLine(($1)->getLine());
				($$)->setType("int");

				fprintf(log,"At line no : %d  rel_expression : simple_expression RELOP simple_expression	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
		;
				
simple_expression : term 
			{
				fprintf(log,"At line no : %d  simple_expression : term	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
		  | simple_expression ADDOP term 
		  	{
				($$)->setName(($1)->getName() + ($2)->getName() + ($3)->getName());
				($$)->setLine(($1)->getLine());

				string sType = ($1)->getType();
				string tType = ($3)->getType();

				if(sType=="float" || tType == "float"){
					($$)->setType("float");
				}
				else{
					($$)->setType("int");
				}

				fprintf(log,"At line no : %d  simple_expression : simple_expression ADDOP term	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
		  ;
					
term :	unary_expression
			{
				fprintf(log,"At line no : %d  term : unary_expression\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
     |  term MULOP unary_expression
	 		{
				string op = ($2)->getName(); 
				string tType = ($1)->getType();
				string uType = ($3)->getType();

				($$)->setName(($1)->getName() + ($2)->getName() + ($3)->getName());
				($$)->setLine(($1)->getLine());
				
				
				if(op == "%"){
					if(tType != "int" || uType != "int"){
						errors++;
						fprintf(ferr,"At line no : %d , Error : Non-integer operand of modulus(%) operator\n\n",($1)->getLine());
					}
					($$)->setType("int");
				}

				else if(tType=="float" || uType == "float"){
					($$)->setType("float");
				}
				else{
					($$)->setType("int");
				}

				fprintf(log,"At line no : %d  term : term MULOP unary_expression \n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
     ;

unary_expression : ADDOP unary_expression
			{
				($$)->setName(($1)->getName() + ($2)->getName());
				($$)->setLine(($1)->getLine());
				($$)->setType(($1)->getType());

				fprintf(log,"At line no : %d  unary_expression : ADDOP unary_expression	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
		 | NOT unary_expression 
		 	{
				($$)->setName(($1)->getName() + ($2)->getName());
				($$)->setLine(($1)->getLine());
				($$)->setType("int");

				fprintf(log,"At line no : %d  unary_expression : NOT unary_expression \n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
		 | factor
		 	{
				fprintf(log,"At line no : %d  unary_expression : factor	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());

				($$)->setType(($1)->getType());
			} 
		 ;
	
factor	: variable 
			{
				string varName = split(($1)->getName(),'[').at(0);
				fprintf(log,"At line no : %d  factor : variable	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());

				SymbolInfo * var = table->lookup(varName);
				if(var == NULL) {
					errors++;
					fprintf(ferr,"At line no : %d ,Error : Variable %s is not declared in this scope.\n\n",($1)->getLine(),varName.c_str());

				}
				else{
					($$)->setType(var->getType());
				}
				
			}
	| ID LPAREN argument_list RPAREN
			{
				string idName = ($1)->getName();
				string args = ($3)->getName();
				($$)->setName(($1)->getName() +"(" +  ($3)->getName() + ")");
				($$)->setLine(($1)->getLine());
				SymbolInfo * func = table->lookup(idName);
				if(func == NULL){
					errors++;
					fprintf(ferr,"At line no : %d, Error : Function %s is not declared in this scope\n\n",($1)->getLine(),idName.c_str());
					($$)->setType("void");
				}
				else{

					($$)->setType(func->getType());
					
					FunctionInfo * finfo = func->getfinfo();
					vector<pair<string,string> > pList = finfo->paramList;
					if(finfo->is_declared == true){
						errors++;
						fprintf(ferr,"At line no : %d, Error : Function %s is defined but not declared in this scope\n\n",($1)->getLine(),idName.c_str());
					}
					else if(argTypes.size() != pList.size() ){
						errors++;
						fprintf(ferr,"At line no : %d , Error : Argument number does not match parameter number\n\n",($1)->getLine());
						fprintf(log,"size no\n");
						
					}
				
					else{
						for(int i=0;i<argTypes.size();i++){
							string pType = pList.at(i).second;
							string argName = split(args,',').at(i);
							if(pType != argTypes.at(i)){
								errors++;
								fprintf(ferr,"At line no : %d , Error : Argument %s does not match type with the parameter\n\n",($1)->getLine(),argName.c_str());
								break;
							}
						}
					}
					
				}
				argTypes.resize(0);
				fprintf(log,"At line no : %d  factor : ID LPAREN argument_list RPAREN	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	| LPAREN expression RPAREN
			{
				($$)->setName("(" + ($2)->getName() + ")");
				($$)->setLine(($1)->getLine());
				($$)->setType(($2)->getType());

				fprintf(log,"At line no : %d  factor : LPAREN expression RPAREN	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());

			}
	| CONST_INT
			{
				fprintf(log,"At line no : %d  factor : CONST_INT \n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());

				($$) = ($1);
				($$)->setType("int");
			} 
	| CONST_FLOAT
			{
				fprintf(log,"At line no : %d  factor : CONST_FLOAT	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());

				($$) = ($1);
				($$)->setType("float");
			}
	| variable INCOP
			{
				string varName = split(($1)->getName(),'[').at(0);
				($$)->setName(($1)->getName() + ($2)->getName());
				($$)->setLine(($1)->getLine());
				
				SymbolInfo * var = table->lookup(varName);
				if(var == NULL){
					errors++;
					fprintf(ferr,"At line no : %d , Error : Variable %s is not declared in this scope.\n\n",($1)->getLine(),varName.c_str());
				}
				else{
					if(var->getType() != "int"){
						errors++;
						fprintf(ferr,"At line no : %d , Error : %s type variable can not be incremented\n\n",($1)->getLine(),var->getType().c_str());
					}
					else{
						($$)->setType(var->getType());
					}
					
				}
				
				fprintf(log,"At line no : %d  factor : variable INCOP \n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			} 
	| variable DECOP
			{
				string varName = split(($1)->getName(),'[').at(0);
				($$)->setName(($1)->getName() + ($2)->getName());
				($$)->setLine(($1)->getLine());

				SymbolInfo * var = table->lookup(varName);
				if(var == NULL){
					errors++;
					fprintf(ferr,"At line no : %d , Error : Variable %s is not declared in this scope.\n\n",($1)->getLine(),varName.c_str());
				}
				else{
					if(var->getType() != "int"){
						errors++;
						fprintf(ferr,"At line no : %d , Error : %s type variable can not be decremented\n\n",($1)->getLine(),var->getType().c_str());
					}
					else{
						($$)->setType(var->getType());
					}
					
				}
				fprintf(log,"At line no : %d  factor : variable DECOP\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	;
	
argument_list : arguments
			{
				fprintf(log,"At line no : %d  argument_list : arguments	\n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
			  |
			  {
				  ($$)->setName("");
				  ($$)->setType("void");
				
			  }
			  ;
	
arguments : arguments COMMA logic_expression
			{
				string aType = ($3)->getType();
				($$)->setName(($1)->getName() + "," + ($3)->getName());
				($$)->setLine(($1)->getLine());

				argTypes.push_back(aType);
				fprintf(log,"At line no : %d  arguments : arguments COMMA logic_expression \n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($$)->getName().c_str());
			}
	      | logic_expression
		  	{
				argTypes.push_back(($1)->getType());
				fprintf(log,"At line no : %d  arguments : logic_expression \n\n",($1)->getLine());
				fprintf(log,"%s\n\n\n",($1)->getName().c_str());
			}
	      ;
 

%%


int main(int argc, char **argv){
	
    FILE *fp;
    if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	//printf("Opened successfully\n");
	log = fopen("log.txt","w+");
	fclose(log);
	log = fopen("log.txt","a");
	ferr = fopen("err.txt","w+");
	fclose(ferr);
	fopen("err.txt","a");
	//printf("Log opened successfully\n");
	table = new SymbolTable;
    yyin = fp;

    yyparse();
	
	fprintf(ferr,"\nTotal Errors : %d\n",errors);
	fclose(ferr);
	fclose(fp);
	fclose(log);
    return 0;
}