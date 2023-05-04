.text
	init_normal_line:
		# a0 - start pos
		# a1 - start address
		# a2 - update value
		# a3 - amount
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$s0,	0		# counter
		move	$s1,	$a0		# pos
		move	$s2,	$a1		# memory address
		move	$s3,	$a2		# update value
		andi	$s4,	$a3, 	0xF	# amount (cells)
		srl	$a3,	$a3,	4	
		andi	$s6,	$a3,	0xF	# type
		srl	$a3,	$a3,	4
		move	$s7,	$a3		# team
		
		
		walk_init_cells:
			sw	$s1,	($s2)
			
			# a0 -> team
			# a1 -> coord
			# a2 -> type
			# a3 -> amount (pieces)
			move	$a0,	$s7
			move	$a1,	$s1
			move	$a2,	$s6
			li	$a3,	0
			jal	cell
			
			addi	$s0,	$s0,	1
			add	$s1,	$s1,	$s3
			addi	$s2,	$s2,	4
			
			blt	$s0,	$s4,	walk_init_cells
		
		sub	$v0,	$s1,	$s3
		move	$v1,	$s2
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
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
		li	$a0,	0x3403
		move	$a1,	$t0
		li	$a2,	0x0008
		li	$a3,	6
		jal	init_normal_line
		
		# go up a cell
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0
		li	$a3,	1
		jal	init_normal_line
		
		# go right and go up 6 cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	6
		jal 	init_normal_line
		
		# go right and go two cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x00008
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	2
		jal	init_normal_line
		
		# go down and go five cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	5
		jal	init_normal_line
		
		# go right one cell
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0
		li	$a3,	1
		jal	init_normal_line
		
		# go down and go right 6 cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	6
		jal 	init_normal_line

		# go down and go two cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	2
		jal	init_normal_line

		# go left and go five cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	5
		jal	init_normal_line

		# go down one cell
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1 
		li	$a2,	0
		li	$a3,	1
		jal	init_normal_line

		# go left and go down 6 cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	6
		jal 	init_normal_line

		# go left and go two cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	2
		jal	init_normal_line

		# go up and go five cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	5
		jal	init_normal_line

		# go left one cell
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0
		li	$a3,	1
		jal	init_normal_line

		# go up and go left 6 cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	6
		jal 	init_normal_line

		# go one cell up
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0
		li	$a3,	1
		jal	init_normal_line
		
		# COLORFULLLL
		# a0 - start pos
		# a1 - start address
		# a2 - update value
		# a3 -	team type amount

		# go right and down and go right 1
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0808
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	0x231
		jal	init_normal_line
		
		# go up and go right 6
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	0x216
		jal	init_normal_line
		
		# jump 6 up and print 1
		move	$a0,	$v0
		subi	$a0,	$a0,	0x3000
		move	$a1,	$v1
		li	$a3,	0x331
		jal	init_normal_line

		# go up and go right 6	
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	0x316
		jal	init_normal_line

		# jump 6 right and print 1
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0030
		move	$a1,	$v1
		li	$a3,	0x431
		jal	init_normal_line
		
		# go 7 for the bottom
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	0x416
		jal	init_normal_line

		# jump 6 down and print 1
		move	$a0,	$v0
		addi	$a0,	$a0,	0x3000
		move	$a1,	$v1
		li	$a3,	0x131
		jal	init_normal_line
		
		# go 8 for the bottom
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	0x116
		jal	init_normal_line

		jal	 entry_index
		
		jal 	create_crosspieces
		
		jal	draw_reserve_zones
		jal	players_numbers
		jal	center_board

		# get return address and go back
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		
		jr	$ra
		
