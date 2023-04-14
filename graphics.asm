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
		
		#la	$t0,	frameBuffer
		li	$t0,	0x10000000
		li	$t1,	0x200	# addresses per row (128 pixels -> 512 addresses)
		
		andi	$t6,	$a1,	0xFF	# x
		srl	$t7,	$a1,	8	# y
			
		sll	$t6,	$t6,	2	# how many address should jump: x << 2 (4 per pixel)
		sll	$a2,	$a2,	2	# a2 = x pixels * 4 addresses/pixel
		
		# convert y in pixels::	y << 9
		# y * 2^7 (128 pixels per row) * 2^2 (addresses by pixel)
		sll	$t7,	$t7,	9
		sll	$a3,	$a3,	9	# convert height in pixels

		add	$t3,	$t0,	$t6	# move to x coord
		add	$t3,	$t3,	$t7	# move y coord
		
		add	$t4,	$a2,	$t3	# x limit on first iteration
		add	$t5,	$a3,	$t4	# last pixel to be paintend in the end of the last row
		
	walk_x:
		sw	$a0,	0($t3)
		addi	$t3,	$t3,	4	# next pixel
		ble	$t3,	$t4, 	walk_x	# if t3 didnt reach the x limit yet, go to next iteration
	walk_y:
		bge	$t3,	$t5,	end_rect
		
		add	$t4,	$t4,	$t1	# update x limit
		
		add	$t3,	$t3,	$t1
		sub	$t3,	$t3,	$a2	# update pos
		subi	$t3,	$t3,	4
		
		j	walk_x
		
	end_rect:
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
	
		jr	$ra
		
		
	.globl background
	background:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
	
		li	$a0,	0xF4FBF8 # white color 	
		li	$a1,	0	# x = 128, y = 64
		li	$a2,	128	# width
		li	$a3,	128	# height = 32
		jal	rect
		
		lw	$ra,	($sp)
		addi	$sp,	$sp, 4
		
		jr	$ra 
		
	.globl cell
	cell:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
	
		li	$a0,	0x111426	# dark color
		li	$a2,	7		# width
		li	$a3,	7		# height = 32
		jal	rect
		
		li	$a0,	0xF4FBF8	# white color
		addi 	$a1,	$a1,	0x101
		li	$a2,	5		# width
		li	$a3,	5		# height = 32
		jal	rect
		
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp, 8
		
		jr	$ra 
		
	loop_add:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		
		loop_a:
			sw	$a2,	4($sp)
			sw	$a3,	8($sp)
			add	$a1,	$a1,	$a3
			jal	cell
			lw	$a2,	4($sp)
			lw	$a3,	8($sp)
			subi	$a2,	$a2,	1
			bgtz	$a2,	loop_a
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	loop_sub:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		
		loop_s:
			sw	$a2,	4($sp)
			sw	$a3,	8($sp)
			sub	$a1,	$a1,	$a3
			jal	cell
			lw	$a2,	4($sp)
			lw	$a3,	8($sp)
			subi	$a2,	$a2,	1
			bgtz	$a2,	loop_s
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra		

	.globl board
	board:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		# first cell
		li 	$a1,	0x3703
		jal 	cell
		
		# add 5 cells to x
		li	$a2,	5
		li	$a3,	0x0007
		jal	loop_add
		
		
		# sub 1 cell to y
		li	$a2,	1
		li	$a3,	0x0700
		jal 	loop_sub
		
		# add 1 cell to x
		li	$a2,	1
		li	$a3,	0x0007
		jal 	loop_add
		
		# sub 5 cells to y
		li	$a2,	5
		li	$a3,	0x0700
		jal 	loop_sub
		
		# add 2 cells to x
		li	$a2,	2
		li	$a3,	0x0007
		jal 	loop_add
		
		# add 5 cells to y
		li	$a2,	5
		li	$a3,	0x0700
		jal 	loop_add
		
		# add 1 cell to x
		li	$a2,	1
		li	$a3,	0x0007
		jal 	loop_add
		
		# add 1 cell to y
		li	$a2,	1
		li	$a3,	0x0700
		jal 	loop_add
		
		# add 5 cells to x
		li	$a2,	5
		li	$a3,	0x0007
		jal 	loop_add
		
		# add 2 cells to y
		li	$a2,	2
		li	$a3,	0x0700
		jal 	loop_add
		
		# sub 5 cells to x
		li	$a2,	5
		li	$a3,	0x0007
		jal 	loop_sub
		
		# add 1 cell to y
		li	$a2,	1
		li	$a3,	0x0700
		jal 	loop_add
		
		# sub 1 cell to x
		li	$a2,	1
		li	$a3,	0x0007
		jal 	loop_sub
		
		# add 5 cells to y
		li	$a2,	5
		li	$a3,	0x0700
		jal 	loop_add
		
		# sub 2 cells to x
		li	$a2,	2
		li	$a3,	0x0007
		jal 	loop_sub
		
		# sub 5 cells to y
		li	$a2,	5
		li	$a3,	0x0700
		jal 	loop_sub
		
		# sub 1 cell to x
		li	$a2,	1
		li	$a3,	0x0007
		jal 	loop_sub
		
		# sub 1 cell to y
		li	$a2,	1
		li	$a3,	0x0700
		jal 	loop_sub
		
		# sub 5 cells to x
		li	$a2,	5
		li	$a3,	0x0007
		jal 	loop_sub
		
		# sub 1 cell to y
		li	$a2,	1
		li	$a3,	0x0700
		jal 	loop_sub
		
		lw	$ra,	($sp)
		addi	$sp,	$sp, 4
		
		jr	$ra 
	
