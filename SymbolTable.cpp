#include <cstdio>
#include <string>
#include<iostream>
#include <cstdlib>
#include <vector>

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
            cout <<name << " pos " << pos << endl;
        }

        return (int)pos;
    }

public:
    //variables
    ScopeTable * parentScope;

    ScopeTable(int x = 10 , int id){
        n = x;
        this->id = id;
        scopeTable = new SymbolInfo*[n];
        for(int i=0; i<n; i++){
            scopeTable[i] = NULL;
        }

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

        int pos = hashFunction(name);
        SymbolInfo *cur = scopeTable[pos];
        if(cur == NULL)
            scopeTable[pos] = newItem;
        else{

            while(cur->next != NULL){
                if(cur->getName() == name){
                    return false;
                }
                //prev = cur;
                cur = cur->next;
            }
            cur->next = newItem;
        }
        cout << "<" << name << "," << type << "> inserted at "<<pos << endl;
        return true;

    }

    SymbolInfo * lookup(string name){
        SymbolInfo * cur = new SymbolInfo;


        int pos = hashFunction(name);
        cur = scopeTable[pos];
        while(cur!=NULL){
            if(cur->getName() == name)
                return cur;
            cur = cur->next;
        }
        return cur;

    }

    bool deleteItem(string name){
        SymbolInfo *prev,* cur ;


        int pos = hashFunction(name);
        cur = scopeTable[pos];

        prev = NULL;
        while(cur != NULL){
            if(cur->getName() == name){
                if(prev!=NULL)
                    prev->next = cur->next;
                else
                    scopeTable[pos] = cur->next;
                delete cur;
                return true;
            }
            prev = cur;
            cur = cur->next;

        }
        return false;
    }

    void print(){
        SymbolInfo *cur;
        cout << n << endl;
        for(int i=0;i<n;i++){
            printf("Bucket%d :",i);
            cur = scopeTable[i];
            while(cur!=NULL){
                cout << "<" << cur->getName() << "," << cur->getType() << "> ";
                cur = cur->next;
            }
            cout << endl;
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
    }

    void enterScope(){
        curId++;
        ScopeTable * newScope = new ScopeTable(bucketSize,curId);
        newScope -> parentScope = currentScope;
        currentScope = newScope;
    }

    void exitScope(){
        ScopeTable *prev = currentScope;
        currentScope = currentScope->parentScope;
        curId--;
        delete prev;

    }

    bool insert(string name, string type){
        if(currentScope->insert(name,type))
            return true;
        else return false;
    }

    bool remove(string name){
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
                return res;
            else cur = cur->parentScope;
        }
        return res;

    }

    void printCurrentScope(){
        currentScope->print();
    }
    void printAll(){
        ScopeTable * cur = currentScope;

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


int main(){
    freopen("in.txt","rw",stdin);
    int n,x;
    cin >> n;
    ScopeTable table(n);
    while(true){
        if(scanf("%d",&x) == EOF){
            freopen("/dev/tty","r",stdin);
        }
        if(x == 1){
            string name,t;
            cin >> name >> t;
            table.insert(name,t);
        }
        if(x == 2){
            string name;
            cin >> name;
            SymbolInfo * tmp = table.lookup(name);
            if(tmp != NULL)
                cout << tmp->getName() << "," <<tmp->getType() << endl;
            else
                cout << "Item was not found!!\n";
        }
        if(x == 3){
            string name;
            cin >> name;
            bool b = table.deleteItem(name);
            if(b)
                cout << "item deleted successfully\n";
            else
                cout << "Item was not found!!\n";
        }
        if(x == 4)
            table.print();
        if(x == 5)
            break;
    }
    return 0;
}
