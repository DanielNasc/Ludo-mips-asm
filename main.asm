.data	
#k	initial_pos	.word	
	pos:	.word	0
.text
	.globl main
	main:
		# 256 x 128 cells (2x2 pixels)
		jal 	background

		jal	init_cells

		jal create_pieces
		jal	create_teams
		
		move $a0, $v0
		li $a1, 2
		jal set_selected
		
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
