#include <cstdio>
#include <string>
#include <iostream>
#include <cstdlib>
#include <vector>
#include <fstream>
#include <utility>
//#include"y.tab.h"

extern FILE * log;
extern FILE * ferr;
using namespace std;

class FunctionInfo{

public:
    string retType;
    bool is_declared;
    vector < pair < string,string > > paramList;
    FunctionInfo(){}
    FunctionInfo(string retType,vector<pair<string ,string> > paramList,bool is_declared = false){
        this->retType = retType;
        this->paramList = paramList;
        this->is_declared = is_declared;
    }
    void print(){
        fprintf(log,"\nFunction Info:\n");
        fprintf(log,"Return Type:%s\n",retType.c_str());
        fprintf(log,"No Of Parameters:%d\n",paramList.size());
        fprintf(log,"Parameters:\n");
        for(int i=0;i<paramList.size();i++){
            pair<string,string> tmpPair = paramList.at(i);
            fprintf(log,"< %s , %s >\n",tmpPair.first.c_str(),tmpPair.second.c_str());
        }

    }
    bool isEquals(FunctionInfo *f){
        if(this->retType != f->retType)
            return false;
        vector<pair <string,string> > fparamList = f->paramList;
        if(paramList.size() != fparamList.size()){
            return false;
        }
        for(int i=0;i<paramList.size();i++){
            if(paramList.at(i).second != fparamList.at(i).second)
                return false;
            if(fparamList.at(i).first == "")
                continue;
            if(paramList.at(i).first != fparamList.at(i).first){
                return false;
            }
        }
        return true;
    }
};

class SymbolInfo
{
  private:
    string name;
    string type;
    int line;
    FunctionInfo * finfo;
    int arrSize;
    
  public:
    SymbolInfo *next;
    SymbolInfo() {
        name = "";
        type = "";
        finfo = NULL;
        arrSize = 0;
    }
    SymbolInfo(string name, string type, int line = 0)
    {
        this->name = name;
        this->type = type;
        this->line = line;
        finfo = NULL;
        arrSize = 0;
        //printf("hello");
    }
    void setName(string name)
    {
        this->name = name;
    }
    string getName()
    {
        return name;
    }
    void setType(string type)
    {
        this->type = type;
    }
    string getType()
    {
        return type;
    }
    void setLine(int line){this->line = line;}
    int getLine(){return line;}
    bool isFunc(){
        if(finfo == NULL)return false;
        else return true;
    }
    void setFinfo(FunctionInfo *finfo){this->finfo = finfo;}
    FunctionInfo * getfinfo(){return finfo;}

    void setArrSize(int arrSize){this->arrSize = arrSize;}
    int getArrSize(){return arrSize;}
};

class ScopeTable
{
  private:
    int n;
    SymbolInfo **scopeTable; //hashTable
    int id;

    int hashFunction(string name)
    {
        unsigned int pos = 0;

        for (int i = 0; i < name.length(); i++)
        {
            pos = (pos * 31 + name[i]) % n;
            //cout <<name << " pos " << pos << endl;
        }

        return (int)pos;
    }

  public:
    //variables
    ScopeTable *parentScope;

    ScopeTable(int id, int x = 10)
    {
        n = x;
        this->id = id;
        scopeTable = new SymbolInfo *[n];
        for (int i = 0; i < n; i++)
        {
            scopeTable[i] = NULL;
        }
        //printf("hello");
        fprintf(log,"ScopeTable with id %d  is created\n\n\n",id);
    }

    void setId(int id)
    {
        this->id = id;
    }

    int getId()
    {
        return id;
    }

