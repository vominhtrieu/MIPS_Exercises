.data
arrSize: .word 0
arr: .space 4000		#4000bytes can contains 1000 word elements

inputFile: .asciiz "input_sort.txt"
outputFile: .asciiz "output_sort.txt"
inputBuffer: .space 20000 	#Array have 1000 elements in maximum
				#A decimal have 11 characters in maximum
				#And we need 999 spaces in maximum
				#So we need 1000*11 + 999 = 11999(Bytes)
				#And 20000 is enough for storing them
outputBuffer: .space 20000
.text
.globl main
main:
	jal readFile
	#Read number of elements
	la $a0, inputBuffer
	jal charToInt
	addi $s0, $v0, 0
	la $t0, arrSize
	sw $s0, 0($t0)
	
	#Convert input string to int array
	jal toArray
	
	#Preparing parameters for Quick sort
	la $a0, arr
	la $t0, arrSize
	lw $t1, 0($t0)
	li $t2, 4
	subi $t1, $t1, 1
	mult $t1, $t2
	mflo $t3
	add $a1, $a0, $t3
	jal quickSort
	
	#Write result to file
	jal writeFile
	li $v0, 10
	syscall

########################
##Load Array to Memory##
########################
    
readFile:
	#Open File
	li $v0, 13
	la $a0, inputFile
	li $a1, 0
	li $a2, 0
	syscall
	addi $s0, $v0, 0
	
	#Read File
	li $v0, 14
	addi $a0, $s0, 0
	la $a1, inputBuffer
	li $a2, 19999
	syscall
	
	#Close file
	li $v0, 16
	addi $a0, $s0, 0
	syscall
	jr $ra

#Convert a char to int
charToInt:
	li $v0, 0

	loopConvert:
		lb $t0, 0($a0)
		#Check whether this character is a number
		bgt $t0, '9', endLoopConvert
		blt $t0, '0', endLoopConvert
		
		#num *= 10 by using num = num + 8 + 2 or num = (num << 3) + (num << 1)
		sll $t2, $v0, 1
		sll $v0, $v0, 3
		add $v0, $v0, $t2
		
		subi $t0, $t0, '0'
		add $v0, $v0, $t0
		addi $a0, $a0, 1
		j loopConvert
	endLoopConvert:
    		jr $ra # return
    
#String to array
toArray:
	addi $s2, $ra, 0
	la $s3, arr
	la $a0, inputBuffer
	jal charToInt

	addi $s1, $v0, 0
	addi $a0, $a0, 1
	lb $t0, 0($a0)

	bgt $t0, '9', endLine
	blt $t0, '0', endLine
	j loopInput
	endLine:
	addi $a0, $a0, 1

	loopInput:
		beq $s1, 0, endLoopInput
		jal charToInt
		addi $a0, $a0, 1
		addi $s1, $s1, -1
		sw $v0, 0($s3)
		addi $s3, $s3, 4
		j loopInput

	endLoopInput:
		addi $ra, $s2, 0
		jr $ra

##############
##Quick Sort##
##############
##This procedure receive $a0: left, $a1: right, $a2: pivot
##Specification:
##$t0: leftArr[leftPointer]
##$t1: leftArr[rightPointer]

partition:
	subi $t0, $a0, 4
	addi $t1, $a1, 0
	#Get address of array
	la $t2, arr

	loopLeftPointer:
		addi $t0, $t0, 4
		lw $t4, 0($t0)
		bge $t4, $a2, loopRightPointer
		j loopLeftPointer

	loopRightPointer:
		ble $t1, $t2, endSortLoop #Compare $s1(Right pointer) and $t2(Address of first element)
		subi $t1, $t1, 4
		lw $t4, 0($t1)
		ble $t4, $a2, endSortLoop
		j loopRightPointer
		endSortLoop:
		bge $t0, $t1, outLoop

		#Swap
		lw $t2, 0($t0)
		lw $t3, 0($t1)
		sw $t2, 0($t1)
		sw $t3, 0($t0)

		j loopLeftPointer

	outLoop:
		lw $t2, 0($t0)
		lw $t3, 0($a1)
		sw $t2, 0($a1)
		sw $t3, 0($t0)
		addi $v0, $t0, 0
		jr $ra

quickSort:
	ble $a1, $a0, endQuickSort
	lw $a2, 0($a1)

	addi $s0, $ra, 0
	jal partition
	#Push to stack
	subi $sp, $sp, 12
	sw $s0, 0($sp)
	sw $v0, 4($sp)
	sw $a1, 8($sp)

	subi $a1, $v0, 4
	jal quickSort

	#Pop stack
	lw $v0, 4($sp)
	lw $a1, 8($sp)

	addi $a0, $v0, 4
	jal quickSort

	lw $ra, 0($sp)
	addi $sp, $sp, 12

	endQuickSort:
	jr $ra


################
###Write File###
################
intToString:
	beq $a0, $0, isZero
	li $t0, 10
	addi $t2, $sp, 0#Start address of stack
	loopDiv:
	beq $a0, $0, getDataFromStack
	div $a0, $t0
	mfhi $t1
	mflo $a0
	addi $t1, $t1, '0'
	subi $sp, $sp, 1
	sb $t1, 0($sp)

	j loopDiv

	getDataFromStack:
		beq $sp, $t2, done
		lb $t1, 0($sp)
		addi $sp, $sp, 1
		sb $t1, 0($a1)
		addi $a1, $a1, 1
		j getDataFromStack

	isZero:
		li $t0, '0'
		sb $t0, 0($a1)
		addi $a1, $a1, 1

	done:
		li $t0, ' '
		sb $t0, 0($a1)
		jr $ra

writeFile:
	la $s0, arr
	la $s1, arrSize
	lw $s2, 0($s1)
	addi $s3, $ra, 0
	la $a1, outputBuffer
	li $s4, ' '

	loopWriteToBuffer:
		beq $s2, $0, endLoopWrite
		subi $s2, $s2, 1
		lw $a0, 0($s0)
		addi $s0, $s0, 4
		jal intToString
		sb $s4, 0($a1)
		addi $a1, $a1, 1
		j loopWriteToBuffer

	endLoopWrite:
		subi $t0, $a1, 1

		#Open file
		li $v0, 13
		la $a0, outputFile
		li $a1, 1
		li $a2, 0
		syscall
	
		#Write file
		addi $s0, $v0, 0
		li $v0, 15
		addi $a0, $s0, 0
		la $a1, outputBuffer
		sub $a2, $t0, $a1 #Get length of buffer
		syscall

		#Close file
		li $v0, 16
		addi $a0, $s0, 0
		syscall

		jr $s3
