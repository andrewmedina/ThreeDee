# ThreeDee Scanner README
Teammate: Drew Marten Medina (amm2478)

## Lexical Grammar
The scanner for the 3D printing language, ThreeDee, recognizes the following States:
- START
  - This indicates the beginning of any file
  - It can be followed by a COMMAND or PRINT
- COMMAND
  - This indicates an action like "CREATE" or "SET" and must come first (exception is PRINT)
  - It can be followed by a PARAMETER or SETTING
- PARAMETER
  - This indicates an intensity like "STRONG" or "LOW"
  - It can be followed by NEW_LINE or SETTING
- NEW_LINE
  - This indicates the end of that line's command and the line can be read fully
  - It can be followed by COMMAND or PRINT
- SETTING
  - This indicates an attribute like "INFILL" or "LAYER_HEIGHT"
  - It can be followed by INTEGER, or NEW_LINE, or PARAMETER
- INTEGER
  - This indicates a number
  - It can be followed by INTEGER, NEW_LINE, or OPERATOR
- OPERATOR
  - This indicates a mathematical operation like addition or multiplication
  - It can be followed by INTEGER or PARAMETER
- PRINT
  - This indicates a standalone command that (in the final code) will return all specs
  - It can be followed by a NEW_LINE
- LEXICAL_ERROR
  - This is thrown whenever unexpected keywords are encountered

## Usage
1. Install Flex (`brew install Flex`) and GCC (`brew install gcc`).
2. Run `chmod +x run_scanner.sh` to make the scanner executable.
3. Execute the scanner script with a `.ddd` file as the argument, e.g.:
   ```
   ./run_scanner.sh test_1.ddd
   ```

## TEST OUTPUTS
Five test case files were created in `.ddd` (ThreeDee) format and the following are their inputs and expected outputs:

### `test_1.ddd`
Input:
```
CREATE STRONG INFILL 50
SET SPEED HIGH
PRINT
```
Output:
```
VALID transition from START to COMMAND with token: <COMMAND, CREATE>
VALID transition from COMMAND to PARAMETER with token: <PARAMETER, STRONG>
VALID transition from PARAMETER to SETTING with token: <SETTING, INFILL>
VALID transition from SETTING to INTEGER with token: <INTEGER, 50>
VALID transition from INTEGER to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to COMMAND with token: <COMMAND, SET>
VALID transition from COMMAND to SETTING with token: <SETTING, SPEED>
VALID transition from SETTING to PARAMETER with token: <PARAMETER, HIGH>
VALID transition from PARAMETER to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to PRINT with token: <PRINT, PRINT>
```

### `test_2.ddd`
Input:
```
SET INFILL LOW + 10
PRINT
```
Output:
```
VALID transition from START to COMMAND with token: <COMMAND, SET>
VALID transition from COMMAND to SETTING with token: <SETTING, INFILL>
VALID transition from SETTING to PARAMETER with token: <PARAMETER, LOW>
VALID transition from PARAMETER to OPERATOR with token: <OPERATOR, +>
VALID transition from OPERATOR to INTEGER with token: <INTEGER, 10>
VALID transition from INTEGER to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to PRINT with token: <PRINT, PRINT>
```

### `test_3.ddd`
Input:
```
SET SPEED LOW
PRINT
```
Output:
```
VALID transition from START to COMMAND with token: <COMMAND, SET>
VALID transition from COMMAND to SETTING with token: <SETTING, SPEED>
VALID transition from SETTING to PARAMETER with token: <PARAMETER, LOW>
VALID transition from PARAMETER to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to PRINT with token: <PRINT, PRINT>
```

### `test_4.ddd`
Input:
```
CREATE MEDIUM SPEED
SET INFILL HIGH * 10
PRINT
```
Output:
```
VALID transition from START to COMMAND with token: <COMMAND, CREATE>
VALID transition from COMMAND to PARAMETER with token: <PARAMETER, MEDIUM>
VALID transition from PARAMETER to SETTING with token: <SETTING, SPEED>
VALID transition from SETTING to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to COMMAND with token: <COMMAND, SET>
VALID transition from COMMAND to SETTING with token: <SETTING, INFILL>
VALID transition from SETTING to PARAMETER with token: <PARAMETER, HIGH>
VALID transition from PARAMETER to OPERATOR with token: <OPERATOR, *>
VALID transition from OPERATOR to INTEGER with token: <INTEGER, 10>
VALID transition from INTEGER to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to PRINT with token: <PRINT, PRINT>
```

### `test_5.ddd` (error testing)
Input:
```
CREATE FAST LAYER_HEIGHT
SET INFILL LOW
PRINT THISWONTWORK
```
Output:
```
VALID transition from START to COMMAND with token: <COMMAND, CREATE>
VALID transition from COMMAND to PARAMETER with token: <PARAMETER, FAST>
VALID transition from PARAMETER to SETTING with token: <SETTING, LAYER_HEIGHT>
VALID transition from SETTING to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to COMMAND with token: <COMMAND, SET>
VALID transition from COMMAND to SETTING with token: <SETTING, INFILL>
VALID transition from SETTING to PARAMETER with token: <PARAMETER, LOW>
VALID transition from PARAMETER to NEW_LINE with token: <NEW_LINE, \n>
VALID transition from NEW_LINE to PRINT with token: <PRINT, PRINT>
INVALID transition from PRINT with token: <LEXICAL_ERROR, THISWONTWORK>
```

## Lexical Errors
If unrecognized characters are found, the scanner will report them with a `LEXICAL_ERROR`.
