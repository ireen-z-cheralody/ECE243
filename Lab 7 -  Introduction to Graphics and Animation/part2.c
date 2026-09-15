#include <stdlib.h>
#include <stdbool.h>

//function declarations
void plot_pixel(int x, int y, short int line_color);
void draw_line (int y);
void clear_line(int y);
void clear_screen();

// global variable
int pixel_buffer_start;

int main(void) {
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
	//write the same address into the back buffer register
	*(pixel_ctrl_ptr + 1) = pixel_buffer_start;

	//starting y position
	int y = 0;
	
	//controls direction of movement (1 for up, -1 for down)
	int direction = 1;
	
	//pointer to status register
	volatile int *status_reg;
	
	//clear the screen and draw line at starting position
    clear_screen();
	draw_line(y);
	
	while (1) {
		//clear current line
		clear_line(y);
		
		//increment or decrement based on the current direction
		y += direction; 
		
		//change direction if y exceeds bounds
		if (y >= 239) {direction = -1;} 
		if (y <= 0) {direction = 1;}
		
		//draw the line at the new position
		draw_line(y);
		
		//synchronize the VGA
		//write 1 into the buffer register (same as back buffer)
		*pixel_ctrl_ptr = 1;
		//get pointer to status register
		status_reg = pixel_ctrl_ptr + 3;
		
		//wait to clear and draw the next line till the S bit in the 
		//status register becomes 1
		while ((*status_reg & 0x1) != 0);
	}
}

//plots an individual pixel
void plot_pixel(int x, int y, short int line_color){
    volatile short int *one_pixel_address;
        one_pixel_address = (short int*)(pixel_buffer_start + (y << 10) + (x << 1));
        *one_pixel_address = line_color;
}

//draw a straight horizontal line at a y position
void draw_line (int y) {
	for (int x = 40; x < 280; x++) {
		plot_pixel(x, y, 0xffffff);
	}
}

//clear the straight horizontal line at a y position
void clear_line (int y) {
	for (int x = 40; x < 280; x++) {
		plot_pixel(x, y, 0);
	}	
}

//draws black pixels over the screen
void clear_screen() {
	for (int i = 0; i < 320; i++) {
		for (int j = 0; j < 240; j++) {
			plot_pixel(i, j, 0);
		}
	}
} 
