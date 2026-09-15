.global _start
_start:
	
	#load the addresses of the hex and the result
	la t0, InputWord
	la t1, Answer
	
	#register with 1 to compare with bit 0 of the number
	li t2, 1
	
	#counting how many bits we've gone through
	li s0, 32
	li s1, 0
	
	#stores result
	li t3, 0
	
	#loading the hex number into register t4
	lw t4, (t0)
	
	check: 
		#logical AND with 1 to isolate bit 0
		andi t5, t4, 1
		
		#bitwise shift right by one to check the next bit on the next loop
		srli t4, t4, 1
		
		#add 1 to the total bit counter
		addi s1, s1, 1
		
		#if we have gone through 32 bits, stop the program
		beq s0, s1, stop
		
		#if current bit 0 is equal to 1, jump to counter
		beq t2, t5, counter
		
		#loop again
		j check
	
	counter:
		#add one to the total number of 1s counter
		addi t3, t3, 1
		
		#store the value into the memory at the address of Answer
		sw t3, (t1)
		
		#check the next bit of the number
		j check

    stop: j stop

.data
InputWord: .word 0x4a01fead

Answer: .word 0