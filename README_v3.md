## The ThreeDee (.ddd) Language V3

**Teammate: Andrew Marten Medina**

**UNI: amm2478**

## What has changed

In prior iterations of this project, I implemented a scanner and parser for my 3D printing language that would output ASTs based on lexical tokens and a context-free grammar I developed.

Now, I have implemented a code generation step via `gcode.c` which reads the provided AST for a specific input file and will output the relevant GCode as well as comments indicating the state of the program. This code can then be copied and pasted into a 3D printing simulator like https://ncviewer.com and demonstrate how the code progressively modifies the print step by step. I have also added helper functions to the utility file to make the code appear less cluttered as well as allow for reusability/extensibility for future development.

The code itself takes an AST and steps through each node and its siblings to generate the relevant GCode. More specifically, it processes each statement and handles different cases such as assignments, commands, conditional structures like IF and WHILE loops, and printing output to the 3D printing console.

The main functions of this include (all helpers can be found in `utility.c`):

- `process_assignment`, which evaluates and updates the variables
- `parse_the_condition`, which handles IF and WHILE conditions properly
- `generate_gcode`, which goes through AST nodes recursively, properly handling the relationships between each node and its siblings, and allows for greater extensibility to eventually extend logic to handle even more cases.

Given the current constraints, V3 of ThreeDee only handles the above cases for now but in the future could be capable of handling significantly more Gcode commands. In this current iteration, we can at least visualize points on a 3-dimensional graph.

## GCode commands currently supported by ThreeDee

Given the overall complexity of Gcode and the limited time/scope of this project, I decided to focus on demonstrating two major GCode commands:

- G92
  - This sets the current position of a particular axis
    - E.g., `G92 X10` sets the X-axis to 10
- M117
  - This sets the status on the display
    - E.g., `M117 Z1` would display the Z-axis at 1

## Usage (same as before)

1. Install Flex (`brew install Flex`) and GCC (`brew install gcc`).
2. Run `chmod +x run_scanner.sh` to make the scanner executable.
3. Execute the scanner script with a `.ddd` file as the argument, e.g.:

```
./run_scanner.sh test_1_v3.ddd
```

**NOTE:** Only test the V3 test files as the V1 and V2 files may be outdated now.

## Five sample input programs and their expected outputs

_Note: these outputs are truncated to only include the generated GCode but on the terminal it will also show the AST structure as well._

### test_1_v3.ddd

#### Input

```
CREATE X HIGH
CREATE Y MEDIUM
CREATE Z LOW
X = X - 1
PRINT X
PRINT Y
PRINT Z
```

#### Output

```
G92 X10 ; Initialize X to HIGH (10)
G92 Y5 ; Initialize Y to MEDIUM (5)
G92 Z1 ; Initialize Z to LOW (1)
; Updated X to 9
M117 X9 ; Printed value of X
M117 Y5 ; Printed value of Y
M117 Z1 ; Printed value of Z
```

### test_2_v3.ddd

#### Input

```
CREATE X LOW
CREATE Y MEDIUM
IF (Y <= 5) {
    Y = Y * 3
    PRINT X
}
PRINT Y
```

#### Output

```
G92 X1 ; Initialize X to LOW (1)
G92 Y5 ; Initialize Y to MEDIUM (5)
; Updated Y to 15
M117 X1 ; Printed value of X
M117 Y15 ; Printed value of Y
```

### test_3_v3.ddd

#### Input

```
CREATE X HIGH
CREATE Z LOW
PRINT Z
WHILE (X >= 2) {
    X = X - 2
    Z = Z + 1
    PRINT X
}
PRINT Z
```

#### Output

```
G92 X10 ; Initialize X to HIGH (10)
G92 Z1 ; Initialize Z to LOW (1)
M117 Z1 ; Printed value of Z
; Updated X to 8
; Updated Z to 2
M117 X8 ; Printed value of X
; Updated X to 6
; Updated Z to 3
M117 X6 ; Printed value of X
; Updated X to 4
; Updated Z to 4
M117 X4 ; Printed value of X
; Updated X to 2
; Updated Z to 5
M117 X2 ; Printed value of X
; Updated X to 0
; Updated Z to 6
M117 X0 ; Printed value of X
M117 Z6 ; Printed value of Z
```

### test_4_v3.ddd

_Note: this is intentionally supposed to fail and log where the error took place._

#### Input

```
CREATE Z MEDIUM
WHILE (Z >= 1) {
    Z = Z / 0
}
PRINT Z
```

#### Output

```
G92 Z5 ; Initialize Z to MEDIUM (5)
Error: Division by zero
```

### test_5_v3.ddd

#### Input

```
CREATE X HIGH
CREATE Y LOW
CREATE Z MEDIUM
WHILE (X > 1) {
    IF (X == 4) {
        Y = Y + 5
        Z = Z + 2
        PRINT X
    }
    X = X - 1
    PRINT Y
}
PRINT X
PRINT Z
```

#### Output

```
G92 X10 ; Initialize X to HIGH (10)
G92 Y1 ; Initialize Y to LOW (1)
G92 Z5 ; Initialize Z to MEDIUM (5)
; Updated X to 9
M117 Y1 ; Printed value of Y
; Updated X to 8
M117 Y1 ; Printed value of Y
; Updated X to 7
M117 Y1 ; Printed value of Y
; Updated X to 6
M117 Y1 ; Printed value of Y
; Updated X to 5
M117 Y1 ; Printed value of Y
; Updated X to 4
M117 Y1 ; Printed value of Y
; Updated Y to 6
; Updated Z to 7
M117 X4 ; Printed value of X
; Updated X to 3
M117 Y6 ; Printed value of Y
; Updated X to 2
M117 Y6 ; Printed value of Y
; Updated X to 1
M117 Y6 ; Printed value of Y
; Updated X to 0
M117 Y6 ; Printed value of Y
M117 X0 ; Printed value of X
M117 Z7 ; Printed value of Z
```

## Simulating the generated GCode

In order to verify the outputs of the generated G-code, please use https://ncviewer.com and paste the code into the section marked "GCode File", zoom out to get a full view of the provided grid, and then step through from start to finish in its simulation by using the play/stop/next buttons at the bottom of the screen. I have provided a demonstration of this in the video (see V3DemoLink) submitted for this project.
