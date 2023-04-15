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
				
			blt	$t0,	$a3,	walk_and_init_line
				
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
		
		# first row (6 cells)
		li	$a0,	0x3703
		move	$a1,	$t0
		li	$a2,	0x0007
		li	$a3,	6
		jal	init_normal_line
		
		# go up a cell
		move	$t1,	$v0
		subi	$t1,	$t1,	0x0700
		move	$t2,	$v1
		sw	$t1,	($t2)
		
		# go right and go up 6 cells
		move	$a0,	$t1
		addi	$a0,	$a0,	0x0007
		move	$a1,	$v1
		addi	$a1,	$a1,	4
		li	$a2,	-0x0700
		jal 	init_normal_line
		
		# go right and go two cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x00007
		move	$a1,	$v1
		li	$a2,	0x0007
		li	$a3,	2
		jal	init_normal_line
		
		# go down and go five cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0700
		move	$a1,	$v1
		li	$a2,	0x0700
		li	$a3,	5
		jal	init_normal_line
		
		# go right one cell
		move	$t1,	$v0
		addi	$t1,	$t1,	0x0007
		move	$t2,	$v1
		sw	$t1,	($t2)
		
		# go down and go right 6 cells
		move	$a0,	$t1
		addi	$a0,	$a0,	0x0700
		move	$a1,	$v1
		addi	$a1,	$a1,	4
		li	$a2,	0x0007
		li	$a3,	6
		jal 	init_normal_line

		# go down and go two cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0700
		move	$a1,	$v1
		li	$a2,	0x0700
		li	$a3,	2
		jal	init_normal_line

		# go left and go five cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0007
		move	$a1,	$v1
		li	$a2,	-0x0007
		li	$a3,	5
		jal	init_normal_line

		# go down one cell
		move	$t1,	$v0
		addi	$t1,	$t1,	0x0700
		move	$t2,	$v1
		sw	$t1,	($t2)

		# go left and go down 6 cells
		move	$a0,	$t1
		subi	$a0,	$a0,	0x0007
		move	$a1,	$v1
		addi	$a1,	$a1,	4
		li	$a2,	0x0700
		li	$a3,	6
		jal 	init_normal_line

		# go left and go two cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0007
		move	$a1,	$v1
		li	$a2,	-0x0007
		li	$a3,	2
		jal	init_normal_line

		# go up and go five cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0700
		move	$a1,	$v1
		li	$a2,	-0x0700
		li	$a3,	5
		jal	init_normal_line

		# go left one cell
		move	$t1,	$v0
		subi	$t1,	$t1,	0x0007
		move	$t2,	$v1
		sw	$t1,	($t2)

		# go up and go left 6 cells
		move	$a0,	$t1
		subi	$a0,	$a0,	0x0700
		move	$a1,	$v1
		addi	$a1,	$a1,	4
		li	$a2,	-0x0007
		li	$a3,	6
		jal 	init_normal_line

		# go one cell up
		move	$t1,	$v0
		subi	$t1,	$t1,	0x0700
		move	$t2,	$v1
		sw	$t1,	($t2)
		
		# get return address and go back
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
			
		jr	$ra
