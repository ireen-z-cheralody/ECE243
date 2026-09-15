
	#define AUDIO_BASE 0xff203040
	#define SW 0xff200040
	
	//helper function to determine period of wave given switches
	int periodDetector (volatile int *SW_ptr) {
		int halfPeriods[10] = {
			30, //133Hz for SW 0
			20, //200Hz for SW 1
			10, //400Hz for SW 2
			8, 	//500Hz for SW 3
			7, 	//571Hz for SW 4
			6, 	//666Hz for SW 5
			5, 	//800Hz for SW 6
			4, 	//1KHz for SW 7
			3, 	//1.3KHzfor SW 8
			2	//2KHz for SW 9
			}; 
		
		int switches = *SW_ptr;
		
		//if the switch is on then return the period associated with it
		for (int i = 0; i < 10; i++) {
			if (switches & (1 << i)) {
				return halfPeriods[i];
			}
		}
		
		return 40; //default 100Hz wave
	}

	int main (void) {
		//init. audio and switches
		volatile int *audio_ptr = (int *)AUDIO_BASE;
		volatile int *SW_ptr = (int *)SW;
	
		int counter = 0;
		int sample = 0x7fffff; //volume of the sound (big number)
		int halfPeriod = 40; //default 100Hz
		
		while (1) {
			
		    //load encoded value of the fifo space
			int fifospace = *(audio_ptr + 1);
			
			//check if left and right channels are empty
			int WSLC = (fifospace >> 24) & 0xff;
			int WSRC = (fifospace >> 16) & 0xff;
			
			//get the frequency to be played
			halfPeriod = periodDetector(SW_ptr);

			//if the channels are empty then play the sample
			if (WSLC > 0 && WSRC > 0) {
				
				*(audio_ptr + 2) = sample;
				*(audio_ptr + 3) = sample;
				
				counter++;
				
				//flip the sample to be negative when half of the period is reached
				if (counter >= halfPeriod) {
					sample = -sample;
					counter = 0;
				}
			}	
		}
	}