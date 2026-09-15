# ECE243 Lab — VGA Graphics & Animation

This repository contains my work for an **ECE243 lab** focused on **C programming, VGA graphics, line drawing, frame buffers, and animation** on the DE1-SoC.

## Lab Overview

### Part I — Bresenham's Line Drawing
- Implements Bresenham's line-drawing algorithm in C.
- Draws lines between specified points on the VGA display.
- Uses memory-mapped frame buffer access to plot individual pixels.
- Handles different line directions and slopes using integer calculations.

### Part II — Bouncing Line
- Creates a horizontal line that moves vertically across the VGA display.
- The line bounces off the top and bottom edges.
- Uses the VGA frame buffer controller's vertical synchronization to control animation timing.

### Part III — Animated Box Chain
- Animates eight filled boxes moving diagonally across the screen.
- Boxes bounce off the edges of the VGA display.
- Connects the boxes with lines to form a moving chain.
- Uses front and back frame buffers with vertical synchronization to prevent visual artifacts.
- Compares the animation behavior of double buffering with a single frame buffer.

## Concepts Practiced

- C programming
- Bresenham's algorithm
- Pixel plotting
- Memory-mapped I/O
- VGA graphics
- Frame buffers
- Double buffering
- Vertical synchronization
- 2D animation
- Collision/boundary detection

## Files

- `part1.c` — Bresenham line-drawing implementation
- `part2.c` — Bouncing horizontal line animation
- `part3.c` — Animated chain of eight boxes

## Tools

- C
- CPUlator
- DE1-SoC
- VGA Controller
- Nios V
- Quartus Prime
