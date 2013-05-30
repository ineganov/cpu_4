.globl _start
 
.org 0
.set noreorder

_start:
   li $k0, 0x60
   mtc0 $k0, $14 #EPC
   li   $k0, 0           #index = 0 
   mtc0 $k0, $0
   li   $k0, 0x00002     #EntryLO: PFN=0; not Dirty, Valid, not global 
   mtc0 $k0, $2     
   li   $k0, 0x00000001  #EntryHI: VPN=0x000000; ASID=1
   mtc0 $k0, $10         
   tlbwi

   li   $k0, 0x8001 #write to status to enable timer interrupt
   mtc0 $k0, $12

   li $a0, 0
   li $v0, 0

   li   $k0, 41
   mtc0 $k0, $9   #reset counter
   mtc0 $k0, $11   #set compare, reset interrupt
   eret
   li $fp, 1
   li $fp, 2
   li $fp, 3
   li $fp, 4
   li $fp, 5
   li $fp, 6
   li $fp, 7

.org 0x60

_stop:
   j _stop
   addiu $a0, $a0, 1

.org 0x100
#   mfc0 $v1, $13 # Cause --> v1
   li $k0, 10
   addu $k0, $k0, $v0
   mtc0 $k0, $9   #reset counter
   mtc0 $k0, $11   #set compare, reset interrupt
   addiu $v0, 1
   eret
   li $fp, 11
   li $fp, 12
   li $fp, 13
   li $fp, 14
   li $fp, 15
   li $fp, 16
   li $fp, 17

