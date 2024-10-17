%{
#include <stdio.h>
#include <stdlib.h>

int yywrap() { return 1; }

// Define all states
typedef enum { COMMAND, INTEGER, LEXICAL_ERROR, NEW_LINE, OPERATOR, PARAMETER, PRINT, SETTING, START } State;
// START is always the initial state
State current_state = START;

// Return a string representation of each state
const char* state_name(State state) {
    static const char *names[] = { "COMMAND", "INTEGER", "LEXICAL_ERROR", "NEW_LINE", "OPERATOR", "PARAMETER", "PRINT", "SETTING", "START" };
    return names[state];
}

// Map state transitions based on token type and current state
void print_transition(State token_type, const char* token_value) {
    // Whether the current transition is valid according to our state transition diagram
    int valid = 0;
    // Check for valid transitions from the current state to the next state based on token type
    if ((current_state == START || current_state == NEW_LINE) && (token_type == COMMAND || token_type == PRINT)) {
        // START or NEW_LINE must be followed by a COMMAND or PRINT
        valid = 1;
    }
    else if (current_state == COMMAND && (token_type == PARAMETER || token_type == SETTING)) {
        // COMMAND must be followed by a PARAMETER or SETTING
        valid = 1;
    }
    else if (current_state == PARAMETER && (token_type == NEW_LINE || token_type == OPERATOR || token_type == SETTING)) {
        // PARAMETER must be followed by NEW_LINE or SETTING
        valid = 1;
    }
    else if (current_state == OPERATOR && (token_type == INTEGER || token_type == PARAMETER)) {
        // OPERATOR must be followed by INTEGER or PARAMETER
        valid = 1;
    }
    else if (current_state == INTEGER && (token_type == INTEGER || token_type == NEW_LINE || token_type == OPERATOR)) {
        // INTEGER must followed by INTEGER, NEW_LINE, or OPERATOR
        valid = 1;
    }
    else if (current_state == SETTING && (token_type == INTEGER || token_type == NEW_LINE || token_type == PARAMETER)) {
        // SETTING must be followed by INTEGER, NEW_LINE, or PARAMETER
        valid = 1;
    }
    else if (current_state == PRINT && token_type == NEW_LINE) {
        // PRINT must be followed by NEW_LINE
        valid = 1;
    }
    // Process the transition based on whether it's valid or not and print the appropriate message as well as revise the current state
    if (valid) {
        printf("VALID transition from %s to %s with token: <%s, %s>\n", state_name(current_state), state_name(token_type), state_name(token_type), token_value);
        if      (token_type == COMMAND)   current_state = COMMAND;
        else if (token_type == INTEGER)   current_state = INTEGER;
        else if (token_type == NEW_LINE)  current_state = NEW_LINE;
        else if (token_type == OPERATOR)  current_state = OPERATOR;
        else if (token_type == PARAMETER) current_state = PARAMETER;
        else if (token_type == PRINT)     current_state = PRINT;
        else if (token_type == SETTING)   current_state = SETTING;
    } else {
        printf("INVALID transition from %s with token: <%s, %s>\n", state_name(current_state), state_name(token_type), token_value);
        current_state = LEXICAL_ERROR;
    }
}
%}

/* Define the patterns for tokens and their corresponding transitions in our state machine */
%%

"CREATE"|"SET"                                { print_transition(COMMAND, yytext); }       // COMMAND tokens
"PRINT"                                       { print_transition(PRINT, yytext); }         // PRINT token
"FAST"|"HIGH"|"LOW"|"MEDIUM"|"SLOW"|"STRONG"  { print_transition(PARAMETER, yytext); }     // PARAMETER tokens
"INFILL"|"LAYER_HEIGHT"|"SPEED"               { print_transition(SETTING, yytext); }       // SETTING tokens
[0-9]+                                        { print_transition(INTEGER, yytext); }       // INTEGER tokens
\n                                            { print_transition(NEW_LINE, "\\n"); }       // NEW_LINE token
"+"|"-"|"*"|"÷"                               { print_transition(OPERATOR, yytext); }      // OPERATOR tokens
[ \t\r]+                                      { /* Ignore whitespace */ }                  // Skip whitespace
[a-zA-Z]+|.                                   { print_transition(LEXICAL_ERROR, yytext); } // The rest are errors

%%

int main(int argc, char **argv) {
    if (argc > 1 && !(yyin = fopen(argv[1], "r"))) {
        perror("Error opening file");
        return 1;
    }
    yylex(); // Start scanning and processing tokens
    return 0;
}
