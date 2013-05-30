.globl _start
 
.org 0
.set noreorder


_start:
   li   $a0, 0x40
   mtc0 $a0, $14 #set "return" address

   li   $a2, 40   #counter compare value

   move $a0, $a2
   mtc0 $a0,  $11 #set timer compare
   mtc0 $zero, $9 #reset counter

   
   li $a0, 0x8001
   mtc0 $a0, $12   #enable timer interrupt

   li $a0, 1
   li $a1, 0x10000
   sw $a0, 0($a1) 

   eret
   nop

.org 0x40
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

