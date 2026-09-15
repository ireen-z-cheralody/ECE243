# ECE243 Lab 5

This repository contains my work for an **ECE243 lab** focused on **Nios V Assembly Language**, interrupt-driven I/O, hardware timers, and the DE1-SoC displays.

## Lab Overview

### Part I — HEX Display
- Uses the provided `HEX_DISP` subroutine to display hexadecimal digits on the DE1-SoC's 7-segment displays.
- Tests displaying digits and blanking individual displays.
- Developed and tested without interrupts.

### Part II — KEY Interrupts
- Uses interrupt-driven pushbutton input instead of polling.
- Each KEY toggles its corresponding HEX display between a digit and blank.
- Implements interrupt setup and a `KEY_ISR` interrupt service routine.

### Part III — Timer & KEY Interrupts
- Implements a binary counter on the red LEDs.
- Uses a timer interrupt to increment the counter every 0.25 seconds.
- Uses KEY interrupts to start and stop the counter.
- Handles both timer and KEY interrupts through the interrupt handler.

### Part IV — Adjustable Counter Speed
- Extends Part III to allow the counter speed to be changed using the pushbuttons.
- KEY0 starts/stops the counter.
- KEY1 doubles the counter speed.
- KEY2 halves the counter speed.
- Includes minimum and maximum speed limits.

## Concepts Practiced

- Nios V Assembly
- Interrupt-driven I/O
- Interrupt service routines (ISRs)
- Hardware timers
- Memory-mapped I/O
- HEX and LED displays
- Pushbutton input
- Register and stack management

## Tools

- Nios V Assembly Language
- CPULator
- DE1-SoC
- Quartus Prime
