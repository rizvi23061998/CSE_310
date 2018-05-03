#include <cstdio>
#include <string>
#include <iostream>
#include <cstdlib>
#include <vector>
#include <fstream>

using namespace std;

class SymbolInfo{
private:
    string name;
    string type;
public:
    SymbolInfo *next;

    void setName(string name){
        this->name = name;
    }
    string getName(){
        return name;
    }
    void setType(string type){
        this->type = type;
    }
    string getType(){
        return type;
    }
};

class ScopeTable{
private:
    int n;
    SymbolInfo **scopeTable;//hashTable
    int id;

    int hashFunction(string name){
        unsigned int pos = 0;

        for(int i=0;i<name.length(); i++){
            pos  = (pos *31 + name[i]) % n;
            //cout <<name << " pos " << pos << endl;
        }

        return (int)pos;
    }

public:
    //variables
    ScopeTable * parentScope;

    ScopeTable(int id , int x = 10){
        n = x;
        this->id = id;
        scopeTable = new SymbolInfo*[n];
        for(int i=0; i<n; i++){
            scopeTable[i] = NULL;
        }
        cout << "ScopeTable with id "<< id << " is created\n";
    }

    void setId(int id){
        this -> id = id;
    }

    int getId(){
        return id;
    }

    bool insert(string name,string type){
        SymbolInfo * newItem = new SymbolInfo;
        newItem->setName(name);
        newItem->setType(type);
        newItem->next = NULL;

        int chainPos = 0;
        int pos = hashFunction(name);
        SymbolInfo *prev,*cur = scopeTable[pos];
        if(cur == NULL)
            scopeTable[pos] = newItem;
        else{
            prev = NULL;
            while(cur != NULL){
                if(cur->getName() == name){
                    cout <<"<" << name << "," <<type<<"> already exists\n";
                    return false;
                }
                chainPos++;
                //prev = cur;
                prev = cur;
                cur = cur->next;
            }
            prev->next = newItem;
        }
        cout << "<" << name << "," << type << "> inserted at ScopeTable#"<<id << " at ("<<pos << ","<<chainPos << ")\n";
        return true;

    }

    SymbolInfo * lookup(string name){
        SymbolInfo * cur = new SymbolInfo;

        int chainPos = 0;
        int pos = hashFunction(name);
        cur = scopeTable[pos];
        while(cur!=NULL){
            if(cur->getName() == name){
                cout << "<" << name << "," << cur->getType() << "> found in ScopeTable#"<<id << " at ("<<pos << ","<<chainPos << ")\n";
                return cur;
            }

            cur = cur->next;
        }

        //cout << "Item not found\n";

        return cur;

    }

    bool deleteItem(string name){
        SymbolInfo *prev,* cur ;
        lookup(name);

        int pos = hashFunction(name);
        cur = scopeTable[pos];
        int chainPos = 0;

        prev = NULL;
        while(cur != NULL){
            if(cur->getName() == name){
                if(prev!=NULL)
                    prev->next = cur->next;
                else
                    scopeTable[pos] = cur->next;
                delete cur;
                cout << "Deleted entry of ScopeTable#" << id << " at position ("<<pos << "," << chainPos << ")\n";
                return true;
            }
            chainPos++;
            prev = cur;
            cur = cur->next;
        }
        return false;
    }

    void print(){
        SymbolInfo *cur;
        cout << "ScopeTable#"<<id << ":"<< endl;
        for(int i=0;i<n;i++){

            cur = scopeTable[i];
            if(cur!=NULL){
                printf("%d --->  ",i);
                while(cur!=NULL){
                        cout << "<" << cur->getName() << "," << cur->getType() << "> ";
                        cur = cur->next;
                    }
                    cout << endl;
                }
        }

    }

    ~ScopeTable(){
        SymbolInfo * cur , * tmp;
        for(int i=0;i<n;i++){
            cur = scopeTable[i];
            while(cur!= NULL){
                tmp = cur;
                cur = cur->next;
                delete cur;
            }
        }
        cout << "ScopeTable with id "<< id << " is deleted\n";
        delete []scopeTable;
    }



};

class SymbolTable{
private:
    ScopeTable * currentScope;
    int curId;
    int bucketSize;
public:
    SymbolTable(int n = 10){
        currentScope = NULL;
        curId = 0 ;
        bucketSize = n;
        enterScope();
    }

    void enterScope(){
        curId++;
        ScopeTable * newScope = new ScopeTable(curId,bucketSize);
        newScope -> parentScope = currentScope;
        currentScope = newScope;
    }

    void exitScope(){
        if(curId == 1)
            return;
        ScopeTable *prev = currentScope;
        currentScope = currentScope->parentScope;
        curId--;
        delete prev;

    }

    bool insert(string name, string type){
        if(currentScope == NULL)
            return false;
        if(currentScope->insert(name,type))
            return true;
        else return false;
    }

    bool remove(string name){
        if(currentScope == NULL )
            return false;
        if(currentScope->deleteItem(name))
            return true;
        else return false;
    }
    SymbolInfo * lookup(string name){
        ScopeTable * cur = currentScope;
        SymbolInfo * result = NULL;

        while(cur!=NULL){
            result = cur->lookup(name);
            if(result != NULL)
                return result;
            else cur = cur->parentScope;
        }
        return result;

    }

    void printCurrentScope(){
        if(currentScope != NULL)
            currentScope->print();
        else
            cout << "No scope table created\n";
    }
    void printAll(){
        ScopeTable * cur = currentScope;
        if(cur == NULL)
            cout << "No Scope Table!!\n";
        while (cur!=NULL){
            cur->print();
            cur = cur->parentScope;
        }

    }
    ~SymbolTable(){
        ScopeTable *prev = NULL;
        while(currentScope != NULL){
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