    bool insert(string name, string type)
    {
        SymbolInfo *newItem = new SymbolInfo;
        newItem->setName(name);
        newItem->setType(type);
        newItem->next = NULL;

        int chainPos = 0;
        int pos = hashFunction(name);
        SymbolInfo *prev, *cur = scopeTable[pos];
        if (cur == NULL)
            scopeTable[pos] = newItem;
        else
        {
            prev = NULL;
            while (cur != NULL)
            {
                if (cur->getName() == name)
                {
                    //cout << "<" << name << "," << type << "> already exists\n";
                    return false;
                }
                chainPos++;
                //prev = cur;
                prev = cur;
                cur = cur->next;
            }
            prev->next = newItem;
        }
        fprintf(log, "<%s,%s> inserted at ScopeTable #%d at (%d,%d)\n", name.c_str(), type.c_str(), id, pos, chainPos);
        //cout << "<" << name << "," << type << "> inserted at ScopeTable#"<<id << " at ("<<pos << ","<<chainPos << ")\n";
        return true;
    }

    bool insert(SymbolInfo *newItem){
        newItem->next = NULL;
        int chainPos = 0;
        int pos = hashFunction(newItem->getName());
        string name  = newItem->getName();
        string type = newItem->getType();
        SymbolInfo *prev, *cur = scopeTable[pos];
        if (cur == NULL)
            scopeTable[pos] = newItem;
        else
        {
            prev = NULL;
            while (cur != NULL)
            {
                if (cur->getName() == name)
                {
                    fprintf(log," <%s,%s> already exists at ScopeTable #%d\n\n",name.c_str(),type.c_str(),id);
                    return false;
                }
                chainPos++;
                //prev = cur;
                prev = cur;
                cur = cur->next;
            }
            prev->next = newItem;
        }
        fprintf(log, "<%s,%s> inserted at ScopeTable #%d at (%d,%d)\n", name.c_str(), type.c_str(), id, pos, chainPos);
        //cout << "<" << name << "," << type << "> inserted at ScopeTable#"<<id << " at ("<<pos << ","<<chainPos << ")\n";
        if(newItem->isFunc())newItem->getfinfo()->print();
        return true;
    }


    SymbolInfo *lookup(string name)
    {
        SymbolInfo *cur;

        int chainPos = 0;
        int pos = hashFunction(name);
        cur = scopeTable[pos];
        while (cur != NULL)
        {
            if (cur->getName() == name)
            {
                //cout << "<" << name << "," << cur->getType() << "> found in ScopeTable#" << id << " at (" << pos << "," << chainPos << ")\n";
                return cur;
            }

            cur = cur->next;
        }

        //cout << "Item not found\n";

        return cur;
    }

    bool deleteItem(string name)
    {
        SymbolInfo *prev, *cur;
        lookup(name);

        int pos = hashFunction(name);
        cur = scopeTable[pos];
        int chainPos = 0;

        prev = NULL;
        while (cur != NULL)
        {
            if (cur->getName() == name)
            {
                if (prev != NULL)
                    prev->next = cur->next;
                else
                    scopeTable[pos] = cur->next;
                delete cur;
                //cout << "Deleted entry of ScopeTable#" << id << " at position (" << pos << "," << chainPos << ")\n";
                return true;
            }
            chainPos++;
            prev = cur;
            cur = cur->next;
        }
        return false;
    }

    void print()
    {
        SymbolInfo *cur;
        ////cout << "ScopeTable#"<<id << ":"<< endl;
        fprintf(log, "\nScopeTable # %d:\n", id);
        for (int i = 0; i < n; i++)
        {

            cur = scopeTable[i];
            if (cur != NULL)
            {
                fprintf(log, "%d --->  ", i);
                while (cur != NULL)
                {
                    ////cout << "<" << cur->getName() << "," << cur->getType() << "> ";
                    fprintf(log, "<%s,%s,%d> ", cur->getName().c_str(), cur->getType().c_str(),cur->getArrSize());
                    if(cur->isFunc()){
                        cur->getfinfo()->print();
                    }
                    cur = cur->next;
                }
                fprintf(log, "\n");
            }
        }
        fprintf(log,"\n");
    }

