.data
	frameBuffer: 		.space	0x80000
	pixels_per_block_shift:	.word	2	# shift 2 places (multiply by 4)
	dark_colors:		.word	0x6A448A, 0x1C2153, 0xC6224E, 0xC72D1E
	normal_colors:		.word	0xF4FBF8, 0xA467C3, 0x2D4280, 0xF84284, 0xE8931F
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
		subi	$a3,	$a3,	1
		sll	$a3,	$a3,	9	# convert height in pixels

		add	$t3,	$t0,	$t6	# move to x coord
		add	$t3,	$t3,	$t7	# move y coord
		
		add	$t4,	$a2,	$t3	# x limit on first iteration
		add	$t5,	$a3,	$t4	# last pixel to be paintend in the end of the last row
		
	walk_x:
		sw	$a0,	0($t3)
		addi	$t3,	$t3,	4	# next pixel
		blt	$t3,	$t4, 	walk_x	# if t3 didnt reach the x limit yet, go to next iteration
	walk_y:
		bge	$t3,	$t5,	end_rect
		
		add	$t4,	$t4,	$t1	# update x limit
		
		add	$t3,	$t3,	$t1
		sub	$t3,	$t3,	$a2	# update pos
		#subi	$t3,	$t3,	4
		
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
		li	$a1,	0	# x = 0, y = 0
		li	$a2,	128	# width
		li	$a3,	128	# height = 32
		jal	rect
		
		lw	$ra,	($sp)
		addi	$sp,	$sp, 4
		
		jr	$ra 
		

	.globl cell
	cell:
		subi	$sp,	$sp,	20
		sw	$ra,	($sp)
		sw	$a0,	4($sp)		# team (0 - 4)
		sw	$a1,	8($sp)		# coordinate
		sw	$a2,	12($sp)		# type
		sw	$a3,	16($sp)		# amount
	
		li	$a0,	0x111426	# dark color
		li	$a2,	9		# width
		li	$a3,	9		# height
		jal	rect
		
		lw	$a0,	4($sp)		# team (0 - 4)
		lw	$a1,	8($sp)		# coordinate
		lw	$a2,	12($sp)		# type
		lw	$a3,	16($sp)		# amount

		andi	$t0,	$a2,	1
		la	$t1,	normal_colors
		beqz	$t0,	not_colorful
		mul	$t2,	$a0,	4
		add	$t1,	$t1,	$t2
		
		not_colorful:
		lw	$a0,	($t1)
		addi 	$a1,	$a1,	0x101
		li	$a2,	7		# width
		li	$a3,	7		# height
		jal	rect
		
		lw	$a1,	8($sp)
		lw	$a2,	12($sp)
		blt	$a2,	2, not_crosspiece
		
		jal 	crosspiece
		
		not_crosspiece:
		lw	$a0,	4($sp)		# team (0 - 4)
		lw	$a1,	8($sp)		# coordinate
		lw	$a2,	12($sp)		# type
		lw	$a3,	16($sp)		# amount
		
		beqz	$a3,	end_cell
		
		subi	$a0,	$a0,	1
		la	$t0,	dark_colors	
		mul	$a0,	$a0,	4
		add	$a0,	$a0,	$t0
		lw	$a0,	($a0)
		
		jal	one_piece
		
		end_cell:
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp, 	20
		
		jr	$ra 
		
	loop_add:
		# 
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
			
	.globl 	one_piece
	one_piece:
		subi	$sp,	$sp, 	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0602	

		li	$a2,	5		# width
		li	$a3,	1		# height
		jal	rect
		
		beq	$a0,	0x6A448A,	set_purple_color
		beq	$a0,	0x1C2153,	set_blue_color
		beq	$a0,	0xC6224E,	set_pink_color
		beq	$a0,	0xC72D1E,	set_orange_color
		
		subi	$a1,	$a1,	0x0100
		addi	$a1,	$a1,	0x0001	
		
		li	$a2,	3		# width
		li	$a3,	1		# height
		jal	rect
		
		subi	$a1,	$a1,	0x0200
		
		li	$a2,	3		# width
		li	$a3,	1		# height
		jal	rect
		
		subi	$a1,	$a1,	0x0100
		addi	$a1,	$a1,	0x0001	
		
		li	$a2,	1		# width
		li	$a3,	3		# height
		jal	rect
		
		lw	$a0,	4($sp)
		lw	$a1,	8($sp)
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
		
	.globl	small_piece
	small_piece:
		subi	$sp,	$sp, 	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		li	$a2,	2		# width
		li	$a3,	2		# height
		jal	rect
		
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	draw_small_piece_1:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		# piece 1
		li	$a0,	0xE8931F
		jal	small_piece
		
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp,	8
		jr	$ra
		
	draw_small_piece_2:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		# piece 2
		li	$a0,	0xF84284
		addi	$a1,	$a1,	0x0303	
		jal small_piece
		
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp,	8
		jr	$ra
	
	draw_small_piece_3:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		# piece 3
		li	$a0,	0xC6224E
		addi	$a1,	$a1,	0x0300	
		jal small_piece
	
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp,	8
		jr	$ra
	
	draw_small_piece_4:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		# piece 4
		li	$a0,	0x2D4280
		addi	$a1,	$a1,	0x0003
		jal small_piece
		
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp,	8
		jr	$ra
		
	.globl 	more_pieces
	more_pieces:
		subi	$sp,	$sp, 	12
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		addi	$a1,	$a1,	0x0201	
		
			
			beq	$a2,	2,	call_draw_small_piece_2
			beq	$a2,	3,	call_draw_small_piece_3
			
			
			jal	draw_small_piece_4
			call_draw_small_piece_3:
				jal 	draw_small_piece_3
			call_draw_small_piece_2:
				jal 	draw_small_piece_2
				jal	draw_small_piece_1
			
			
			
	
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
			
	.globl 	crosspiece
	crosspiece:
		subi	$sp,	$sp, 	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		addi	$a1,	$a1,	0x0304	# y += 2, x += 2;
		
		li	$a0,	0x111426	# dark color
		li	$a2,	1		# width
		li	$a3,	3		# height 
		jal	rect
		
		addi	$a1,	$a1,	0x0100	# y += 1;
		subi	$a1,	$a1,	0x0001	# x -= 1;
		
		li	$a2,	3		# width
		li	$a3,	1		# height 
		jal	rect
		
		lw	$ra,	($sp)
		lw	$a1,	4($sp)
		addi	$sp,	$sp,	8
		jr	$ra
		
	.globl	create_crosspieces
	create_crosspieces:
		subi	$sp,	$sp, 	8
		sw	$ra,	($sp)
		sw	$a1,	4($sp)
		
		# cross 1
		li 	$a1,	0x341B
		jal 	crosspiece
		
		# cross 2
		addi	$a1,	$a1,	0x0018
		subi	$a1,	$a1,	0x2800
		jal 	crosspiece
		
		# cross 3
		addi	$a1,	$a1,	0x1010
		jal 	crosspiece
		
		# cross 4
		addi	$a1,	$a1,	0x1828
		jal 	crosspiece
		
		# cross 5
		addi	$a1,	$a1,	0x1000
		subi	$a1,	$a1,	0x0010
		jal 	crosspiece
		
		# cross 6
		addi	$a1,	$a1,	0x2800
		subi	$a1,	$a1,	0x0018
		jal 	crosspiece
		
		# cross 7
		subi	$a1,	$a1,	0x1010
		jal 	crosspiece
		
		# cross 8
		subi	$a1,	$a1,	0x1828
		jal 	crosspiece
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	8
		jr	$ra
	
	draw_one:
	# draws the dice with only 1 rectangle
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0404	
		li	$a0,	0x111426	# dark color
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		sw	$a0,	4($sp)
		sub	$a0,	$a0,	$a0
		
		lw	$ra,	($sp)
		lw	$a0,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
		
	draw_two:
	# draws the dice with 2 rectangles
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0101
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0606
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		sw	$a0,	4($sp)
		sub	$a0,	$a0,	$a0
		
		lw	$ra,	($sp)
		lw	$a0,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	draw_three:
	# draws the dice with 3 rectangles
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0101
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0303
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0303
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		sw	$a0,	4($sp)
		sub	$a0,	$a0,	$a0
		
		lw	$ra,	($sp)
		lw	$a0,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	draw_four:
	# draws the dice with 4 rectangles
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0101
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0006
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0600
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		subi	$a1,	$a1,	0x0006
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		sw	$a0,	4($sp)
		sub	$a0,	$a0,	$a0
		
		lw	$ra,	($sp)
		lw	$a0,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	draw_five:
	# draws the dice with 5 rectangles
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0101
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0006
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0600
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		subi	$a1,	$a1,	0x0006
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		subi	$a1,	$a1,	0x0300
		addi	$a1,	$a1,	0x0003
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		sw	$a0,	4($sp)
		sub	$a0,	$a0,	$a0
		
		lw	$ra,	($sp)
		lw	$a0,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
		
	draw_six:
	# draws the dice with 6 rectangles
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x0101
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0006
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0300
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		addi	$a1,	$a1,	0x0300
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		subi	$a1,	$a1,	0x0006
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		subi	$a1,	$a1,	0x0300
		li	$a0,	0x111426
		li	$a2,	1
		li	$a3,	1
		jal 	rect
		
		sw	$a0,	4($sp)
		sub	$a0,	$a0,	$a0	# subtract $a0 from itself to result in 0
		
		lw	$ra,	($sp)
		lw	$a0,	4($sp)
		addi	$sp,	$sp,	12
		jr	$ra
		
	draw_dice_number:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		# checks which number is drawn and calls the function to draw it
		beq	$a0,	1,	draw_one
		beq	$a0,	2,	draw_two
		beq	$a0,	3,	draw_three
		beq	$a0,	4,	draw_four
		beq	$a0,	5,	draw_five
		beq	$a0,	6,	draw_six
		

		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
		
	.globl 	dice
	dice:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		
		# dice contour
		li	$a0,	0x111426
		li	$a1,	0x4f70	# dice coordenates
		li	$a2,	11
		li	$a3,	11
		jal 	rect
		
		# dice white rectangle
		li	$a0,	0xF4FBF8
		addi	$a1,	$a1,	0x0101
		li	$a2,	9
		li	$a3,	9
		jal 	rect
		
		sw	$a1,	4($sp)	# save the coordinates of $a1
		
		jal 	roll_die
		
		lw	$a1,	4($sp)	# returns the coordinates of $a1
		jal	draw_dice_number
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	.globl entry_index
	entry_index:
	# draws the arrow that indicates the entry into the victory zone.
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		# drawing the purple time entry index.
		li	$a0,	0xA467C3	# purple color.
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x3C4B
		
		li	$a2,	1
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0001
		subi	$a1, 	$a1,	0x0100
		li	$a2,	1
		li	$a3,	3
		jal rect
		
		beq	$a0,	0x6A448A,	set_purple_color
		
		addi	$a1,	$a1,	0x0001
		subi	$a1, 	$a1,	0x0100
		li	$a2,	1
		li	$a3,	5
		jal rect
		
		# drawing the blue time entry index.
		li	$a0,	0x5A77B9	# blue color.
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x1b0c
		
		li	$a2,	1
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0100
		subi	$a1, 	$a1,	0x0001
		li	$a2,	3
		li	$a3,	1
		jal rect
		
		addi	$a1,	$a1,	0x0100
		subi	$a1, 	$a1,	0x0001
		li	$a2,	5
		li	$a3,	1
		jal rect
		
		# drawing the pink time entry index.
		li	$a0,	0xF84284	# pink color.
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x002b
		subi	$a1,	$a1,	0x2600
		
		li	$a2,	1
		li	$a3,	5
		jal	rect
		
		addi	$a1,	$a1,	0x0001
		addi	$a1, 	$a1,	0x0100
		li	$a2,	1
		li	$a3,	3
		jal rect
		
		addi	$a1,	$a1,	0x0001
		addi	$a1, 	$a1,	0x0100
		li	$a2,	1
		li	$a3,	1
		jal rect
		
		# drawing the orange time entry index.
		li	$a0,	0xE8931F	# orange color.
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x006a
		subi	$a1,	$a1,	0x0500
		
		li	$a2,	5
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0100
		addi	$a1, 	$a1,	0x0001
		li	$a2,	3
		li	$a3,	1
		jal rect
		
		addi	$a1,	$a1,	0x0100
		addi	$a1, 	$a1,	0x0001
		li	$a2,	1
		li	$a3,	1
		jal rect
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
		
	.globl players_numbers
	players_numbers:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$a0,	0xF4FBF8	# white color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		# drawing number 1
		addi	$a1,	$a1,	0x3264	# goes to the coordinate where the number will be printed
		li	$a2,	1
		li	$a3,	5
		jal	rect
		
		addi	$a1,	$a1,	0x0100
		subi	$a1,	$a1,	0x0001
		li	$a2,	1
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0300
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		# drawing number 2
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x3213
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0200
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0200
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		subi	$a1,	$a1,	0x0100
		li	$a2,	1
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0002
		subi	$a1,	$a1,	0x0200
		li	$a2,	1
		li	$a3,	1
		jal	rect
		
		# drawing number 3
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x0013
		subi	$a1,	$a1,	0x1e00
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0200
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0200
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		addi	$a1,	$a1,	0x0002
		subi	$a1,	$a1,	0x0400
		li	$a2,	1
		li	$a3,	5
		jal	rect
		
		# drawing number 4
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		
		addi	$a1,	$a1,	0x0063
		subi	$a1,	$a1,	0x1e00
		li	$a2,	1
		li	$a3,	3
		jal	rect
		
		addi	$a1,	$a1,	0x0002
		li	$a2,	1
		li	$a3,	5
		jal	rect
		
		addi	$a1,	$a1,	0x0200
		subi	$a1,	$a1,	0x0002
		li	$a2,	3
		li	$a3,	1
		jal	rect
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
		
	set_purple_color:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$a0,	0xA467C3	# purple color
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
		
	set_blue_color:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$a0,	0x5A77B9	# blue color
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
	
	set_pink_color:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$a0,	0xF84284	# pink color
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
		
	set_orange_color:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		li	$a0,	0xE8931F	# orange color
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra

		
	.globl	reserve_zone
	reserve_zone:	
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		# contour
		addi	$a1,	$a1,	0x3403	# based on the coordinates of the first pixel used to draw the board.
		
		subi	$a1,	$a1,	0x2900
		li	$a2,	9
		li	$a3,	27
		jal	rect
		
		# contour
		addi	$a1,	$a1,	0x0900
		subi	$a1,	$a1,	0x0009
		li	$a2,	27
		li	$a3,	9
		jal	rect
		
		# interior
		beq	$a0,	0x6A448A,	set_purple_color
		beq	$a0,	0x1C2153,	set_blue_color
		beq	$a0,	0xC6224E,	set_pink_color
		beq	$a0,	0xC72D1E,	set_orange_color
		
		addi	$a1,	$a1,	0x0101
		li	$a2,	25
		li	$a3,	7
		jal	rect
		
		addi	$a1,	$a1,	0x0009
		subi	$a1,	$a1,	0x0900
		li	$a2,	7
		li	$a3,	25
		jal	rect
		
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	.globl	reserve_piece
	reserve_piece:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		sw	$a0,	4($sp)
		sw	$a1,	8($sp)
		
		addi	$a1,	$a1,	0x3403	# based on the coordinates of the first pixel used to draw the board.
		subi	$a1,	$a1,	0x2800
		
		# first reserve piece		
		jal	one_piece
		
		# second reserve piece
		addi	$a1,	$a1,	0x0012
		jal	one_piece
		
		# third reserve piece
		addi	$a1,	$a1,	0x1000
		jal	one_piece
		
		# fourth reserve piece
		subi	$a1,	$a1,	0x0012
		jal	one_piece
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	.globl	draw_reserve_zones
	draw_reserve_zones:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		# drawing the purple reserve zone.
		li	$a0,	0x6A448A	# dark purple color.
		li	$a1,	0x5060		# coordinate + difference in y
		jal 	reserve_zone
		
		# drawing the blue reserve zone.
		li	$a0,	0x1C2153	# dark blue color.
		li	$a1,	0x5010		# coordinate + difference in y
		jal 	reserve_zone
		
		# drawing the pink reserve zone.
		li	$a0,	0xC6224E	# dark pink color.
		li	$a1,	0x0010
		jal 	reserve_zone
		
		# drawing the orange reserve zone.
		li	$a0,	0xC72D1E	# dark orange color.
		li	$a1,	0x0060
		jal 	reserve_zone
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
	
	center_loop_add:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		
		li	$a0,	0x111426	# dark color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		li	$t0,	24
		
		addi	$a1,	$a1,	0x0030
		
		loop_center_a:
			sw	$t0,	4($sp)
			addi	$a1,	$a1,	0x0101
			li	$a2,	1
			li	$a3,	1
			jal	rect
			lw	$t0,	4($sp)
			subi	$t0,	$t0,	1
			bgtz	$t0,	loop_center_a
			
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	8
		jr	$ra
		
	center_loop_sub:
		subi	$sp,	$sp,	8
		sw	$ra,	($sp)
		
		li	$a0,	0x111426	# dark color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		li	$t0,	24
		
		addi	$a1,	$a1,	0x0048
		
		loop_center_s:
			sw	$t0,	4($sp)
			addi	$a1,	$a1,	0x0100
			subi	$a1,	$a1,	0x0001
			li	$a2,	1
			li	$a3,	1
			jal	rect
			lw	$t0,	4($sp)
			subi	$t0,	$t0,	1
			bgtz	$t0,	loop_center_s
			
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	8
		jr	$ra
	
	center_loop_purple:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		
		li	$a0,	0xA467C3	# purple color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		li	$a2,	21		# max triangle width size
		li	$t0,	11		# counter
		
		addi	$a1,	$a1,	0x1831	# results in the initial coordinate used to draw the purple area in the center
		
		loop_center_pp:
			sw	$t0,	4($sp)
			sw	$a2,	8($sp)
			subi	$a1,	$a1,	0x0100
			addi	$a1,	$a1,	0x0001
			li	$a3,	1
			jal	rect
			lw	$t0,	4($sp)
			lw	$a2,	8($sp)
			subi	$t0,	$t0,	1
			subi	$a2,	$a2,	2
			bgtz	$t0,	loop_center_pp
			
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	center_loop_blue:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		
		li	$a0,	0x5A77B9	# blue color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		li	$a3,	21		# max triangle height size
		li	$t0,	11		# counter
		
		addi	$a1,	$a1,	0x0130	# results in the initial coordinate used to draw the purple area in the center
		
		loop_center_b:
			sw	$t0,	4($sp)
			sw	$a3,	8($sp)
			addi	$a1,	$a1,	0x0101
			li	$a2,	1
			jal	rect
			lw	$t0,	4($sp)
			lw	$a3,	8($sp)
			subi	$t0,	$t0,	1
			subi	$a3,	$a3,	2
			bgtz	$t0,	loop_center_b
			
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	center_loop_pink:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		
		li	$a0,	0xF84284	# pink color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		li	$a2,	21		# max triangle width size
		li	$t0,	11		# counter
		
		addi	$a1,	$a1,	0x0031	# results in the initial coordinate used to draw the purple area in the center
		
		loop_center_pk:
			sw	$t0,	4($sp)
			sw	$a2,	8($sp)
			addi	$a1,	$a1,	0x0101
			li	$a3,	1
			jal	rect
			lw	$t0,	4($sp)
			lw	$a2,	8($sp)
			subi	$t0,	$t0,	1
			subi	$a2,	$a2,	2
			bgtz	$t0,	loop_center_pk
			
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
	
	center_loop_orange:
		subi	$sp,	$sp,	12
		sw	$ra,	($sp)
		
		li	$a0,	0xE8931F	# orange color
		li	$a1,	0x3403		# based on the coordinates of the first pixel used to draw the board.
		li	$a3,	21		# max triangle height size
		li	$t0,	11		# counter
		
		addi	$a1,	$a1,	0x0148	# results in the initial coordinate used to draw the purple area in the center
		
		loop_center_o:
			sw	$t0,	4($sp)
			sw	$a3,	8($sp)
			addi	$a1,	$a1,	0x0100
			subi	$a1,	$a1,	0x0001
			li	$a2,	1
			jal	rect
			lw	$t0,	4($sp)
			lw	$a3,	8($sp)
			subi	$t0,	$t0,	1
			subi	$a3,	$a3,	2
			bgtz	$t0,	loop_center_o
			
		lw	$ra,	($sp)
		addi	$sp,	$sp,	12
		jr	$ra
			
	.globl	center_board
	center_board:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		jal	center_loop_add
		jal	center_loop_sub
		jal	center_loop_purple
		jal	center_loop_blue
		jal	center_loop_pink
		jal	center_loop_orange
		
		lw	$ra,	($sp)
		addi	$sp,	$sp,	4
		jr	$ra
	
	.globl 	board
	board:
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
		
		# first cell
		li	$a0,	0	# white color
		li 	$a1,	0x3403
		li	$a2,	0
		li	$a3,	0
		jal 	cell
		
		# add 5 cells to x
		li	$a2,	5
		li	$a3,	0x0008
		jal	loop_add
		
		
		# sub 1 cell to y
		li	$a2,	1
		li	$a3,	-0x0800
		jal	loop_add
		
		# add 1 cell to x
		li	$a2,	1
		li	$a3,	0x0008
		jal 	loop_add
		
		# sub 5 cells to y
		li	$a2,	5
		li	$a3,	-0x0800
		jal	loop_add
		
		# add 2 cells to x
		li	$a2,	2
		li	$a3,	0x0008
		jal 	loop_add
		
		# add 5 cells to y
		li	$a2,	5
		li	$a3,	0x0800
		jal 	loop_add
		
		# add 1 cell to x
		li	$a2,	1
		li	$a3,	0x0008
		jal 	loop_add
		
		# add 1 cell to y
		li	$a2,	1
		li	$a3,	0x0800
		jal 	loop_add
		
		# add 5 cells to x
		li	$a2,	5
		li	$a3,	0x0008
		jal 	loop_add
		
		# add 2 cells to y
		li	$a2,	2
		li	$a3,	0x0800
		jal 	loop_add
		
		# sub 5 cells to x
		li	$a2,	5
		li	$a3,	-0x0008
		jal	loop_add
		
		# add 1 cell to y
		li	$a2,	1
		li	$a3,	0x0800
		jal 	loop_add
		
		# sub 1 cell to x
		li	$a2,	1
		li	$a3,	-0x0008
		jal	loop_add
		
		# add 5 cells to y
		li	$a2,	5
		li	$a3,	0x0800
		jal 	loop_add
		
		# sub 2 cells to x
		li	$a2,	2
		li	$a3,	-0x0008
		jal	loop_add
		
		# sub 5 cells to y
		li	$a2,	5
		li	$a3,	-0x0800
		jal	loop_add
		
		# sub 1 cell to x
		li	$a2,	1
		li	$a3,	-0x0008
		jal	loop_add
		
		# sub 1 cell to y
		li	$a2,	1
		li	$a3,	-0x0800
		jal	loop_add
		
		# sub 5 cells to x
		li	$a2,	5
		li	$a3,	-0x0008
		jal	loop_add
		
		# sub 1 cell to y
		li	$a2,	1
		li	$a3,	-0x0800
		jal	loop_add
		
		# creating blue cells
		li	$a0,	0x5A77B9	# blue color
		
		addi	$a1,	$a1,	0x0800
		
		li	$a2,	1
		li	$a3,	0x0008
		jal 	loop_add
		
		subi	$a1,	$a1,	0x0808
		
		li	$a2,	5
		li	$a3,	0x0008
		jal 	loop_add
		
		# creating orange cells
		li	$a0,	0xE8931F	# orange color
		
		addi	$a1,	$a1,	0x0018	# pula 3 casas para a direita (eixo x)
		
		li	$a2,	5
		li	$a3,	0x0008
		jal 	loop_add
		
		subi	$a1,	$a1,	0x0808
		
		li	$a2,	1
		li	$a3,	0x0008
		jal 	loop_add
		
		# creating pink cells
		li	$a0,	0xF84284	# pink color
		
		subi	$a1,	$a1,	0x2840	# sobe 5 casas para cima(eixo y) e 8 casas para a esquerda (eixo x)
		
		li	$a2,	2
		li	$a3,	0x0008
		jal 	loop_add
		
		li	$a2,	4
		li	$a3,	0x0800
		jal 	loop_add
		
		# creating purple cells
		li	$a0,	0xA467C3	# purple color
		
		addi	$a1,	$a1,	0x1800	# tr�s casas no eixo y
		
		li	$a2,	5
		li	$a3,	0x0800
		jal 	loop_add
		
		li	$a2,	1
		li	$a3,	0x0008
		jal 	loop_add
		
		jal	 entry_index
		jal		create_crosspieces
		
		jal	draw_reserve_zones
		jal	players_numbers
		jal	center_board
		
		lw	$ra,	($sp)
		addi	$sp,	$sp, 4
		
		jr	$ra 
