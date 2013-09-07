.globl _start
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
   addiu $sp, $sp, -124

   sw $k0, 120($sp)
   sw $k1, 116($sp)
   sw $at, 112($sp)
   sw $v0, 108($sp)
   sw $v1, 104($sp)
   sw $a0, 100($sp)
   sw $a1,  96($sp)
   sw $a2,  92($sp)
   sw $a3,  88($sp)
   sw $t0,  84($sp)
   sw $t1,  80($sp)
   sw $t2,  76($sp)
   sw $t3,  72($sp)
   sw $t4,  68($sp)
   sw $t5,  64($sp)
   sw $t6,  60($sp)
   sw $t7,  56($sp)
   sw $s0,  52($sp)
   sw $s1,  48($sp)
   sw $s2,  44($sp)
   sw $s3,  40($sp)
   sw $s4,  36($sp)
   sw $s5,  32($sp)
   sw $s6,  28($sp)
   sw $s7,  24($sp)
   sw $t8,  20($sp)
   sw $t9,  16($sp)
   sw $gp,  12($sp)
   sw $sp,   8($sp)
   sw $fp,   4($sp)
   sw $ra,   0($sp)

   move $a0, $k0
   move $a1, $k1
   jal interrupt
   move $a2, $sp

   lw $k0, 120($sp)
   lw $k1, 116($sp)
   lw $at, 112($sp)
   lw $v0, 108($sp)
   lw $v1, 104($sp)
   lw $a0, 100($sp)
   lw $a1,  96($sp)
   lw $a2,  92($sp)
   lw $a3,  88($sp)
   lw $t0,  84($sp)
   lw $t1,  80($sp)
   lw $t2,  76($sp)
   lw $t3,  72($sp)
   lw $t4,  68($sp)
   lw $t5,  64($sp)
   lw $t6,  60($sp)
   lw $t7,  56($sp)
   lw $s0,  52($sp)
   lw $s1,  48($sp)
   lw $s2,  44($sp)
   lw $s3,  40($sp)
   lw $s4,  36($sp)
   lw $s5,  32($sp)
   lw $s6,  28($sp)
   lw $s7,  24($sp)
   lw $t8,  20($sp)
   lw $t9,  16($sp)
   lw $gp,  12($sp)
   lw $sp,   8($sp)
   lw $fp,   4($sp)
   lw $ra,   0($sp)   

   mtc0  $k0, $14
   addiu $sp, $sp, 124

   eret
   nop


_break_stop:         #...and hang up
   j _break_stop
   nop



#  mfc0 $a0, $16     #get memory size in bytes to reference HW
#  srl  $k1, 8
#  sw   $k1, 0($a0)  #show cause on leds
