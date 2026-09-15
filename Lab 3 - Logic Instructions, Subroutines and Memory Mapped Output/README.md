# ECE243 Lab 3

This repository contains my work for an **ECE243 lab** focused on **Nios V Assembly Language**, subroutines, bit manipulation, and hardware I/O.

## Lab Overview

The lab builds on a program that counts the number of `1`s in the binary representation of a 32-bit word.

### Part I — Counting Ones
- Counts the number of `1` bits in a 32-bit word.
- Stores the result in memory.
- Tested and debugged using CPULator and the DE1-SoC.

### Part II — ONES Subroutine
- Converts the bit-counting program into a reusable `ONES` subroutine.
- Uses register `a0` for both the input value and returned count.

### Part III — Counting Ones & Zeroes
- Processes a sequence of 32-bit numbers in a loop.
- Uses the `ONES` subroutine to count both `1`s and `0`s.
- Determines the largest number of ones and zeroes.
- Stores the results in `LargestOnes` and `LargestZeroes`.

### Part IV — LED Output
- Displays the results on the DE1-SoC's 10 LEDs.
- Implements a software delay subroutine so the outputs can be viewed sequentially.
- Tested on both CPULator and the physical DE1-SoC hardware.

## Concepts Practiced

- Nios V Assembly
- Subroutines and function calls
- Registers and the stack
- Bitwise operations
- Loops and branching
- Memory-mapped I/O
- Hardware debugging

## Tools

- Nios V Assembly Language
- CPULator
- DE1-SoC
- Quartus Prime
