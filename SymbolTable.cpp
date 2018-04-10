#include <cstdio>
#include <string>

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




};


int main(){

    return 0;
}
