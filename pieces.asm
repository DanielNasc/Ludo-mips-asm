.text
	.globl create_pieces
	create_pieces:
				
		# Each piece contains the following information:
	
		#   * `coords` - the coordinates of the piece
		#   * `team` - the team the piece belongs to
		#   * `status` - the status of the piece
		#     - `dead` - the piece is dead
		#     - `in play` - the piece is in play
		#     - `in reserve` - the piece is in reserve
		#     - `in victory zone` - the piece is in the victory zone
		#     - `in goal` - the piece is in the goal
		#	
		
		# As the game board is a 128x128 matrix, X and Y can be represented by a number between 0 and 127 (0 - 0x7F).
		# The `team` is represented by a number between 0 and 3 (0 - 0x03) or 2 bits.
		# The `status` is represented by a number between 0 and 4 (0 - 0x04) or 3 bits.


		# With this information, we can represent the piece as a 32-bit word.
		# From less significant to most significant bits:

		#     * 7 bits for X coordinate -> 128 possible values between 0 and 127
		#     * 7 bits for Y coordinate -> 128 possible values between 0 and 127
		#     * 2 bits for team -> 4 possible values between 0 and    
		#     * 3 bits for status -> 8 possible values between 0 and 7
		#     * 13 bits unused -> 8192 possible values between 0 and 8191
	
	
		# Store return addresss on stack
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
	
		# Allocate Memory
		li	$a0,	64	# 16 pieces * 4 bytes/piece
		li	$v0,	9	# code for allocate memory
		syscall
		
		# Update data of each piece
		move	$t0,	$v0	# first piece address
		li	$t1,	0	# COLOR/TEAM: 0 - 3
		li	$t2,	0	# pieces_counter
		
		init_pieces:
			# update team
			add	$t3,	$zero,	$t1	# load team number
			sll	$t3,	$t3,	16	# put the team bits in the correct position (shift 16 times)
			sw	$t3,	($t0)		# update value in memory
			
			addi	$t0,	$t0,	4	# next piece address
			addi	$t2,	$t2,	1	# pieces_counter++ 
			
			# go to init_pieces again if t3 < 4 pieces and init next piece 
			blt	$t2,	4,	init_pieces
			
			# reset pieces_counter and increase team
			li	$t2,	0
			addi	$t1,	$t1,	1
			
			# go again to init_pieces if there is no 4 teams yet
			blt	$t1,	4,	init_pieces
			
			# get return address and go back 
			lw	$ra,	($sp)
			addi	$sp,	$sp,	4
			
			jr	$ra
			
			
			
			
