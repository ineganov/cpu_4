.globl _start
 
.org 0
.set noreorder


_start:
   li   $a0, 0x60
   mtc0 $a0, $14 #set "return" address
   li   $a0, 0xDEADBEEF
   mtc0 $a0, $23

   li   $a2, 4000000   #counter compare value
   li   $t0, 0x3FFFFFF #leds and value

   move $a0, $a2
   mtc0 $a0,  $11 #set timer compare
   mtc0 $zero, $9 #reset counter

   
   li $a0, 0x8001
   mtc0 $a0, $12   #enable timer interrupt

   li $a0, 1
   li $a1, 0x8000
   sw $a0, 4($a1) 

   li $v0, 0xDEADBEEF
   sw $v0, 8($a1)

   eret
   nop

.org 0x60
_stop:
   j _stop
   nop



.org 0x100
   sll $a0, $a0, 1
   and  $a0, $t0, $a0
   bnez $a0, _write_leds
   nop
   li $a0, 1
_write_leds:
   lw  $t1, 4($a1)
   xor $a0, $t1, $a0
   sw  $a0, 4($a1)

   move $k0, $a2
   mtc0 $k0,  $11
   mtc0 $zero, $9
   eret
   nop

_break_stop:
   j _break_stop
   nop

