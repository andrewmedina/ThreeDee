#include "scanner.h"
#include <stdio.h>
#include <string.h>
#include "gcode.h"

Symbol symbol_table[100];
int symbol_count = 0;

// Helper function to do math based on the given operator
int do_math(int current_value, const char *operator, int operand)
{
    switch (operator[0])
    {
    case '+':
        return current_value + operand;
    case '-':
        return current_value - operand;
    case '*':
        return current_value * operand;
    case '/':
        if (operand == 0)
        {
            fprintf(stderr, "Error: Division by zero\n");
            exit(EXIT_FAILURE);
        }
        return current_value / operand;
    default:
        fprintf(stderr, "Error: Unsupported operator '%s'\n", operator);
        exit(EXIT_FAILURE);
    }
}

// Helper function to evaluate comparison operators
int evaluate_condition(int left, const char *operator, int right)
{
    switch (operator[0])
    {
    case '>':
        return operator[1] == '=' ? left >= right : left > right;
    case '<':
        return operator[1] == '=' ? left <= right : left < right;
    case '=': // This assumes that the following character is also '='
        return left == right;
    case '!': // This assumes that the following character is '='
        return left != right;
    default:
        fprintf(stderr, "Error: Unsupported operator '%s'\n", operator);
        return 0;
    }
}

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

// Helper function to get or create a symbol
Symbol *get_symbol(const char *identifier)
{
    for (int i = 0; i < symbol_count; i++)
    {
        if (strcmp(symbol_table[i].identifier, identifier) == 0)
        {
            return &symbol_table[i];
        }
    }

    // Add a new symbol if not found
    Symbol *new_symbol = &symbol_table[symbol_count++];
    strncpy(new_symbol->identifier, identifier, sizeof(new_symbol->identifier) - 1);
    new_symbol->value = 0; // Default value
    return new_symbol;
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

// Helper function to map parameters to numerical values
int map_initial_value(const char *value)
{
    if (strcmp(value, "HIGH") == 0)
        return 10;
    else if (strcmp(value, "MEDIUM") == 0)
        return 5;
    else if (strcmp(value, "LOW") == 0)
        return 1;
    fprintf(stderr, "Error: Unsupported initialization value '%s'\n", value);
    exit(EXIT_FAILURE);
}

// Helper function to initialize variables with set values and output relevant Gcode
void initialize_variable(const char *var_name, const char *value)
{
    Symbol *symbol = get_symbol(var_name);
    symbol->value = map_initial_value(value);
    printf("G92 %s%d ; Initialize %s to %s (%d)\n", var_name, symbol->value, var_name, value, symbol->value);
}
