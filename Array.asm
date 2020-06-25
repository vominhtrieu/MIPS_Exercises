.data
  inputSize: .asciiz "Nhap vao so phan tu (lon hon 0) cua mang: "
  inputMsg: .asciiz "Nhap phan tu "
  inputMsgEnd: .asciiz ": "
  menu1: .asciiz "1. Xuat ra cac phan tu\n"
  menu2: .asciiz "2. Tinh tong cac phan tu\n"
  menu3: .asciiz "3. Liet ke cac phan tu la so nguyen to\n"
  menu4: .asciiz "4. Tim max\n"
  menu5: .asciiz "5. Tim phan tu co gia tri x (nguoi dung nhap vao) trong mang\n"
  menu6: .asciiz "6. Thoat chuong trinh\n"
  endln: .asciiz "\n"
  optionMsg: .asciiz "Nhap lua chon: "
  option1Msg: .asciiz "Cac phan tu cua mang:\n"
  option2Msg: .asciiz "Tong cac phan tu: "
  option3Msg: .asciiz "Cac phan tu la so nguyen to:\n"
  option4Msg: .asciiz "Phan tu lon nhat trong mang: "
  option5Msg: .asciiz "Phan tu can tim la phan tu thu "
  option5InputMsg: .asciiz "Nhap gia tri x can tim: "
  option5MissingMsg: .asciiz "Khong co gia tri ban can tim trong mang!"
  option6Msg: .asciiz "Ban se thoat khoi chuong trinh."
  invalidOption: .asciiz "Lua chon khong hop le! Vui long chon lai.\n"
  arrBaseAddr: .word 0
  arrSize: .word 0
