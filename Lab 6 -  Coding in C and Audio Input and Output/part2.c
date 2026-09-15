	
	#define AUDIO_BASE 0xff203040
	
	int main (void) {
		
		//init. control/status register
		volatile int *audio_ptr = (int *) AUDIO_BASE;
		int fifospace;

		while (1) {
			//load encoded value from fifospace register 
			fifospace = *(audio_ptr + 1); 
			
			//if RARC bits are > 0 
			//there is at least one sample in the input FIFOS
			if ((fifospace & 0xff) > 0) {
				
				//load encoded value of left and right channels
				int left = *(audio_ptr + 2);
				int right = *(audio_ptr + 3);

				//store the input channels into the output channels
				*(audio_ptr + 2) = left;
				*(audio_ptr + 3) = right;
			}
		}
	}
	