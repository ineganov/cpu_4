.globl _start
.globl delay
.globl sdma_read
.globl sdma_write
 
.org 0
.set noreorder


_start:
   mfc0 $sp, $16     #get memory size in bytes
   nop
   move $gp, $sp     #Set $gp = $mem_size (could be used to reference HW) addi $sp, $sp, -4 #Stack pointer = $mem_size-4

   la   $k1, main #get int main() address
   mtc0 $k1, $14     #set it as a return from reset exception

   eret              #jump to main and exit exception mode
   nop

delay:
   addiu $a0, -1
   nop
   bnez  $a0, delay
   nop
   jr $ra
   nop

.org 0x100
   mfc0 $k0, $14     #get EPC
   mfc0 $k1, $13     #get cause
   mfc0 $a0, $16     #get memory size in bytes to reference HW
   srl  $k1, 2
   andi $k1, 0x1F
   sw   $k1, 4($a0)  #show cause on leds
   sw   $k0, 8($a0)  #show EPC on seven-segs

_break_stop:         #...and hang up
   j _break_stop
   nop