    ~ScopeTable()
    {
        SymbolInfo *cur, *tmp;
        for (int i = 0; i < n; i++)
        {
            cur = scopeTable[i];
            while (cur != NULL)
            {
                tmp = cur;
                cur = cur->next;
                delete cur;
            }
        }
        fprintf(log,"ScopeTable with id %d is deleted\n\n\n",id);
        delete[] scopeTable;
    }
};

class SymbolTable
{
  private:
    ScopeTable *currentScope;
    int curId;
    int bucketSize;

  public:
    SymbolTable(int n = 60)
    {
        currentScope = NULL;
        curId = 0;
        bucketSize = n;
        enterScope();
    }

    void enterScope()
    {
        curId++;
        ScopeTable *newScope = new ScopeTable(curId, bucketSize);
        newScope->parentScope = currentScope;
        currentScope = newScope;
    }

    void exitScope()
    {
        if (curId == 1)
            return;
        ScopeTable *prev = currentScope;
        currentScope = currentScope->parentScope;
        curId--;
        delete prev;
    }

    bool insert(string name, string type)
    {
        if (currentScope == NULL)
            return false;
        if (currentScope->insert(name, type))
            return true;
        else
            return false;
    }

    bool insert(SymbolInfo * s){
        if (currentScope == NULL)
            return false;
        if (currentScope->insert(s))
            return true;
        else
            return false;
    }

    bool remove(string name)
    {
        if (currentScope == NULL)
            return false;
        if (currentScope->deleteItem(name))
            return true;
        else
            return false;
    }
    SymbolInfo *lookup(string name)
    {
        ScopeTable *cur = currentScope;
        SymbolInfo *result = NULL;

        while (cur != NULL)
        {
            result = cur->lookup(name);
            if (result != NULL)
                return result;
            else
                cur = cur->parentScope;
        }
        return result;
    }

    void printCurrentScope()
    {
        if (currentScope != NULL)
            currentScope->print();
        else{}
            //cout << "No scope table created\n";
    }
    void printAll()
    {
        ScopeTable *cur = currentScope;
        if (cur == NULL)
            fprintf(log,"No Scope Table!!\n");
        while (cur != NULL)
        {
            cur->print();
            cur = cur->parentScope;
        }
    }
    ~SymbolTable()
    {
        ScopeTable *prev = NULL;
        while (currentScope != NULL)
        {
            prev = currentScope;
            currentScope = currentScope->parentScope;
            delete prev;
        }
    }
};

//int main(){
//    ifstream in("in.txt");
//    ofstream out("out.txt");
//    streambuf *inbuf = cin.rdbuf();
//    cin.rdbuf(in.rdbuf());
//    //cout.rdbuf(out.rdbuf());
//    int n,f = 1;
//    in >> n;
//    //cout << n;
//    SymbolTable st(n);
//    string cmd;
//    while(true){
//
//        if(cin.eof()){
//            cin.rdbuf(inbuf);
//            cout << "cin changed" << endl;
//            //break;
//        }
//        cin >> cmd;
//        cout << cmd << " ";
//        if(cmd == "S"){
//            cout << endl <<"\t";
//            st.enterScope();
//        }
//        if(cmd == "E"){
//            cout << endl << "\t";
//            st.exitScope();
//        }
//        if(cmd == "I"){
//            string name,type;
//            cin >> name >> type;
//            cout << name << " "<<type << endl << "\t";
//            st.insert(name,type);
//        }
//        if(cmd == "D"){
//            string name;
//            cin >> name;
//            cout << name << endl << "\t";
//            st.remove(name);
//        }
//        if(cmd == "L"){
//            string name;
//            cin >> name;
//            cout << name << endl << "\t";
//            st.lookup(name);
//        }
//        if(cmd == "P"){
//            string printType;
//            cin >> printType;
//            cout << printType << endl << "\t";
//            if(printType == "A"){
//                st.printAll();
//            }
//            else if(printType == "C"){
//                st.printCurrentScope();
//            }
//        }
//        if(cmd == "Q"){
//            cout << endl << "\t";
//            break;
//        }
//
//        //break;
//
//
//    }
//    return 0;
//}