.text
.globl main
  main:
  #input array's size
  SizeLoop:
    la $a0, inputSize
    li $v0, 4
    syscall
  
    li $v0, 5
    syscall
    ble $v0, 0, SizeLoop

  la $a0, arrSize  #store the array's size
  sw $v0, ($a0)
  #create Array
  sll $a0, $s0, 2 #the number of bytes of the array = size * 4
  li $v0, 9
  syscall

  la $a0, arrBaseAddr	#store the base address in $s1
  sw $v0, ($a0)
  li $t0, 0 #index of array
  InputLoop:
    move $a1, $t0
    jal printInputMsg

    li $v0, 5
    syscall

    lw $s0, arrSize
    lw $s1, arrBaseAddr

    sll $t1, $t0, 2
    addu $t2, $t1, $s1
    sw $v0, ($t2)
    addi $t0, $t0, 1
    bne $t0, $s0, InputLoop
  
  #show menu
  Menu:
    li $v0, 4
    la $a0, menu1
    syscall
    la $a0, menu2
    syscall
    la $a0, menu3
    syscall
    la $a0, menu4
    syscall
    la $a0, menu5
    syscall
    la $a0, menu6
    syscall

    la $a0, optionMsg
    syscall
    li $v0, 5
    syscall

    move $s2, $v0  #store user's option in $s2
  
  beq $s2, 1, Option1
  beq $s2, 2, Option2
  beq $s2, 3, Option3
  beq $s2, 4, Option4
  beq $s2, 5, Option5
  beq $s2, 6, Option6
  la $a0, invalidOption
  li $v0, 4
  syscall
  j Menu
  
  Option1:
    la $a0, option1Msg
    li $v0, 4
    syscall
    lw $a1, arrBaseAddr
    lw $a2, arrSize
    jal printArray 
    j Menu

  Option2:
    la $a0, option2Msg
    li $v0, 4
    syscall
    lw $a1, arrBaseAddr
    lw $a2, arrSize
    jal calArraySum
    move $a0, $v0
    li $v0, 1
    syscall
    la $a0, endln
    li $v0, 4
    syscall
    j Menu

  Option3:
    la $a0, option3Msg
    li $v0, 4
    syscall
    lw $a1, arrBaseAddr
    lw $a2, arrSize
    jal printPrimeNumber
    j Menu

  Option4:
    la $a0, option4Msg
    li $v0, 4
    syscall
    lw $a1, arrBaseAddr
    lw $a2, arrSize
    jal findMax
    move $a0, $v0
    li $v0, 1
    syscall
    la $a0, endln
    li $v0, 4
    syscall
    j Menu

  Option5:
    la $a0, option5InputMsg
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    add $a0, $0, $v0
    lw $a1, arrBaseAddr
    lw $a2, arrSize
    jal findValue
    add $s0, $0, $v0

    beq $v0, -1, xNotFound
    la $a0, option5Msg
    li $v0, 4
    syscall
    add $a0, $0, $s0
    li $v0, 1
    syscall
    xNotFound:
      la $a0, option5MissingMsg
      li $v0, 4
      syscall

    la $a0, endln
    li $v0, 4
    syscall
    j Menu

  Option6:
    la $a0, option6Msg
    li $v0, 4
    syscall
    li $v0, 12
    syscall
    j Exit

  printInputMsg:  #result: inputMsg + $a1 + inputMsgEnd
    la $a0, inputMsg
    li $v0, 4
    syscall
    move $a0, $a1
    li $v0, 1
    syscall
    la $a0, inputMsgEnd
    li $v0, 4
    syscall
    jr $ra

  printArray: #function for option 1, arguments: $a1 = base address, $a2 = size
    li $t0, 0
    PrintFullArrLoop:
      sll $t1, $t0, 2
      addu $t2, $t1, $a1
      lw $a0, ($t2)
      li $v0, 1
      syscall

      la $a0, endln
      li $v0, 4
      syscall

      addi $t0, $t0, 1
      bne $t0, $a2, PrintFullArrLoop
    jr $ra

  calArraySum: #function for option 2, return in $v0
    li $t0, 0
    li $v0, 0
    SumLoop:
      sll $t1, $t0, 2
      addu $t2, $t1, $a1
      lw $t3, ($t2)
      add $v0, $v0, $t3

      addi $t0, $t0, 1
      bne $t0, $a2, SumLoop
    jr $ra

  printPrimeNumber:  #funtion for option 3
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $s0, 0
    PrintPrimeLoop:
      sll $t1, $s0, 2
      addu $t2, $t1, $a1
      lw $a0, ($t2)
      jal isPrime
      move $v1, $v0
      beq $v1, 0, NoPrint
      li $v0, 1
      syscall
      la $a0, endln
      li $v0, 4
      syscall
      NoPrint:
      addi $s0, $s0, 1
      bne $s0, $a2, PrintPrimeLoop
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

  isPrime:  #argument: $a0, return 0 or 1 in $v0
    blt $a0, 2, False
    li $t0, 2
    srl $t1, $a0, 1
    PrimeLoop:
      bgt $t0, $t1, True
      div $a0, $t0
      mfhi $t2
      beq $t2, 0, False
      addi $t0, $t0, 1
      j PrimeLoop
    True: 
      li $v0, 1
      jr $ra
    False:
      li $v0, 0
      jr $ra

  findMax:  #function for option 4, return max in $v0
    li $t0, 0
    li $v0, 0
    MaxLoop:
      sll $t1, $t0, 2
      addu $t2, $t1, $a1
      lw $t3, ($t2)
      ble $t3, $v0, Less
      add $v0, $0, $t3
      Less:
      addi $t0 ,$t0, 1
      bne $t0, $a2, MaxLoop
    jr $ra

  findValue:  #function for option 5, x in $a0
    li $v0, 0
    FindingLoop:
      sll $t1, $v0, 2
      addu $t2, $t1, $a1
      lw $t3, ($t2)
      beq $t3, $a0, finishFind
      addi $v0, $v0, 1
      bne $v0, $a2, FindingLoop
    addi $v0, $0, -1
    finishFind:
    jr $ra


  Exit:  #exit program
    li $v0, 10
    syscall
