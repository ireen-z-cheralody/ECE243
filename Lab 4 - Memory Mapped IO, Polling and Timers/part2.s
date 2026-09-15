.global _start
.equ TIMER_BASE, 0xFF2002000
.equ KEY_BASE, 0xFF200050
.equ COUNTER_DELAY, 500000
.equ LEDs, 0xFF200000
.equ KEY_EDGE, 0xFF20005c

_start:
    la t0, KEY_BASE #load address of KEYs 
    la t1, LEDs		#load address of LEds
    li s1, 0		#
    li s2, 1 		#running/stopped tracker (0 if stopped)
	#if zero, don't update LEDs
    
loop:
	#update the LEDs with the value of s1
    sw s1, (t1) 
    
    #check low four bits of the edge capture register
    lw t4, 12(t0) 
	#check which buttons were pressed (and with 1111)
    andi t4, t4, 0xF 
    
    beqz t4, count_logic #if no buttons were pressed, proceed with counting
    
    xori s2, s2, 1 #if a button was pressed, flip the running/stopped tracker
	#sets to 0 if stopped, 1 if no button pressed
    
	#t4 contains a 1 in the location of the edge capture bit that was turned on 
	#storing a 1 back in will reset it
    sw t4, 12(t0)      
    
count_logic:
	#if counter is stopped dont continue counting
    beqz s2, loop 
    
	#increment counter
    addi s1, s1, 1 
    li t2, 256
	
	#check if value is less than 256
    blt s1, t2, do_delay 
	
	#if it is equal to 256, then reset counter
    li s1, 0 
    
do_delay:
	#load 500 000
	#will delay the time between the incrementing on the LEDs
    li t3, COUNTER_DELAY
	
sub_loop: #counts down from 500000 to slow the loop down
    addi t3, t3, -1
	#when not zero, continue decrementing
    bnez t3, sub_loop
    
    j loop
	
	
	
	