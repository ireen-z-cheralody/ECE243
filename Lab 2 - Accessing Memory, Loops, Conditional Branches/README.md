# ECE243 Lab 2

This repository contains my work for an **ECE243 Lab 2** focused on programming and debugging using **Nios V Assembly Language**.

## Part I — Finding Largest and Lowest Values

The first part involved modifying an existing assembly program that searches through numbers stored in memory.

Two versions of the program were created:

- `part1_big.s` — Searches through 15 unique numbers and determines the **largest** value.
- `part1_lowest.s` — Searches through the same 15 numbers and determines the **lowest** value.

The programs were tested using **CPULator** with single-stepping and then run on the **DE1-SoC** board, with the result displayed using the 10 LEDs.

### Concepts Practiced

- Assembly instructions and registers
- Memory access
- Loops and branching
- Comparing values
- Number representation in binary and decimal
- Hardware output using LEDs
- Debugging through single-stepping

## Part II — Student Grade Lookup

The second part involved writing a Nios V assembly program that searches for a student number within a list stored in memory.

The program:

1. Takes a student number from register `s0`.
2. Searches through the `Snumbers` list.
3. Determines the student's index if found.
4. Uses the corresponding index to retrieve the student's grade from the `Grades` list.
5. Stores the grade in the memory location labeled `result`.
6. Stores `-1` if the student number is not found.

### Concepts Practiced

- Searching through memory
- Address manipulation
- Array indexing
- Conditional branching
- Working with assembler directives such as `.word`
- Storing results in memory

## Tools

- Nios V Assembly Language
- CPULator
- DE1-SoC
