.data
	frameBuffer: 		.space	0x80000
	pixels_per_block_shift:	.word	2	# shift 2 places (multiply by 4)
.text
	.globl rect
	rect:
		# addrl(i + jw), where i is x coord, j is y coord, w is the width and addrl is address length
		# a0 = coord x
		# a1 = width
		# a2 = coord y
		# a3 = height
		
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		la	$t0,	frameBuffer
		li	$t1,	0x400	
		li	$t2,	0xFF002F	# red
		li	$t4,	0
		
		move	$t0,	$gp
			
		sll	$a0,	$a0,	2	# how many address should jump: x << 2 (4 per pixel)
		sll	$a1,	$a1,	2
		
		# convert y in pixels::	y << 10
		# y * 2^8 (256 pixels per row) * 2^2 (addresses by pixel)
		sll	$a2,	$a2,	10
		sll	$a3,	$a3,	10	# convert height in pixels::

		add	$t3,	$gp,	$a0	# move to x coord
		add	$t3,	$t3,	$a2	# move y coord
		
		add	$t4,	$a1,	$t3	# x limit on first iteration
		add	$t5,	$a3,	$t4	# last pixel to be paintend in the end of the last row
		
	walk_x:
		sw	$t2,	0($t3)
		addi	$t3,	$t3,	4	# next pixel
		blt	$t3,	$t4, walk_x	# if t3 didnt reach the x limit yet, go to next iteration
	walk_y:
		bge	$t3,	$t5,	end_rect
		
		add	$t4,	$t4,	$t1	# update x limit
		
		add	$t3,	$t3,	$t1
		sub	$t3,	$t3,	$a1	# update pos
		
		j	walk_x
		
	end_rect:
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
	
		jr	$ra
	