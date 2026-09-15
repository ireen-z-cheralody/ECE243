//include for rand() function
#include <stdlib.h>
#include <stdbool.h>

//function declarations
void plot_pixel(int x, int y, short int line_color);
void draw_boxes (int xBox[8], int yBox[8], short int color[8], int size, int clear);
void move_boxes (int xBox[8], int yBox[8], int dxBox[8], int dyBox[8]);
void draw_line (int x0, int y0, int x1, int y1, short int line_color);
void draw_all_lines(int xBox[8], int yBox[8], int clear);
void wait_for_vsync();
void swap (int* x, int* y);
void clear_screen();

//global variables
volatile int pixel_buffer_start;
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];

int main(void) {
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	pixel_buffer_start = *pixel_ctrl_ptr;
	
	int squareSize = 6; //box is a four pixel square
	int clear = 1; //whether or not the boxes and lines should be cleared
	
	int xBox[8], yBox[8], dxBox[8], dyBox[8];
	short int color[8];
	
	//initialize all random values
	for (int i = 0; i < 8; i++) {
		xBox[i] = rand() % 320;
		yBox[i] = rand() % 240;
		color[i] = rand() % 0x10000;
		//initial direction of each box
		dxBox[i] = (rand() % 2 == 0) ? 1 : -1;  // either +1 or -1
		dyBox[i] = (rand() % 2 == 0) ? 1 : -1;
	}
	

    //set front pixel buffer to Buffer 1
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
	//now, swap the front/back buffers, to set the front buffer location
    wait_for_vsync();
    //initialize a pointer to the pixel buffer, used by drawing functions
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    //set back pixel buffer to Buffer 2
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
	clear_screen();
	
	int prevX[8], prevY[8]; 
	
    while (1){
		//erase boxes and lines previously drawn
		draw_all_lines(prevX, prevY, 1);
		draw_boxes(prevX, prevY, color, squareSize, 1);
		
		//update previous position, used to erase
		for (int i = 0; i < 8; i++) { prevX[i] = xBox[i]; prevY[i] = yBox[i]; }
		
		move_boxes (xBox, yBox, dxBox, dyBox); //update location
		//draw new boxes and lines
		draw_all_lines(xBox, yBox, 0);
		draw_boxes(xBox, yBox, color, squareSize, 0);
		
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

//plot a single pixel
void plot_pixel(int x, int y, short int line_color){
    volatile short int *one_pixel_address;
        one_pixel_address = (short int*)(pixel_buffer_start + (y << 10) + (x << 1));
        *one_pixel_address = line_color;
}

//draw a box
void draw_boxes (int xBox[8], int yBox[8], short int color[8], int size, int clear) {
	
	//loop through each box
	for (int a = 0; a < 8; a++) {
		//draw each box
		for (int i = xBox[a]; i < xBox[a] + size; i++) {
			for(int j = yBox[a]; j < yBox[a] + size; j++) {
				//only draw if within bounds and not erasing
				if (clear != 1 && i > 0 && i < 320 && j > 0 && j < 240) {
					plot_pixel(i, j, color[a]);
				} else {
					plot_pixel(i, j, 0);
				}
			}
		}
	}
}


void move_boxes (int xBox[8], int yBox[8], int dxBox[8], int dyBox[8]) {
	
	for (int a = 0; a < 8; a++) {
		//update location of each box
		xBox[a] += dxBox[a];
		yBox[a] += dyBox[a];
		
		//if the coordinates exceed any bounds, flip the direction
		if (xBox[a] <= 0 || xBox[a] >= 319) dxBox[a] = -dxBox[a];
        if (yBox[a] <= 0 || yBox[a] >= 239) dyBox[a] = -dyBox[a];
	}
}

void draw_all_lines(int xBox[8], int yBox[8], int clear) {
	
	int color = 0;
	//if not erasing, then line color is white
	if (clear != 1) {color = 0xffffff;}
	
	//draw a line from box 0 to box 1 and box 1 to box 2 etc.
	//make sure it wraps around with box 7 connecting to box 0
	for (int a = 0; a < 8; a++) {
		int b = (a + 1) % 8; //wrap around
		draw_line(xBox[a], yBox[a], xBox[b], yBox[b], color);
	}
}

//draw any line from one point to another
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

void wait_for_vsync() {
	 
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	//synchronize the VGA
	//write 1 into the buffer register
	*pixel_ctrl_ptr = 1;
	//get pointer to status register
	volatile int * status_reg = pixel_ctrl_ptr + 3;
	//wait to clear and draw the next line till the S bit in the 
	//status register becomes 1
	while ((*status_reg & 0x1) != 0);
	
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
