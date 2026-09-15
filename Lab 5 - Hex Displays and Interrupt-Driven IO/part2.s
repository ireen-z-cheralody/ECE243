.global _start
_start:

.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
.equ KEY_BASE, 0xFF200050

    #Turn off interrupts in case an interrupt is called before correct set up
	csrw mstatus, zero
    csrci mstatus, 8 #clear mie bit 3 (1000) (stores 0 into mie register that corresponds to the 1 bits)

    #Initialize the stack pointer
    li sp, 0x20000

    #Set the mtvec register to be the interrupt_handler location
    la t0, interrupt_handler
    csrw mtvec, t0 #when an interrupt happens go to address of interrupt_handler

    #activate interrupts from IRQ18 (Pushbuttons)
    li t0, 0x40000 #set bit 18  of MIE register to 1 to enable the interrupts
    csrs mie, t0 #set bit in Machine Interrupt Enable

    li s0, KEY_BASE
    li t1, 0xF #enable interrupt on all keys
    sw t1, 8(s0) # store 1111 into interrupt mask register
    sw t1, 12(s0) #clear any edge capture bits by storing 1 into edge capture register

    csrsi mstatus, 8 #set MIE bit 3 to turn on interrupts 

IDLE: j IDLE #infinite loop to wait for interrupts

.align 4
interrupt_handler:
    addi sp, sp, -28 #save space for 7 registers (s0, s1, ra, t0, t1, t2, a0)
    
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw a0, 24(sp)
    
    # 2. Check the cause
    li s0, 0x7FFFFFFF #0 followed by 32 1s 
    csrr s1, mcause #if interrupt was caused by the key bit 31 of mcause will be 1
    and s1, s1, s0 #check if interrupt was caused by key press
    
    call KEY_ISR #key interrupt service routine
    
end_interrupt:
    # 3. Restore ALL registers in reverse order
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw a0, 24(sp)
    
    addi sp, sp, 28
    mret #mret to return from interrupt

#key interrupt service routine

KEY_ISR:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw a1, 24(sp)

    li s0, KEY_BASE
    lw s1, 12(s0) #check edge capture register
    sw s1, 12(s0) #clear edge capture by storing a 1

    la s2, TOGGLE_STATE #list to store the state of each key
    li s3, 0 #counter for key index

check_keys_loop:
    li t0, 1
    sll t0, t0, s3
    and t1, s1, t0
    beq t1, zero, next_key #check each key for the one that was pressed

	#check bit in TOGGLE_STATE
    add s4, s2, s3
    lb t2, 0(s4)
    xori t2, t2, 1 #toggle corresponding bit to track keys 
    sb t2, 0(s4)

    #call HEX_DISP 
    mv a1, s3 #HEX index
    beq t2, zero, set_blank #set to blank if t2 contains 0
    mv a0, s3 #if it is not 0 call HEX_DISP with corresponding 0,1,2,3
    j call_hex
set_blank:
    li a0, 0x10 #store 10000 for a blank hex

call_hex:
    call HEX_DISP

next_key:
    addi s3, s3, 1 #index value of key by 1
    li t0, 4 #index list by 4 to access next value
    blt s3, t0, check_keys_loop

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw a1, 24(sp)
    addi sp, sp, 32
    ret

#HEX_DISP subroutine

HEX_DISP:   
		addi sp, sp, -16           # store the 4 registers being used in this subroutine on the stack
		sw s0,0(sp)
		sw s1,0x4(sp)
		sw s2,0x8(sp)
		sw s3,0xC(sp)
	
		la   s0, BIT_CODES         # starting address of the bit codes
	    andi     s1, a0, 0x10	       # get bit 4 of the input into r6
	    beq      s1, zero, not_blank 
	    mv      s2, zero
	    j       DO_DISP
not_blank:  andi     a0, a0, 0x0f	   # r4 is only 4-bit
            add      a0, a0, s0        # add the offset to the bit codes
            lb      s2, 0(a0)         # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			la       s0, HEX_BASE1         # load address
			li       s1,  4
			blt      a1,s1, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      a1, a1, s1            # if hex4 or hex5, we need to adjust the shift
			addi     s0, s0, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     a1, a1, 3             # hex*8 shift is needed
			addi     s3, zero, 0xff        # create bit mask so other values are not corrupted
			sll      s3, s3, a1 
			li     	 a0, -1
			xor      s3, s3, a0  
    		sll      a0, s2, a1            # shift the hex code we want to write
			lw    	 a1, 0(s0)             # read current value       
			and      a1, a1, s3            # and it with the mask to clear the target hex
			or       a1, a1, a0	           # or with the hex code
			sw    	 a1, 0(s0)		       # store back
END:			
			mv 		 a0, s2				   # put bit pattern on return register
			
			
			lw s0,0(sp)			# restore those same 4 registers from the stack.
			lw s1,0x4(sp)
			lw s2,0x8(sp)
			lw s3,0xC(sp)
			addi sp, sp, 16
			ret


.data

.section .data
.align 4
TOGGLE_STATE: .byte 0, 0, 0, 0  # Memory to track ON/OFF state
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end