.globl _start
 
.org 0
.set noreorder

_start:
#   li $v0, 0x80000000
   li $a0, 3
   li $a1, 2
   li $a2, 0xFFFFFFFF
   li $a3, 0x7FFFFFFF
   mult $zero, $zero
   madd $a0, $a1
   madd $a0, $a1
   madd $a0, $a1

#   mult  $a2, $a2
   add  $t0, $a0, $a1
   mflo $v0
   mfhi $v1
   sub $t1, $a0, $a1
   sub $t2, $a0, $a2
   add $t3, $a2, $a2
   sub $t4, $a3, $a3
   addu $t4, $a3, $a3
   addi $t5, $v0,  1
   addi $t6, $v0, -1


.org 0x60

_stop:
   j _stop
   addiu $a0, $a0, 1

.org 0x100
   mfc0 $v1, $13 # Cause --> v1
   li $k0, 40
   addu $k0, $k0, $v0
   mtc0 $k0, $9   #reset counter
   mtc0 $k0, $11   #set compare, reset interrupt
   addiu $v0, 1
   nop
   nop
   nop
   nop
   nop
   nop
   eret
