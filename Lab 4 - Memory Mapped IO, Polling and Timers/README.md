# ECE243 Lab — Timers, Polling & Binary Clock

This repository contains my work for an **ECE243 lab** focused on **Nios V Assembly Language**, polling I/O, pushbuttons, hardware timers, and real-time LED displays on the **DE1-SoC**.

## Lab Overview

### Part I — Pushbutton-Controlled Counter
- Controls a binary number displayed on the 10 LEDs using the four pushbuttons.
- KEY0 resets the display to 1.
- KEY1 increments the value up to 15.
- KEY2 decrements the value down to 1.
- KEY3 blanks the display.
- Uses polling I/O through the KEY Data register.

### Part II — Binary Counter
- Implements a binary counter displayed on the 10 LEDs.
- Increments approximately every 0.25 seconds.
- Wraps from 255 back to 0.
- Any pushbutton can start or stop the counter.
- Uses a software delay loop and the KEY Edgecapture register.

### Part III — Hardware Timer
- Replaces the software delay with a hardware timer.
- Uses polling I/O to detect timer timeouts.
- Generates an accurate 0.25-second delay.

### Part IV — Real-Time Binary Clock
- Implements a binary clock using the 10 LEDs.
- Displays seconds on LEDR9:7 and hundredths of a second on LEDR6:0.
- Uses a single hardware timer to track both time intervals.
- The clock can be started and stopped using any pushbutton.
- Wraps after 7 seconds and 99 hundredths.

## Concepts Practiced

- Nios V Assembly
- Memory-mapped I/O
- Polling I/O
- Pushbutton and LED interfacing
- Hardware timers
- Software delay loops
- Binary number representation
- Real-time programming

## Tools

- Nios V Assembly Language
- CPULator
- DE1-SoC
- Quartus Prime
