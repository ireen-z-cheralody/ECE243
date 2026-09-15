.global _start
_start:
    .equ LEDs,     0xFF200000
    .equ TIMER,    0xFF202000
    .equ KEY_BASE, 0xFF200050
	.equ DELAY_VAL, 25000000

    li sp, 0x20000
    
    jal    CONFIG_TIMER        # configure the Timer
    jal    CONFIG_KEYS         # configure the KEYs port
    
    la t0, interrupt_handler 
    csrw mtvec, t0 #go to interrupt_handler if interrupt is caused

    li t0, 0x50000 #hexidecimal 50000 has 1 at bit 18 and bit 16 with the rest being 0
    csrs mie, t0 #enables timer and key IRQs
    
    li t0, 0x8 #MIE bit in mstatus
    csrs mstatus, t0 #enable global interrupts
    
    #main loop
    la s0, LEDs
    la s1, COUNT
    
LOOP:
    lw      s2, 0(s1)          # Get current count
    sw      s2, 0(s0)          # Store count in LEDs
    j       LOOP

.align 4
interrupt_handler:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw a0, 12(sp)
    sw s0, 16(sp)
    sw s1, 20(sp)
    
    csrr t0, mcause #read mcause register
    li t1, 0x7FFFFFFF
    and t0, t0, t1 #t0 contains 
    
    li t1, 16 #IRQ 16 is timer
    beq t0, t1, call_timer #mcause will have 16 in binary if interrupt from timer
    
    li t1, 18 #IRQ 18 is key
    beq t0, t1, call_keys #mcause will have 18 in binary if interrupt came from key
    j exit_handler #return to main loop if no interrupts

call_timer:
    call TIMER_ISR
    j exit_handler

call_keys:
    jal ra, KEY_ISR

exit_handler:
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw a0, 12(sp)
    lw s0, 16(sp)
    lw s1, 20(sp)
    addi sp, sp, 32
    mret #return to main loop if no interrupts

TIMER_ISR:
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    
    la s0, TIMER
    sw zero, 0(s0) #reset timeout (TO) bit to 0
    
    la s1, RUN
    lw s2, 0(s1)
    beq s2, zero, timer_done #if run is not toggled, skip the increment
    
    la s1, COUNT
    lw s2, 0(s1)
    addi s2, s2, 1
    li t0, 256
    rem s2, s2, t0 #rem does modulus(%), if s2 reaches 256 it will reset to 0 because 256(count)%256 is 0
    sw s2, 0(s1) #reset COUNT to 0

timer_done:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 16
    ret

KEY_ISR:
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    
    la s0, KEY_BASE
    lw s1, 12(s0) #read edge capture register
    sw s1, 12(s0) #store 1 to clear edge capture
    
    la s0, RUN
    lw s1, 0(s0)
    xori s1, s1, 1 #toggle run status tracker
    sw s1, 0(s0)

    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

CONFIG_TIMER: 
    la t0, TIMER
    li t2, DELAY_VAL #25000000

    sw t2, 8(t0) #store low 16 bits into counter start register

    srli t3, t2, 16 #bit shift by 16 to the left
    sw t3, 12(t0) #store high 16 bits into upper start value register

    li t1, 0x7 #binary 111 (Start, Cont, Interrupt)
    sw t1, 4(t0)
    ret

CONFIG_KEYS: 
    li t0, KEY_BASE
    li t1, 0xF #enable interrupts for all 4 keys
    sw t1, 8(t0) #set interrupt mask
    sw t1, 12(t0) #clear edgecapture
    ret

.data
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end