
.text
	.globl create_pieces
	create_pieces:
				
		# Each piece contains the following information:
	
		#   * `pos` - the coordinates of the piece in the cells array
		#   * `team` - the team the piece belongs to
		#   * `status` - the status of the piece
		#     - `dead` - the piece is dead
		#     - `in play` - the piece is in play
		#     - `in reserve` - the piece is in reserve
		#     - `in victory zone` - the piece is in the victory zone
		#     - `in goal` - the piece is in the goal

		# Store return addresss on stack
		subi	$sp,	$sp,	4
		sw	$ra,	($sp)
	
		move	$t0,	$a0
	
		# Allocate Memory
		li	$a0,	64	# 16 pieces * 4 bytes/piece
		li	$v0,	9	# code for allocate memory
		syscall
		
		# Update data of each piece
		
		move	$t0,	$v0		# first piece address
		li	$t1,	0		# COLOR/TEAM: 0 - 3
		li	$t2,	0		# pieces_counter
		li	$t3,	80		# pieces_pos in cells array

		init_pieces:
			# update team
			move	$t4,	$t1	# load team number	
			sll	$t4,	$t4,	7	# team bits in the correct position
			add $t4,	$t4,	$t3	# add pos to team bits
			sll $t4,	$t4,	3	# team bits in the correct position
			add $t4,	$t4,	$zero	# add status bits

			sw	$t4,	($t0)			# update value in memory

			addi	$t0,	$t0,	4		# next piece address
			addi	$t2,	$t2,	1		# pieces_counter++ 
			addi	$t3,	$t3,	1		# pieces_pos++
			
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

	.globl filter_piece_team
	filter_piece_team:
		# $a0 - piece address

		# Load piece value
		lw	$t0,	($a0)

		# Filter team bits
		srl	$t0,	$t0,	10	# shift right 10 bits
		andi	$t0,	$t0,	0x03	# filter team bits

		# Return team value
		move	$v0,	$t0

		jr	$ra

	.globl filter_piece_pos
	filter_piece_pos:
		# $a0 - piece address

		# Load piece value
		lw	$t0,	($a0)

		# Filter pos bits
		srl $t0,	$t0,	3	# shift right 7 bits
		andi	$t0,	$t0,	0x7F	# filter pos bits

		# Return pos value
		move	$v0,	$t0

		jr	$ra


	.globl filter_piece_status
	filter_piece_status:
		# $a0 - piece address

		# Load piece value
		lw	$t0,	($a0)

		# Filter status bits
		andi $t0,	$t0,	0x07	# filter status bits

		# Return status value
		move	$v0,	$t0
		jr	$ra
