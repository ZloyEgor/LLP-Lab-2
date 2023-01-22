#define YYDEBUG 1

#include <stdio.h>
#include "parser.h"
#include "y.tab.h"
int yyparse();

int main() {
    int yydebug=1;
    yyparse();
    return 0;
}
