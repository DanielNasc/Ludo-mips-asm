.data	
#k	initial_pos	.word	
	pos:	.word	0
.text
	.globl main
	main:
		# 256 x 128 cells (2x2 pixels)
		jal 	background

		jal	init_cells

		subi $sp, $sp, 4
		sw $v0, ($sp)	# save cells address

		jal create_pieces

		subi $sp, $sp, 4
		sw $v0, ($sp)	# save pieces address

		jal	create_teams

		# $a0 = team address
        # $a1 = cells address
        # $a2 = pieces address
		move $a0,	$v0
		lw $a1, 4($sp)
		lw $a2, ($sp)
		jal select_
				
		jal	dice
		
		jal	roll_die
		li	$v0,	1
		syscall
		
		la	$a0,	pos
		li	$a1,	1
		li	$a2,	19
		
		sw	$a1,	($a0)
		sw	$a1,	4($a0)
		
		jal	update_pos
	
		end:
		li	$v0,	10
		syscall
