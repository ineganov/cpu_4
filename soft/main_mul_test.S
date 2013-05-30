.globl _start
 
.org 0
.set noreorder

_start:
   li $a0, 2
   li $a1, 5
   mult $a0, $a1
   nop
   mflo $a2
   li $a0, -12
   li $a1, 3
   mult $a0, $a1
   nop
   mflo $a2


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
