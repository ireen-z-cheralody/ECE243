#include <stdlib.h>
#include <stdbool.h>

//function declarations
void plot_pixel(int x, int y, short int line_color);
void draw_line (int x0, int y0, int x1, int y1, short int line_color);
void clear_screen();
void swap (int* x, int* y);

int pixel_buffer_start; // global variable

int main(void) {
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
	
	while (1);
}

void plot_pixel(int x, int y, short int line_color){
    volatile short int *one_pixel_address;
        one_pixel_address = (short int*)(pixel_buffer_start + (y << 10) + (x << 1));
        *one_pixel_address = line_color;
}

//algorithm given in figure 2
void draw_line (int x0, int y0, int x1, int y1, short int line_color) {
	
	//determine if the line is steep
	//steep line changes more in y than x
	bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	
	//swap x and y coordinates to iterate over the longer axis if steep
	if (is_steep) {
		swap (&x0, &y0);
		swap (&x1, &y1);
	}
	
	//make sure we always draw left to right
	if (x0 > x1) {
		swap (&x0, &x1);
		swap (&y0, &y1);
	}
	
	int y_step = 0;
	int deltax = x1 - x0; 		//total horizontal distance
	int deltay = abs(y1 - y0);	//total vertical distance 
	int error = -(deltax/2);	//error accumulates, is centered at -(deltax/2)
	int y = y0;					//current y position starts at y0
	
	//check if y increases or decreases as we step through x
	if (y0 < y1) {
		y_step = 1;
	} else {
		y_step = -1;
	}
	
	//step through every x pixel from x0 to x1
	for (int x = x0; x < x1; x++) {
		//if the line is steep, unswap x and y
		if (is_steep) {
			plot_pixel (y, x, line_color);
		} else {
			plot_pixel (x, y, line_color);
		}
		
		//accumulate vertical error
		error = error + deltay;
		
		//if error is positive, we can increment why
		if (error > 0) {
			y = y + y_step;
			error = error - deltax; //reset error
		}
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

//swaps the value of two integers
void swap (int* x, int* y) {
	int temp = *x;
	*x = *y;
	*y = temp;
}
