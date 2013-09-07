.globl _start
.globl main
.globl delay
 
.org 0
.set noreorder


_start:
   mfc0 $sp, $16     #get memory size in bytes
   nop
   move $gp, $sp     #Set $gp = $mem_size (could be used to reference HW) 
   addi $sp, $sp, -4 #Stack pointer = $mem_size-4

   la   $k1, main    #get int main() address
   mtc0 $k1, $14     #set it as a return from reset exception

   li $k1, 0x0101
   mtc0 $k1, $12     #enable button interrupt

   eret              #jump to main and exit exception mode
   nop

main:
   li $a0, 1025
   li $a1, 64
   div  $a0, $a1
#   mflo  $a0
   addiu $a0, 1
   mfhi  $a1



_and_stop:
   j _and_stop
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

_int_stop:
   j _int_stop
   nop
