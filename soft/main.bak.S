.globl _start
 
.org 0

_start:

#	li $sp, 255				#init stack pointer
#	li $gp, 0x00000000	#init global pointer
	li $a0, 0x8000001C
	mtc0 $a0, $14
	nop
	nop
	eret
	nop

	li $a0, 0xAA
	li $a1, 0xBB
	li $a2, 0xCC
	li $a3, 0xDD

	li   $k0, 1 	  	    #index = 1	
	mtc0 $k0, $0
	li   $k0, 0x00406   	 #EntryLO: PFN=1; Dirty, Valid, not global 
	mtc0 $k0, $2     
	li   $k0, 0xFFFF0001  #EntryHI: VPN=0xFFFF00; ASID=1
	mtc0 $k0, $10         
	tlbwi
	
	li   $k0, 2	     		 #index = 2
	mtc0 $k0, $0
	li   $k0, 0x0F406 	 #EntryLO: PFN=3D; Dirty, Valid, not global 
	mtc0 $k0, $2     
	li   $k0, 0xFFFF0002  #EntryHI: VPN=0xFFFF00; ASID=2
	mtc0 $k0, $10         
	tlbwi

	li   $k0, 3				 #index = 3
	mtc0 $k0, $0
	li   $k0, 0xFFF07     #EntryLO: Valid, dirty, global 
	mtc0 $k0, $2     		 
	li   $k0, 0xDDDD0000  #EntryHI: VPN=0xFFFF00;
	mtc0 $k0, $10         
	tlbwi
	nop
	nop



	li   $k0, 0  #EntryLO: ASID=0
	mtc0 $k0, $10


	li $t0, 0xFFFF0000
	lwl $t0, 0
	li $t1, 0xDDDD0000

	sw $a0, 0x0234($t1)
	sw $a1, 0x4($t1)
	sw $a2, 0x8($t1)
	sw $a3, 0xC($t1)

	sw $a0, 0x0234($t0)
	sw $a1, 0x4($t0)
	sw $a2, 0x8($t0)
	sw $a3, 0xC($t0)


	li   $k0, 1  #EntryLO: ASID=2
	mtc0 $k0, $10         #move to entry_hi

	sw $a0, 0x0($t0)
	sw $a1, 0x4($t0)
	sw $a2, 0x8($t0)
	sw $a3, 0xC($t0)
	lw $a3, 0x0($t1)
	lw $a2, 0x4($t1)
	lw $a1, 0x8($t1)
	lw $a0, 0xC($t1)


	li $fp, 0xDEAD
	li $a1, 0xF0


.set noreorder
loop:
	bne $a0, $a1, loop
	addiu $a0, 1


#	lw $a1, 12

  li $t0, 0

_stop:			#loop forever
	j _stop
	addiu $t0, 1

.org 0x200

_interrupt:
	mfc0 $k0, $13
	mfc0 $k1, $14
#	addiu $k1, $k1, -4
#	jr $k1
	eret
	nop

_proc:
	jr $ra
	addu $t7, $a1, $a0


