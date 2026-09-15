.global _start
.equ TIMER_BASE, 0xFF202000
.equ KEY_BASE, 0xFF200050
.equ LEDs, 0xFF200000
.equ TIMER_COUNT, 1000000 #0.01 seconds at 100MHz

_start:
    li s1, 0 #seconds counter
    li s2, 0 #hundreths counter
    li s3, 1 #running/stopped tracker
    
	#initialize timer
    call TIMER_INIT

main_loop:
	#all subroutines return seconds value in a0 and hundreths value in a1
    mv a0, s1 #seconds
    mv a1, s2 #hundreths
	
	#display current values onto the clock
    call DISPLAY_CLOCK
    
    mv a0, s3
    call CHECK_BUTTONS #check if a button was pressed
    mv s3, a0
    
	#if timer is stopped, wait for unpause instead of incrementing
    beqz s3, main_loop 
    
	#start timer then wait till timer is done counting
    call START_TIMER
    call WAIT_FOR_TIMER
    
    mv a0, s1
    mv a1, s2
	
	#increment seconds and hundreths
    call INCREMENT_TIME
	
    mv s1, a0
    mv s2, a1
    
	#loop again
    j main_loop

DISPLAY_CLOCK:
    slli t0, a0, 7 #shift seconds bits left by 7 to take up bits 9-7
    or t0, t0, a1 #combine bits 6-0 with hundreths counter
	
	#load the value into the LEDs
    la t1, LEDs
	
    sw t0, 0(t1) #store seconds & hundreths value into LEDs
    ret

INCREMENT_TIME:
    addi a1, a1, 1 #increment hundreths counter by 1
    li t0, 100
    blt a1, t0, end #if hundreths is less than 100, continue to main loop
	
    #if hundreths is greater than 100:
    li a1, 0 #reset back to 0
    addi a0, a0, 1 #increment seconds counter
    li t0, 8
    blt a0, t0, end #if seconds is less than 8, continue to main loop
    
    li a0, 0 #reset back to 0
	
	end:
    ret

CHECK_BUTTONS:
    li t0, KEY_BASE
    lw t1, 12(t0) #load value in edge capture register
    andi t1, t1, 0xF #AND with 1111 to see if any keys were pressed
    beqz t1, skip_btn #if no buttons return back to main loop
    xori a0, a0, 1 #toggle running/stopped state
    sw t1, 12(t0) #store 1 back into edge capture to reset it
	
	skip_btn:
    ret

TIMER_INIT:
    la t0, TIMER_BASE
    li t1, TIMER_COUNT
    sw t1, 8(t0) #store low 16 bits into counter start register
    srli t1, t1, 16
    sw t1, 12(t0) #store high 16 bits into counter start register
    ret

START_TIMER:
    la t0, TIMER_BASE
    li t1, 4 #100
    sw t1, 4(t0) #store a 1 into bit 2 (start bit) of control register
    ret

WAIT_FOR_TIMER:
    la t0, TIMER_BASE
	
	poll:
    lw t1, 0(t0)
    andi t1, t1, 1
    beqz t1, poll #poll until TO bit in status register is 1 (done counting)
    sw zero, 0(t0) #store 0 into it to reset
    ret
	
	
	