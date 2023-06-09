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
		li 	$a0,	0xC6224E	# color
		li 	$a1,	0x3403		# cell coordenate
		jal 	one_piece	
		
		# How to create two pieces
		li 	$a1,	0x441B		# cell coordenate
		jal 	more_pieces
		
		# How to create reserve pieces
		# Purple player
		li	$a0,	0x6A448A	# dark purple color
		li	$a1,	0x5057		# coordenate + 0x2800
		jal 	reserve_piece
		# Blue player
		li	$a0,	0x1C2153	# dark blue color
		li	$a1,	0x5007		# coordenate + 0x2800
		jal 	reserve_piece
		# Pink player
		li	$a0,	0xC6224E	# dark pink color
		li	$a1,	0x0007		# coordenate
		jal 	reserve_piece
		# Orange player
		li	$a0,	0xC72D1E	# dark orange color
		li	$a1,	0x0057		# coordenate
		jal 	reserve_piece
		
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
