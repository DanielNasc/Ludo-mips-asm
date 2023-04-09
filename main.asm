.data
	msg:	.asciiz	"\nHello, Ludo!\n"
	
	pos:	.word	0
.text
	.globl main
	main:
		# 256 x 128 cells (2x2 pixels)
		li	$a0,	128	# x = 128
		li	$a1,	64	# width = 64
		li	$a2,	64	# y = 32
		li	$a3,	32	# height = 32
		jal	rect
	
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
