.global _start
.equ KEY_BASE, 0xFF200050
.equ LEDs, 0xFF200000

_start:
    la t0, KEY_BASE #load address of KEYS into t0
    la t4, LEDs     #load address of LEDs into t4
    li s0, 1		#register to store reset value

updateLED:
	#load value of s0 into the LEDs
	#value of s0 is determined by which KEY was pressed
    sw s0, (t4)		

#poll after updating the LEDs to see if KEYs were pressed
poll: 
	#load value of KEYS into register t1 (4-bit)
    lw t1, (t0)
	
	#check if any keys were pressed
    andi t1, t1, 0xF #(15)10 -> (1111)2
	
	#keep checking if no keys were pressed
    beqz t1, poll 

    #if a was pressed, check if its KEY3
    andi t2, t1, 0x8 #(8)10 -> (1000)2
	
	#if key3 not pressed, check if leds are in a 0 state (last pressed key was key3)
    beqz t2, checkZeroState 
	
    li s0, 0
    j wait

checkZeroState:
	#if the value of s0 is 1 (last key pressed not zero)
	#continue the normal logic (no need to display 1)
    bnez s0, handleNormalLogic 
	
	#display 1 if last pressed key was key3
    li s0, 1 
	
	#jump to poll
    j wait

handleNormalLogic:
	#first check KEY0 (and with 0001)
    andi t2, t1, 0x1
	
	#if KEY0 not pressed check for KEY2
    beqz t2, checkKEY2
	
	#display 1, if KEY0 is pressed
    li s0, 1
	
    j wait

checkKEY2:
	#check if KEY2 was pressed (and with 0100)
    andi t2, t1, 0x4 
	
	#if KEY2 not pressed, check KEY1
    beqz t2, checkKEY1
	
	#if KEY2 is pressed, then
    li t3, 1
    beq  s0, t3, wait #if led already displaying 1, do nothing
    addi s0, s0, -1 #decrement if displaying not 1
    j wait

checkKEY1:
	#check if KEY1 was pressed (and with 0010)
    andi t2, t1, 0x2 
    beqz t2, wait 
	
	#if KEY1 is pressed, then..
    li t3, 15
    beq s0, t3, wait #if number on leds is 15, do nothing
    addi s0, s0, 1 #add 1 otherwise

#loop to check if KEYs were released
wait:
	#load value of KEYS into register t1 (4-bit)
    lw t1, (t0)
	
	#check if any KEY was pressed
    andi t1, t1, 0xF 
	
	#only update the LED when the key is released (t1 wont contain 0 anymore)
    bnez t1, wait 
    j updateLED
	
	