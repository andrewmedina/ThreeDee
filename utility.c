#include "scanner.h"
#include <stdio.h>
#include <string.h>

// Helper function to expect and consume a token of a specific type
int expect_token(int *i, State expected_type, const char *error_message)
{
    if (tokens[*i].type != expected_type)
    {
        fprintf(stderr, "Syntax error: %s\n", error_message);
        return 0;
    }
    (*i)++; // Consume the token
    return 1;
}

// Helper function to check if a token type is a comparison operator
int is_comparison_operator(State type)
{
    return type == LESS_THAN || type == GREATER_THAN ||
           type == LESS_EQUAL || type == GREATER_EQUAL ||
           type == EQUAL || type == NOT_EQUAL;
}

// Helper function to check if a token type is a valid operand
int is_valid_operand(State type)
{
    return type == IDENTIFIER || type == INTEGER || type == PARAMETER;
}
