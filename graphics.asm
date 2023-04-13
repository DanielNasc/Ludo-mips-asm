.data
	frameBuffer: 		.space	0x80000
	pixels_per_block_shift:	.word	2	# shift 2 places (multiply by 4)
.text
	.globl rect
	rect:
		# addrl(i + jw), where i is x coord, j is y coord, w is the width and addrl is address length
		# a0 = color
		# a1 = coord x and coord y
		# a2 = width
		# a3 = height
		
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$t1,	0x400	# addresses per row (256 pixels -> 1024 addresses)
		
		andi	$t6,	$a1,	0xFF	# x
		srl	$t7,	$a1,	8	# y
			
		sll	$t6,	$t6,	2	# how many address should jump: x << 2 (4 per pixel)
		sll	$a2,	$a2,	2	# a2 = x pixels * 4 addresses/pixel
		
		# convert y in pixels::	y << 10
		# y * 2^8 (256 pixels per row) * 2^2 (addresses by pixel)
		sll	$t7,	$t7,	10
		sll	$a3,	$a3,	10	# convert height in pixels

		add	$t3,	$gp,	$t6	# move to x coord
		add	$t3,	$t3,	$t7	# move y coord
		
		add	$t4,	$a2,	$t3	# x limit on first iteration
		add	$t5,	$a3,	$t4	# last pixel to be paintend in the end of the last row
		
	walk_x:
		sw	$a0,	0($t3)
		addi	$t3,	$t3,	4	# next pixel
		blt	$t3,	$t4, walk_x	# if t3 didnt reach the x limit yet, go to next iteration
	walk_y:
		bge	$t3,	$t5,	end_rect
		
		add	$t4,	$t4,	$t1	# update x limit
		
		add	$t3,	$t3,	$t1
		sub	$t3,	$t3,	$a2	# update pos
		
		j	walk_x
		
	end_rect:
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
	
		jr	$ra
		
		
	.globl poker_face
	poker_face:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
	
		li	$a0,	0xFFFFFF # color
		li	$a1,	0x407F	# x = 128, y = 64
		li	$a2,	64	# width
		li	$a3,	64	# height = 32
		jal	rect
		
		li	$a0,	0	 # color
		li	$a1,	0x5090
		li	$a2,	3	# width
		li	$a3,	7	# height = 32
		jal	rect
		
		li	$a0,	0	 # color
		li	$a1,	0x509E
		li	$a2,	3	# width
		li	$a3,	7	# height = 32
		jal	rect
		
		li	$a0,	0	 # color
		li	$a1,	0x6090
		li	$a2,	32	# width
		li	$a3,	2	# height = 32
		jal	rect
		
		lw	$ra,	($sp)
		addi	$sp,	$sp, 4
		
		jr	$ra 
	
