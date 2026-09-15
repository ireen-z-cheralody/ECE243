.global _start
_start:
	
	/*the real processor is faster than the simulator because it directly 
	executes the instructions whereas a simulator has an extra step.
	it loses efficiency in trying to make a virtual machine on an existing
	operating system*/	
	
	.equ LEDs, 0xFF200000 
	la s3, LEDs
	
	main: 
	
	#load the addresses of the hex and the result
	la s0, TEST_NUM
	la s1, LargestOnes
	la s2, LargestZeroes
	
	#keeps track of ones
	li a1, 0
	
	#keeps track of zeros
	li a2, 0
	
	#to convert from neg to pos number
	li a3, 0
	
	#load address of stack
	la sp, 0x20000
	
	#load the first number at TEST_NUM
	lw a0, (s0)
	
	#loop to check through each number at TEST_NUM
	loop:
		
		#store the current number in a0 onto the stack
		addi sp, sp, -4
		sw a0, (sp)
		
		#call the subroutine to count the number of ones
		call ONES
		
		#check result against the current largest number of ones
		#jump to addLargestOnes if result is larger
		blt a1, a0, addLargestOnes
		
		back1: 
		
		#pop off the initial number from the stack
		lw a0, (sp)
		addi sp, sp, 4
	
		#complement the number
		xori a0, a0, -1
		
		#call subroutine to count the number of 0s (now 1s)
		call ONES
		
		#check result against the current largest number of zeroes
		#jump to addLargestZeroes if result is larger
		blt a2, a0, addLargestZeroes
		
		back2: 

		#go to the number at the next address in TEST_NUMM
		addi s0, s0, 4
		lw a0, (s0)
		
		#if the value is zero, end the loop
		beqz a0, continue
	
		#otherwise, continue looping
		j loop
		
	addLargestOnes: 
		#replace the previous largest number with the new one
		mv a1, a0
		
		#go back to the loop
		j back1
		
	addLargestZeroes:
		#replace the previous largest number with the new one
		mv a2, a0
		
		#go back to the loop
		j back2
	
	#store the results into memory
	continue: 
		sw a1, (s1)
		sw a2, (s2)

	#infinitely loop the LEDs
	LEDs: 
	
		#display LargestOnes on the LEDs
		sw a1, (s3)
		#delay before displaying the next number
		call delayLoop
		
		#display LargestZeroes on the LEDs
		sw a2, (s3)
		call delayLoop
		
		#continue looping
		j LEDs
	
	
	#subroutines below ------------------
	
	
	#subroutine that counts the number of 1s in a number
	ONES: 
		
		#keep track of return address on the stack
		addi sp, sp, -4
		sw ra, (sp)
		
		#counts the number of bits
		li t0, 33
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
		
		#pop of the last return address from the stack
		lw ra, (sp)
		addi sp, sp, 4
		
		#go back to main program
		ret
		
	#subroutine that counts till 100 mil	
	delayLoop:
		#keep track of return address on the stack
		addi sp, sp, -4
		sw ra, (sp)
		
		li a3, 100000000
		li a4, 0
		
		#count till 100 mil
		innerLoop: 
			addi a4, a4, 1
			blt a4, a3, innerLoop
		
		#pop of the last return address from the stack
		lw ra, (sp)
		addi sp, sp, 4
		
		#go back to main program
		ret

.data
TEST_NUM: .word 0x4a01fead, 0xF677D671, 0xDC9758D5, 0xEBBD45D2, 0x8059519D
			.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
			.word 0 # end of list

LargestOnes: .word 0
LargestZeroes: .word 0