.text
	init_normal_line:
		# a0 - start pos
		# a1 - start address
		# a2 - update value
		# a3 - amount
		li	$t0,	0	# cell_index
		move	$t1,	$a0	# current position
		move	$t3,	$a1	# current address
		
			walk_and_init_line:
				sw	$t1,	($t3)
				
				addi	$t0,	$t0,	1
				addi	$t3,	$t3,	4
				add	$t1,	$t1,	$a2
				
				ble	$t0,	$a3,	walk_and_init_line
				
		move	$v0,	$t1
		sub	$v0,	$v0,	$a2
		
		move	$v1,	$t3
		
		jr	$ra
				

	.globl	init_cells
	init_cells:
		# Store return addresss on stack
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
	
		# Allocate Memory
		li	$a0,	384	# 96 cells * 4 addresses/cell
		li	$v0,	9
		syscall
		
		# Update each cell
		move	$t0,	$v0
		
		# Cells beetween 0 - 56 -> Normal
		# a0 - start pos
		# a1 - start address
		# a2 - update value
		# a3 - amount
		li	$a0,	0x3703
		move	$a1,	$t0
		li	$a2,	0x0007
		li	$a3,	6
		
		jal	init_normal_line
		
		# get return address and go back
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
			
		jr	$ra