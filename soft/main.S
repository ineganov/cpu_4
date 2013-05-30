.globl _start
 
.org 0
.set noreorder


_start:
   li   $a0, 0x80
   mtc0 $a0, $14 #set "return" address

   li   $a2, 30   #counter compare value

   move $a0, $a2
   mtc0 $a0,  $11 #set timer compare
   mtc0 $zero, $9 #reset counter

   
   li $a0, 0x8001
   mtc0 $a0, $12   #enable timer interrupt

   li $a0, 1
   li $a1, 0x10000
   sw $a0, 0($a1) 

   li $t0, 0x01020304
   li $t1, 0x10203040
   sw $t0, 0x1000
   sw $t1, 0x1004
   lw $t2, 0x1000
   lw $t3, 0x1004
   or $t4, $t3, $t2
   eret
   nop

.org 0x80
   mult $zero, $zero
   li $a1, 3
   li $a2,-2
   li $a3, -4
   madd $a2, $a3
#   mult $a1, $a2
_stop:
   j _stop
   nop



.org 0x100
   sll $a0, $a0, 1
   andi $a0, $a0, 0xFF
   bnez $a0, _write_leds
   nop
   li $a0, 1
_write_leds:
   sw $a0, 0($a1)

   move $k0, $a2
   mtc0 $k0,  $11
   mtc0 $zero, $9
   eret
   nop

_break_stop:
   j _break_stop
   nop

