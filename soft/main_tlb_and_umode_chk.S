.globl _start
 
.org 0
.set noreorder

_start:
	li $k0, 0x40
	mtc0 $k0, $14 #EPC
	li   $k0, 0 	  	    #index = 0	
	mtc0 $k0, $0
	li   $k0, 0x00002   	 #EntryLO: PFN=0; not Dirty, Valid, not global 
	mtc0 $k0, $2     
	li   $k0, 0x00000001  #EntryHI: VPN=0x000000; ASID=1
	mtc0 $k0, $10         
	tlbwi
	nop
	nop
	eret

.org 0x40

	li $a0, 0
	li $a1, 1
	li $a2, 2
	li $a3, 3
	li $t0, 0xAABBCCDD

	sb $a0, 0
	sb $a1, 1
	sb $a2, 2
	sb $a3, 3
	sw $t0, 4

	lw $v0, 0

	li $v1, 0x00000000
	lw $v1, 4($v1)

_stop:
	j _stop
	addiu $a0, $a0, 10



.org 0x100
	li   $k0, 0x00006   	 #EntryLO: PFN=0; Dirty, Valid, not global 
	mtc0 $k0, $2 
	tlbwi 
	eret
