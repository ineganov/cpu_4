.globl _start
 
#.org 0x80000000
.set noreorder

_start: 
   sw $zero, 0x80010000
   li $a0, 1
   addiu $t0, $a0, 0xF0
   li $a1, 2
   addiu $t1, $a1, 0xF0
   li $a2, 3
   addiu $t2, $a2, 0xF0
   li $a3, 4
   addiu $t3, $a3, 0xF0
   nop
   nop
   nop
   nop
   nop
   nop
   sw $t3, 0x80010000
_stop:
   j _stop
   nop



.org 0x100 
   mfc0 $k0, $13   #cause
   mfc0 $k1, $8    #bad_va
   lw   $28, 0($k1)
   srl  $k0, $k0, 2
   andi $k0, $k0, 0x1F


_estop: 
   j _estop
   nop

