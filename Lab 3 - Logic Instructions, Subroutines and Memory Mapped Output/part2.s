.global _start
_start:
	
	main: 
	
	#load the addresses of the hex and the result
	la s0, InputWord
	la s1, Answer
	
	#loading the hex number into register a0
	lw a0, (s0)
	call ONES
	
	#store the returned result into memory
	sw a0, (s1)

    stop: j stop
	
	ONES: 
		
		#counts the number of bits
		li t0, 32
		li t1, 0
		
		#counts the number of 1s
		li t2, 0 
		
		#to compare bit zero to 1
		li t3, 1
	
	check: 
		#logical AND with 1 to isolate bit 0
		andi t4, a0, 1
		
		#bitwise shift right by one to check the next bit on the next loop
		srli a0, a0, 1
		
		#add 1 to the total bit counter
		addi t1, t1, 1
		
		#if we have gone through 32 bits, stop the program
		beq t0, t1, end
		
		#if current bit 0 is equal to 1, jump to counter
		beq t4, t3, counter
		
		#loop again
		j check
	
	counter:
		#add one to the total number of 1s counter
		addi t2, t2, 1
		
		#check the next bit of the number
		j check
		
	end: 
		#store the result in register a0
		mv a0, t2
		
		#go back to main program
		ret

.data
InputWord: .word 0x4a01fead

Answer: .word 0