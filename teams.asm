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
			lw  $t5, ($t1)		# load entrance index
			sll $t5,$t5,	7	# entrance index in correct position in word
			add $t5, $t5, $t2	# victory zone index
			sll $t5, $t5, 7		# victory zone index in correct position in word
			add $t5, $t5, $t3	# goal zone index
			sll $t5, $t5, 	2	# goal zone index in correct position in word
			# selected = 0
			
			sw	$t5,	($t4)		# store data
			addi	$t4,	$t4,	4	# next team address
			
			addi	$t0,	$t0,	1	# increment counter
			addi	$t1,	$t1,	4	# next entrance index
			addi	$t2,	$t2,	6	# next victory zone index
			addi	$t3,	$t3,	6	# next goal zone index
			blt	$t0,	4,	init_teams	# branch if there is more teams to initialize
			
		jr	$ra
	

	.globl filter_team_number
	filter_team_number:
		# $a0 = team address in memory

		# Load team data
		lw	$t0,	($a0)		# load team

		# Filter team number
		# 2 bits from selected + 7 bits from goal zone + 7 bits from victory zone + 7 bits from entrance
		srl $t0, $t0, 23 # 2 + 7 + 7 + 7 = 23 bits
		andi $t0, $t0, 3

		move $v0, $t0
		jr $ra

	.globl filter_entrance
	filter_entrance:
		# $a0 = team address in memory

		# Load team data
		lw	$t0,	($a0)		# load team

		# Filter entrance
		# 2 bits from selected + 7 bits from goal zone + 7 bits from victory zone
		srl $t0, $t0, 16 	# 2 + 7 + 7 = 16 bits
		andi $t0, $t0, 63 	# set all bits to 0 except the entrance bits

		move $v0, $t0
		jr $ra


	.globl filter_victory_zone
	filter_victory_zone:
		# $a0 = team address in memory

		# Load team data
		lw	$t0,	($a0)		# load team

		# Filter victory zone
		# 2 bits from selected + 7 bits from goal zone
		srl $t0, $t0, 9 	# 2 + 7 = 9 bits
		andi $t0, $t0, 63 	# set all bits to 0 except the victory zone bits

		move $v0, $t0
		jr $ra

	.globl filter_goal_zone
	filter_goal_zone:
		# $a0 = team address in memory

		# Load team data
		lw	$t0,	($a0)		# load team

		# Filter goal zone
		srl $t0, $t0, 2 	# 2 bits from selected
		andi $t0, $t0, 63 	# set all bits to 0 except the goal zone bits

		move $v0, $t0
		jr $ra

	.globl filter_selected
	filter_selected:
		# $a0 = team address in memory

		# Load team data
		lw	$t0,	($a0)		# load team

		# Filter selected
		andi $t0, $t0, 3 	# set all bits to 0 except the selected bits

		move $v0, $t0
		jr $ra

	.globl set_selected
	set_selected:
		# $a0 = team address in memory
		# $a1 = selected value

		# Load team data
		lw	$t0,	($a0)		# load team

		# Check if the param is between 0 and 3
		li $t1, 3
		blt $a1, $zero, end_set_selected
		bgt $a1, $t1, end_set_selected

		# Selected is the 2 least significant bits
		# Clear the selected bits
		andi $t0, $t0, 0xFFFFFFFC
		# Set the selected bits
		or $t0, $t0, $a1

		# Store team data
		sw $t0, ($a0)		# store team data

		end_set_selected:
		jr $ra