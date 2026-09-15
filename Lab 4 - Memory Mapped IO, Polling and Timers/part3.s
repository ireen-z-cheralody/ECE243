.global _start
.equ TIMER_BASE, 0xFF202000
.equ KEY_BASE, 0xFF200050
.equ LEDs, 0xFF200000
.equ TIMER_COUNT, 25000000

_start:
	li s1, 0 #counter value
	li s2, 1 #running/stopped state

	#initialize timer with count (25 mil)
	call TIMER_INIT

main_loop:
	#all subroutines store counter and global values into register a0
	
    mv a0, s1 
    call DISPLAY_LEDS #display counter value
    
	
    mv a0, s2 
    call CHECK_BUTTONS #check if any buttons were pressed 
	
	mv s2, a0 
    
    beqz s2, main_loop #if timer is paused (s2 = 0), keep displaying current value
    
	#start timer then wait till timer is done counting
    call START_TIMER
    call WAIT_FOR_TIMER
    
	#count the value on the LEDs up by 1
    mv a0, s1
    call INCREMENT_COUNT
    mv s1, a0
    
    j main_loop #repeat loop

CHECK_BUTTONS:
    la t0, KEY_BASE
    lw t1, 12(t0) #check value of edge capture register
    andi t1, t1, 0xF #AND with 1111 to check if a button was clicked
    beqz t1, skip_btn #continue if no button pressed
    
    xori a0, a0, 1 #toggle running or stopped state
    sw t1, 12(t0) #store 1 back into edge capture register
	
	skip_btn:
	ret #returns to main

INCREMENT_COUNT:
    addi a0, a0, 1 #add 1 to counter each time this is called
    li t0, 256
    blt a0, t0, reset_count #skip reset line if counter is lower than 256
    li a0, 0 #reset to 0
	
	reset_count:
    ret #returns to main

DISPLAY_LEDS:
    la t0, LEDs #store counter value into LEDs
    sw a0, 0(t0)
    ret

#subroutine to initialize timer
TIMER_INIT:
    la t0, TIMER_BASE
    la t1, TIMER_COUNT
	
	#the counter start register is split into two half bytes
    sw t1, 8(t0) #store lower 16 bits into counter start register          
    srli t1, t1, 16 # shift bits by 16 to the right
    sw t1, 12(t0) # store upper 16 bits into counter start register 
    ret

#subroutine to start the timer count
START_TIMER:
    la t0, TIMER_BASE
    li t1, 4   #0100          
    sw t1, 4(t0) #store a 1 into control reg (start bit 2)
    ret
	
#subroutine to 
WAIT_FOR_TIMER:
    la t0, TIMER_BASE
	
	poll:
    lw t1, (t0) 
    andi t1, t1, 1
    beqz t1, poll #poll TO bit in status register until it becomes 1 when the timer finishes counting down
    sw zero, (t0) #store 0 into TO bit to reset it        
    ret
	
	
	