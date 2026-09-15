# ECE243 Lab 6

This repository contains my work for an **ECE243 lab** focused on **C programming, memory-mapped I/O, polling, and audio processing** on the DE1-SoC.

## Lab Overview

### Part I — KEY Polling & LEDs
- Uses C pointers to access memory-mapped I/O.
- Polls the KEY pushbutton edge capture register.
- KEY0 turns on all 10 red LEDs.
- KEY1 turns off all 10 red LEDs.
- Uses bitwise operators and pointer arithmetic.

### Part II — Audio Input to Output
- Reads audio samples from the microphone input FIFO.
- Sends the samples directly to the speaker output FIFO.
- Tested using CPUlator and the DE1-SoC audio interface.

### Part III — Adjustable Square Wave
- Generates a square wave through the audio output.
- Uses the 10 switches to select the output frequency.
- Supports frequencies across approximately **100 Hz–2 kHz**.

### Part IV — Audio Echo
- Extends the audio input/output program to create an **echo effect**.
- Uses an approximately **0.4-second delay**.
- Experiments with damping to produce a suitable echo.

## Concepts Practiced

- C programming
- Memory-mapped I/O
- C pointers and pointer arithmetic
- Bitwise operations
- Polling
- Pushbutton and switch input
- LED output
- Audio FIFOs
- Digital audio processing
- Square-wave generation
- Echo and delay effects

## Files

- `part1.c` — KEY polling and LED control
- `part2.c` — Microphone-to-speaker audio passthrough
- `part3.c` — Switch-controlled square wave generator
- `part4.c` — Audio echo effect

## Tools

- C
- CPUlator
- DE1-SoC
- Nios V
- Quartus Prime
