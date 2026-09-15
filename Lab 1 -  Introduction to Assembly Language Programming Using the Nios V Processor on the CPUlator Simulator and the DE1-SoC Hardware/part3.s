.global _start
_start:

li s1, 1  #load the value 1 into register s1
		  #this is where the final value will be stored
		  
li t1, 2  #load the value 2 into register t1
		  #this will be the first value we add to the sum
		  
li t2, 30 #load the value 30 into register t2
		  #this will help us stop the summation at the number 30

loop: add s1, s1, t1 #add the sum to register s1
addi t1, t1, 1       #immediately add 1 to the sum
ble t1, t2, loop     #till the sum is less than 30, keep adding it to register s1

done: j done #infinite loop to end the program