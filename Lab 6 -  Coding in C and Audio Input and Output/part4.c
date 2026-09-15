	
	#define delay 3200 // 8000 * 0.4

	int main() {
		//init. the audio registers
		volatile int *audio_ptr = (int *)0xFF203040;

		// arrays to store the delay of right and left
	  	int leftBuffer[delay] = {0};
	  	int rightBuffer[delay] = {0};
		
	  	int index = 0;

		//1100, bit 2 is clear write, 3 is clear read
		//clears input and output fifos
	  	*(audio_ptr) = 0xc; 
		
		//reset control status to 0
	  	*(audio_ptr) = 0x0; 

	  	while (1) {
			//grt the fifospace
			int fifospace = *(audio_ptr + 1);

			//bit shift to check if the output channels are empty
			int right_writes = (fifospace >> 24) & 0xff;
			int left_writes = (fifospace >> 16) & 0xff;
			
			//bit shift to check if the input channels are filled
			int right_read = (fifospace >> 8) & 0xff;
			int left_read = (fifospace) & 0xff;

			//if the left and right output channels are not completely empty (nothing to echo)
			//and if the left and right input channels are not completely full (more input can be taken in)
			if (right_writes < 1 || right_read < 1 || left_writes < 1 || left_read < 1) {
				continue; //continue running
			}

			//load the left and right input samples 
			int leftIn = *(audio_ptr + 2);
			int rightIn = *(audio_ptr + 3);

			//get the delayed sample (on the first run there is no delay)
			int leftDelayed = leftBuffer[index];
			int rightDelayed = rightBuffer[index];

			//reduce volume of left and right by bit shifting right
			int leftOut = (leftDelayed >> 1) + leftIn; 
			int rightOut = (rightDelayed >> 1) + rightIn;

			//add the previous output sample to the buffer array
			leftBuffer[index] = leftOut;
			rightBuffer[index] = rightOut;

			index++; //move buffer pointer forward

			//if the delay is greater than .4s ago, then reset 
			if (index >= delay) {
				index = 0;
			}
			
			//output audio to left and right
			*(audio_ptr + 2) = leftOut;
			*(audio_ptr + 3) = rightOut; 
		}
	}