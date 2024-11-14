// utility.h
#ifndef UTILITY_H
#define UTILITY_H
#include "scanner.h"

int expect_token(int *i, State expected_type, const char *error_message);
int is_comparison_operator(State type);
int is_valid_operand(State type);

#endif
