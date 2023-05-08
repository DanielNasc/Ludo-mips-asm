.data 
	update_team_reserve_pos:	0x0000,	-0x50,	-0x5000,	0x0050
.text
	init_normal_line:
		# a0 - start pos
		# a1 - start address
		# a2 - update value
		# a3 - amount
		subi	$sp,	$sp,	36
		sw	$ra,	($sp)
		sw	$s0,	4($sp)
		sw	$s1,	8($sp)
		sw	$s2,	12($sp)
		sw	$s3,	16($sp)
		sw	$s4,	20($sp)
		sw	$s5,	24($sp)
		sw	$s6,	28($sp)
		sw	$s7,	32($sp)
		
		li	$s0,	0		# counter
		move	$s1,	$a0		# pos
		move	$s2,	$a1		# memory address
		move	$s3,	$a2		# update value
		andi	$s4,	$a3, 	0xF	# amount (cells)
		move 	$t0,	$a3
		srl	$t0,	$t0,	4
		andi	$s6,	$t0,	0xF	# type
		srl	$t0,	$t0,	4
		move	$s7,	$t0		# team

		move	$s5,	$s7
		sll 	$s5,	$s5,	4
		add		$s5,	$s6,	$s5
		sll		$s5,	$s5,	2
		# Now s5 contains type, team and amount (pieces)
		
		walk_init_cells:
			sll	$t1,	$s5,	16
			add	$t2,	$s1,	$t1
			sw	$t2,	($s2)
			
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
		lw	$s0,	4($sp)
		lw	$s1,	8($sp)
		lw	$s2,	12($sp)
		lw	$s3,	16($sp)
		lw	$s4,	20($sp)
		lw	$s5,	24($sp)
		lw	$s6,	28($sp)
		lw	$s7,	32($sp)
		addi	$sp,	$sp,	36
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
		
		# go right and go up 4 cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	4
		jal 	init_normal_line
		
		# go up and go up 1 entry cell
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	0x331
		jal 	init_normal_line
		
		# go up and go up 1 cell
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	1
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
		
		# go down and go right 4 cells
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	4
		jal 	init_normal_line
		
		# go right and go right 1 cell
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	0x431
		jal 	init_normal_line
		
		# go right and go right 1 cell
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	1
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

		# go left and go down 4 cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	4
		jal 	init_normal_line
		
		# go down and go down 1 entry cell
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	0x131
		jal 	init_normal_line
		
		# go down and go down 1 cell
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	1
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

		# go up and go left 4 cells
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0800
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	4
		jal 	init_normal_line
		
		# go left and go left 1 entry cell
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	0x231
		jal 	init_normal_line
		
		# go left and go left 1 cell
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	1
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

		# go right and go right 6
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0008
		li	$a3,	0x216
		jal	init_normal_line
		
		# jump 6 up, go right and go down 6	
		move	$a0,	$v0
		subi	$a0,	$a0,	0x3000
		addi	$a0,	$a0,	0x0008
		move	$a1,	$v1
		li	$a2,	0x0800
		li	$a3,	0x316
		jal	init_normal_line

		# jump 6 right, go down and go left 6
		move	$a0,	$v0
		addi	$a0,	$a0,	0x0830
		move	$a1,	$v1
		li	$a2,	-0x0008
		li	$a3,	0x416
		jal	init_normal_line

		# jump 6 down, go left and go 6 up
		move	$a0,	$v0
		subi	$a0,	$a0,	0x0008
		addi	$a0,	$a0,	0x3000
		move	$a1,	$v1
		li	$a2,	-0x0800
		li	$a3,	0x116
		jal	init_normal_line
		
		li	$s0,	0x0012			# update x rate
		la	$s2,	update_team_reserve_pos		# counter
		move	$s3,	$v0	
		addi	$s3,	$s3,	0x1820
		move	$s4,	$v1
		li	$s5,	0	# team
		li	$s6,	0	# hcounter
		li	$s7,	0	# vcounter
		
		init_reserve:
			move	$a0,	$s3		# cell pos
			move	$a1,	$v1		# cell address
			move	$a2,	$s0		# udpdate rate
			move	$a3,	$s5		#
			sll	$a3,	$a3,	8	# move current number to the correct pos 
			addi	$a3,	$a3,	0x142	# type -> reserve | cells amount -> 2
			jal	init_normal_line
			
			#addi	$s6,	$s6,	1	# hcounter++
			
			#blt	$s6,	2,	init_reserve	
			beq	$s7,	1,	jump_to_next
			
			addi	$s3,	$s3,	0x1000
			sll	$t1,	$s5,	2
			add	$s1,	$s1,	$t1
			addi	$s7,	$s7,	1	# vcounter++
			j		init_reserve
			
			jump_to_next:
			bge	$s5,	4,	end_reserve	
			subi	$s3,	$s3,	0x1000
			add	$s2,	$s2,	4
			lw	$t3,	($s2)
			add	$s3,	$s3,	$t3
			addi	$s5,	$s5, 	1
			li	$s6,	0
			li	$s7,	0
			j	init_reserve
			
			end_reserve:
			
		jal	 entry_index
		
		jal 	create_crosspieces
		
		jal	draw_reserve_zones
		jal	players_numbers
		jal	center_board

		# get return address and go back
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		
		jr	$ra	
		
	.globl filter_cell_team
	filter_cell_team:
		# a0 - cell address

		lw	$t0,	($a0)

		srl $t0,	$t0,	22
		andi	$t0,	$t0,	0xF

		# return
		move $v0,	$t0
		jr	$ra

	
	.globl filter_cell_type
	filter_cell_type:
		# a0 - cell address

		lw	$t0,	($a0)

		srl $t0,	$t0,	18
		andi	$t0,	$t0,	0x0F

		# return
		move $v0,	$t0
		jr	$ra

	
	.globl filter_cell_amount
	filter_cell_amount:
		# a0 - cell address

		lw	$t0,	($a0)

		srl $t0,	$t0,	16
		andi $t0,	$t0,	0x03

		# return
		move $v0,	$t0
		jr	$ra

	# .globl filter_cell_team
	# filter_cell_team

	.globl filter_cell_pos
	filter_cell_pos:
		# a0 - cell address

		lw	$t0,	($a0)

		andi	$t0,	$t0,	0xFFFF

		# return
		move $v0,	$t0
		jr	$ra


	.globl walk_cells
	walk_cells:
		# a0 - cell address
		# a1 - cell pos
		# a2 - how many cells to walk
		# a3 - team

		li $s0, 0 # counter
		move $s1, $a0 # first cell address
		move $s2, $a1 # index in cells array
		move $s3, $a2 # how many cells to walk

		loop_walk_cells:
			beq $s0, $s3, end_walk_cells
			
			# victory zone -> can overflow
			jal filter_cell_type
			sne $t0, $v0, 0x01
			beq $t0, $zero, end_walk_cells
			sne $t0, $v0, 0x03
			beq $t0, $zero, end_walk_cells

			sll $t0, $s2, 2 # index in cells array * 4 = offset
			add $s4, $t0, $s1	# cell address + offset
			lw $s5, ($s4) # cell value

			move $a0, $s5 
			# if amount > 1 and team != a3, then cannot walk
			jal filter_cell_amount
			sgt $s6, $v0, 1 # if amount > 1
			move $a0, $s5
			jal filter_cell_team
			sne $t1, $v0, $a3 # if team != a3
			and $t0, $s6, $t1 # if amount > 1 and team != a3
			bne $t0, $zero, cannot_walk
			
			# go to next cell
			# if overflow, the normal cells back to the first cell
			addi $s0, $s0, 1
			addi $s2, $s2, 1

			# if overflow and the piece is not in the victory zone, then reset the index
			slti $t2, $s2, 56
			bne $t2, $zero, loop_walk_cells
			jal filter_cell_type
			sne $t0, $v0, 0x01
			beq $t0, $zero, end_walk_cells
			sne $t0, $v0, 0x03
			beq $t0, $zero, end_walk_cells
			subi $s2, $s2, 56

			j loop_walk_cells

		end_walk_cells:
			li	$v0,	1
			jr	$ra

		cannot_walk:
			li	$v0,	0
			jr	$ra			
