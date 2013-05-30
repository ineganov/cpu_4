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

sdma_read:
  lui $v1, 0x101
  sll $a1, $a1, 1    # num bytes = num_words * 2
  addu $a1, $a0, $a1 # compute the final address
  addiu $a1, $a1, -2 # compute the final address

                     # by now, we have starting addr in a1 
                     # and finishing addr in a2
  sw  $v1, 12($gp) # request the very first DM9K read cycle
  nop
  nop
  nop               # wait for the appropriate time
  lw  $v0, 12($gp) # load first half-word

__sdma_read_cycle:  # the whole cycle takes 6 clock periods. 
  sw  $v1, 12($gp) # request DM9K read cycle
  sh  $v0, 0($a0)   # store previous value to buffer
  addiu $a0, $a0, 2 # increment buffer pointer
  bne $a0, $a1, __sdma_read_cycle
  lw  $v0, 12($gp) #load new half-word

  sh  $v0, 0($a0)   # don't forget to store the final word to buffer

  jr $ra
  nop

sdma_write:
  lui $t0, 0x111
  sll $a1, $a1, 1    # num bytes = num_words * 2
  addu $a1, $a0, $a1 # compute the final address

  lhu $v1, 0($a0)    # load first half-word

__sdma_write_cycle:  # the whole cycle takes 5 clock periods. 
  or  $v0, $v1, $t0  # or with 0x01110000
  addiu $a0, $a0, 2 
  lhu $v1, 0($a0)    # load new half-word
  bne $a0, $a1, __sdma_write_cycle
  sw  $v0, 12($gp)  # request DM9K write cycle

  or  $v0, $v1, $t0  # or with 0x01110000
  sw  $v0, 12($gp)  # request DM9K write cycle for the last word in buffer

  jr $ra
  nop
  