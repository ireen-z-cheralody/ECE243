.global _start
_start:

# s3 should contain the grade of the person with the student number, -1 if not found
# s0 has the student number being searched

li s0, 718293

la t0, result #load address of result into register t0

li t1, -1 #load register t1 with -1 in case student number is not found

la t2, Snumbers #load address of Snumbers array into t2
la t3, Grades #load address of Grades array into t3

loop:
	
	lw t4, (t2) #load the student number at the current index to register t4
	lw t5, (t3) #load the grade at the current index array to register t5
	
	#if the student number is equal to the one we found, jump to the finished label
	beq t4, s0, finished
	
	#if we've reached the end of the array, jump to notFound label
	beq t4, zero, notFound 
	
	/*increment both the grades and student number indices by 4 bytes 
	to get the next value*/
	addi t2, t2, 4
	addi t3, t3, 4
	
	#run the loop again
	j loop
	
finished: 
	#if student number is a match, store the grade into result
	sw t5, (t0)
	
	#jump to the end of the program
	j iloop

notFound:
	#if student number does not exist, store -1 into result
	sw t1, (t0)
	
	#jump to the end of the program
	j iloop

#end program
iloop: j iloop

/* result should hold the grade of the student number put into s0, or
-1 if the student number isn't found */ 

.data
result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .align 2
		.byte 99 #10392584
		.align 2
		.byte 68 #423195
		.align 2
		.byte 90 #644370
		.align 2
		.byte 85 #496059
		.align 2
		.byte 91 #296800
		.align 2
		.byte 67 #265133
		.align 2
		.byte 80 #68943
		.align 2
        .byte 66 #718293
		.align 2
		.byte 95 #315950
		.align 2
		.byte 91 #785519
		.align 2
		.byte 91 #982966
		.align 2
		.byte 99 #345018
		.align 2
		.byte 76 #220809
		.align 2
		.byte 68 #369328
		.align 2
        .byte 69 #935042
		.align 2
		.byte 93 #467872
		.align 2
		.byte 90 #887795
		.align 2
		.byte 72 #681936