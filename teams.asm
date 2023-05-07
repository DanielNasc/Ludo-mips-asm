.data
	entrances_index: .word	39, 53, 11, 25
.text
	.globl create_teams
	create_teams:
		
		# Team Format: [Team Number, Entrance Index, Victory Zone Index, Goal Zone Index, Selected]

		# Allocate Memory
		li	$a0,	16	# 4 teams * 4 addresses/team
		li	$v0,	9
		syscall
		
		li	$t0,	0		# teams counter
		la	$t1,	entrances_index
		li	$t2,	56		# victory zone index in cell array		
		li	$t3,	61		# goal zone index in cell array
		move	$t4,	$v0 	# teams adresses
		
		init_teams:
			move $t5, $t0		# team number
			sll $t5, $t5, 7 	# team number in correct position in word
			lw  $t6, ($t1)		# load entrance index
			add $t5, $t5, $t6
			sll $t5,$t5,	7	# entrance index in correct position in word
			add $t5, $t5, $t2	# victory zone index
			sll $t5, $t5, 7		# victory zone index in correct position in word
			add $t5, $t5, $t3	# goal zone index
			sll $t5, $t5, 2		# goal zone index in correct position in word
			
			sw	$t5,	($t4)		# store data
			addi	$t4,	$t4,	4	# next team address
			
			addi	$t0,	$t0,	1	# increment counter
			addi	$t1,	$t1,	4	# next entrance index
			addi	$t2,	$t2,	6	# next victory zone index
			addi	$t3,	$t3,	6	# next goal zone index
			blt	$t0,	4,	init_teams	# branch if there is more teams to initialize
			
		jr	$ra

	