.equ LEDs, 0xFF200000
.equ TIMER, 0xFF202000
.equ KEY_BASE, 0xFF200050
.equ DELAY_VAL, 25000000

.global _start

_start:
    li sp, 0x20000

    jal ra, CONFIG_TIMER
    jal ra, CONFIG_KEYS

    la t0, interrupt_handler #go to interrupt_handler when interrupt is triggered
    csrw mtvec, t0

    li t0, 0x50000 #1 at bit 16 and 18 to enable timer and key interrupts
    csrs mie, t0
    li t0, 0x8 #MIE bit in mstatus (1000)
    csrs mstatus, t0

    la s0, LEDs
    la s1, COUNT

LOOP:
    lw  s2, 0(s1)
    sw  s2, 0(s0) #store current count value into LED
    j   LOOP

.align 4
interrupt_handler:
    addi sp, sp, -48 #save all registers
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw s0, 20(sp)
    sw s1, 24(sp)
    sw s2, 28(sp)
    sw s3, 32(sp)
    sw s4, 36(sp)
    sw a1, 40(sp)

    csrr t0, mcause
    li t1, 0x7FFFFFFF #find out whether timer or key caused interrupt
    and t0, t0, t1

    li t1, 16 #IRQ 16 is timer
    beq t0, t1, call_timer
    li t1, 18 #IRQ 18 is key
    beq t0, t1, call_keys
    j exit_handler #if no interrupt return to main loop

call_timer:
    call TIMER_ISR
    j exit_handler

call_keys:
    call KEY_ISR

exit_handler:
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw s0, 20(sp)
    lw s1, 24(sp)
    lw s2, 28(sp)
    lw s3, 32(sp)
    lw s4, 36(sp)
    lw a1, 40(sp)
    addi sp, sp, 48
    mret

TIMER_ISR:
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    la s0, TIMER
    sw zero, 0(s0) #reset (TO) register
	
    la s1, RUN
    lw s2, 0(s1)
    beq s2, zero, timer_done #if timer is paused skip the increment

    la s1, COUNT
    lw s2, 0(s1)
    addi s2, s2, 1
    li t0, 256
    rem s2, s2, t0 #modulus 256 to reset to 0 after timer hits 255
    sw s2, 0(s1)

timer_done:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 16
    ret

KEY_ISR:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    li s0, KEY_BASE
    lw s1, 12(s0) #edge capture
    sw s1, 12(s0) #clear edge capture

    #KEY0: pause/resume counter
    andi t0, s1, 1
    beq t0, zero, check_key1 #if not key 0 check key 1
    la s0, RUN
    lw t1, 0(s0)
    xori t1, t1, 1 #toggle global run variable
    sw t1, 0(s0)

check_key1:
    #KEY1: double speed
    andi t0, s1, 2
    beq t0, zero, check_key2 #if not key 1 check key 2
    call GET_TIMER_VAL #returns counter value as one 32bit number
    srli a0, a0, 1 #bit shift to the left by 1 doubles the speed by halving counter value
    
    li t1, 0x00010000 #speed limit maximum
    bge a0, t1, apply_timer #within speed limit, then apply value
    mv a0, t1 #if too fast (under 10000), move speed limit to timer
    j apply_timer #updates timer

check_key2:
    #KEY2: half speed
    andi t0, s1, 4
    beq t0, zero, key_isr_exit #if not key 2 exit to main loop
    call GET_TIMER_VAL #returns counter value as one 32bit number
    slli a0, a0, 1 #bit shift to the left halves the speed by doubling the counter value
    
    li t1, 100000000 #speed limit minimum
    ble a0, t1, apply_timer #update timer
    mv a0, t1

apply_timer:
    call UPDATE_TIMER

key_isr_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
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

GET_TIMER_VAL:
    la t0, TIMER
    lw t1, 8(t0) #load low 16 bits of counter value
    lw t2, 12(t0) #load high 16 bits of counter value
    slli t2, t2, 16 #combine 2 numbers to create 32bit number
    or a0, t2, t1
    ret

UPDATE_TIMER:
    la t0, TIMER
    li t1, 0x8 #1000
    sw t1, 4(t0) #store a 1 in STOP bit of control register
    sw a0, 8(t0) #write new Low
    srli a1, a0, 16 #use a temporary for the shift
    sw a1, 12(t0) #write new High
    li t1, 0x7 #start back up (111)
    sw t1, 4(t0) #store 111 into control register which starts timer again
    ret

.section .data
.align 4
COUNT:  .word 0x0
RUN:    .word 0x1
.end