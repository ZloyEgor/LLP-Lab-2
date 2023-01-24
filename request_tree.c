//
// Created by Zloy Egor on 23.01.2023.
//

#include "request_tree.h"
#include <stdio.h>

static void print_schema(add_schema_struct schema) {
    printf("Add schema: %s\n", schema.schema_name);
    for (int i = 0; i < arraylist_size(schema.attribute_declarations); i++) {
        attribute_declaration *cur_attr = arraylist_get(schema.attribute_declarations, i);
        switch (cur_attr->type) {
            case ATTR_TYPE_INTEGER: {
                printf("%s: integer\n", cur_attr->attr_name);
                break;
            }
            case ATTR_TYPE_BOOLEAN: {
                printf("%s: boolean\n", cur_attr->attr_name);
                break;
            }
            case ATTR_TYPE_FLOAT: {
                printf("%s: float\n", cur_attr->attr_name);
                break;
            }
            case ATTR_TYPE_STRING: {
                printf("%s: string\n", cur_attr->attr_name);
                break;
            }
            case ATTR_TYPE_REFERENCE: {
                printf("%s: reference to %s", cur_attr->attr_name, cur_attr->schema_ref_name);
                break;
            }
        }
    }
}

static void print_node(add_node_struct node) {
    printf("Add node of schema: %s\n", node.schema_name);
    for (int i = 0; i < arraylist_size(node.attribute_values); ++i) {
        attr_value *cur_attr = arraylist_get(node.attribute_values, i);
        switch (cur_attr->type) {
            case ATTR_TYPE_INTEGER: {
                printf("%s: %d\n", cur_attr->attr_name, cur_attr->value.integer_value);
                break;
            }
            case ATTR_TYPE_BOOLEAN: {
                printf("%s: %s\n", cur_attr->attr_name, cur_attr->value.bool_value? "true" : "false");
                break;
            }
            case ATTR_TYPE_FLOAT: {
                printf("%s: %f\n", cur_attr->attr_name, cur_attr->value.float_value);
                break;
            }
            case ATTR_TYPE_STRING: {
                printf("%s: %s\n", cur_attr->attr_name, cur_attr->value.string_value);
                break;
            }
            case ATTR_TYPE_REFERENCE: {
                printf("%s: %d\n", cur_attr->attr_name, cur_attr->value.integer_value);
                break;
            }
        }
    }
}

void print_request_tree(request_tree tree) {
    switch (tree.type) {
        case REQUEST_OPEN: {
            printf("Open file: %s\n", tree.file_work.filename);
            break;
        }
        case REQUEST_CREATE: {
            printf("Create file: %s\n", tree.file_work.filename);
            break;
        }
        case REQUEST_CLOSE: {
            printf("Close file\n");
            break;
        }
        case REQUEST_ADD_SCHEMA: {
            print_schema(tree.add_schema);
            break;
        }
        case REQUEST_DELETE_SCHEMA: {
            printf("Delete schema: %s\n", tree.delete_schema.schema_name);
            break;
        }
        case REQUEST_ADD_NODE: {
            print_node(tree.add_node);
            break;
        }
        case REQUEST_SELECT: {
            //TODO
            break;
        }
        case UNDEFINED:
            printf("Empty tree");
            break;
    }
}