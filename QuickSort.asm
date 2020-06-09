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
.text
.globl main
main:
jal readFile
#Read number of elements
la $a0, inputBuffer
jal atoi
addi $s0, $v0, 0
la $t0, arrSize
sw $s0, 0($t0)

jal toArray
jal print
li $v0, 10
syscall

#####################  
#Load Array to Memory
#####################
    
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

#parse string to integer
atoi:
    or      $v0, $zero, $zero   # num = 0
    or      $t1, $zero, $zero   # isNegative = false
    lb      $t0, 0($a0)
    bne     $t0, '+', .isp      # consume a positive symbol
    addi    $a0, $a0, 1
.isp:
    lb      $t0, 0($a0)
    bne     $t0, '-', .num
    addi    $t1, $zero, 1       # isNegative = true
    addi    $a0, $a0, 1
.num:
    lb      $t0, 0($a0)
    slti    $t2, $t0, 58        # *str <= '9'
    slti    $t3, $t0, '0'       # *str < '0'
    beq     $t2, $zero, .done
    bne     $t3, $zero, .done
    sll     $t2, $v0, 1
    sll     $v0, $v0, 3
    add     $v0, $v0, $t2       # num *= 10, using: num = (num << 3) + (num << 1)
    addi    $t0, $t0, -48
    add     $v0, $v0, $t0       # num += (*str - '0')
    addi    $a0, $a0, 1         # ++num
    j   .num
.done:
    beq     $t1, $zero, .out    # if (isNegative) num = -num
    sub     $v0, $zero, $v0
.out:
    jr      $ra         # return
    
#String to array
toArray:
addi $s2, $ra, 0
la $s3, arr
la $a0, inputBuffer
jal atoi
addi $a0, $a0, 1
addi $s1, $v0, 0

loopInput:
beq $s1, 0, endLoop
jal atoi
addi $a0, $a0, 1
addi $s1, $s1, -1
sw $v0, 0($s3)
addi $s3, $s3, 4
j loopInput

endLoop:
addi $ra, $s2, 0
jr $ra

print:
la $t1, arrSize
la $t2, arr
lw $t1, 0($t1)
li $v0, 1

loopPrint:
beq $t1, $0, endLoopPrint
addi $t1, $t1, -1
lw $a0, 0($t2)
syscall
addi $t2, $t2, 4
j loopPrint

endLoopPrint:
jr $ra


