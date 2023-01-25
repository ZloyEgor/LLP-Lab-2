#define YYDEBUG 1

#include <stdio.h>
#include "parser.h"
#include "request_tree.h"
int yyparse();

int main() {
    int yydebug=1;
    yyparse();
    request_tree tree = get_request_tree();
    print_request_tree(tree);
    printf("Tree size: %zu bytes\n", get_tree_size(tree));
    return 0;
}
