
	#define LEDs 0xff200000
	#define KEY_BASE 0xff200050
		
	int main (void) {
		//init. LEDs & data registers address 
		volatile int *LEDR_ptr = (int *) LEDs;
		volatile int *KEYS_ptr = (int *) KEY_BASE;
		
		//reset edge capture bits just in case
		*(KEYS_ptr + 3) = 0b1111;
		
		//init. variable to turn on all LEDs
		int ledsOn = 0b1111111111;
		
		//turn off all LEDs just in case
		*LEDR_ptr = 0;
		
		//infinite loop
		while (1) {
			//get the value encoded in the edge capture reg
			int edge_cap = *(KEYS_ptr + 3);
			
			//bitwise and with 1 to isolate bit 0
			if (edge_cap & 0b1) {
				
				//if key0 is pressed then turn on LEDs
				*LEDR_ptr = ledsOn;
				
				//reset edge capture after handling request
				*(KEYS_ptr + 3) = 0b1111;
				
			} else if ((edge_cap & 0b10) == 0b10){
				
				//if key1 is pressed then turn off LEDs
				*LEDR_ptr = 0;
				
				//reset edge capture after handling request
				*(KEYS_ptr + 3) = 0b1111;
			}
		}
	}