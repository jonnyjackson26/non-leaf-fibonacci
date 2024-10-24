.data
  .align 2 #to make it line up on multiples of 4
  arr: .space 128 #32*4 because you store 32 4 byte integers
  arrLength: .word 0
  
  #arr1: .word 8, 9, 10, 11 
  #arr1Length: .word 4

  promptMessage: .asciiz "Please enter how many fibonacci numbers you would like: "
  newLine: .asciiz "\n"
  space: .asciiz " "

.text

.globl main

#$a0 is addy of array
#$a1 is length of array
print_array:
  move $t1, $a0 #array addy
  move $t2, $a1 #length of array
  li $t3, 0 #i, or incrementer
  print_array_loop:
    beq $t3, $t2, end_print_array_loop
    
    #print ith index of array (which i store in $t4)
    li $v0, 1
    lw $t4, 0($t1)
    move $a0, $t4
    syscall
    
    #print space
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t3, $t3, 1  #inc $t3 (i)
    addi $t1, $t1, 4  #inc addy of array
    j print_array_loop
  end_print_array_loop:
    #print newline
    li $v0, 4
    la $a0, newLine
    syscall
    jr $ra
    
    
#$a0 is an integer, and it returns the $a0th number in the fibonacci sequence  (to $v0) 
fib: 
  move $t1, $a0
  beq $t1, 0, isZero
  beq $t1, 1, isOne
  else:
    #li $v0, 2 #returns 2 othersise
    
    #save $r1 and $a0 on the stack
    addi $sp, $sp, -12 #space for 2 register values
    sw $ra, 4($sp)
    sw $a0, 0($sp)
    
    #fib(n-1)
    addi $a0, $a0, -1 #n-1
    jal fib
    move $t2, $v0
    sw $t2, 8($sp) #stores fib(n-1) on the stack, bc next time around it'd be overwritten
    #fib(n-2)
    lw $a0, 0($sp) #load a0 back up (it was written over)
    addi $a0, $a0, -2 #n-2
    jal fib
    move $t3, $v0
    
    lw $t2, 8($sp) #bring t2 back from stack, then add. (fib(n-1)+fib(n-2))
    add $v0, $t2, $t3
    #restore $ra from stack
    lw $ra, 4($sp)
    addi $sp, $sp, 12
    
    j endIfElseStatement
  isZero:
    li $v0, 0
    j endIfElseStatement
  isOne:
    li $v0, 1
    j endIfElseStatement
  endIfElseStatement:
    jr $ra
  
  
main:
  #print prompt message
  li $v0, 4
  la $a0, promptMessage
  syscall
  #ask for int and store in $s3
  li $v0, 5
  syscall
  move $s3, $v0 #s3 is n (number of factorial numbers they want)
  #Load in arr
  la $s0, arr
  lw $s1, arrLength
  

  
  #loop $s2 times
  li $s2, 0 #this is i
  mainLoop:
    beq $s2, $s3, endMainLoop
    
    #store i, or $s1, in array arr
      #incerments arrLength
       lw $t0, arrLength
       addi $t0, $t0, 1     
       sw $t0, arrLength
       # Store fib(i) in arr[i]
       sll $t1, $s2, 2        # Multiply i by 4 (since each int is 4 bytes) "Shift Left Logical." When you shift a number to the left by 2 bits, you are effectively multiplying that number by 2^2, which is 4
       add $t0, $s0, $t1      # $t0 = address of arr[i]
       move $a0, $s2
       jal fib
       sw $v0, 0($t0)         # Store fib(i) in arr[i]
    
    #print arr
    la $a0, arr
    lw $a1, arrLength
    jal print_array
    
    addi $s2, $s2, 1 #inc i
    j mainLoop
  endMainLoop:
  







end:
#end program
li $v0, 10
syscall
