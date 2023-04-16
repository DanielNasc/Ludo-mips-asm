.data
	msg:	.asciiz	"\nHello, Ludo!\n"
	
	pos:	.word	0
.text
	.globl main
	main:
		# 256 x 128 cells (2x2 pixels)
		jal 	background
		jal 	board

		jal	init_cells
		jal 	create_pieces
	
		
		# How to create a piece
		li 	$a0,	0x1C2153	# Dark Blue 2
		li 	$a1,	0x3403		# cell coordenate
		jal 	piece	
		
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
	
		li	$v0,	10
		syscall
