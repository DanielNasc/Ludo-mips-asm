.text
.globl roll_die
.globl update_pos
    	roll_die:				# gen numbers in range [0,6]
      		li 	$a1,	7		# upper bound of random number
      		li	$v0,	42		# 42 -> code for "random int range"
	      	syscall
      	
	      	jr	$ra			# back from subroutine, $a0 = random int
	      	
	update_pos:				# 
		# a0 -> pos vector in ram
		# a1 -> value to increment/decrement to x
		# a2 -> value to increment/decrement to y
		lw	$t0,	($a0)		# set $t0 as x
		lw	$t1,	4($a0)		# set $t1 as y
		
		add	$t0,	$t0,	$a1	# add mov direction to pos x
		add	$t1,	$t1,	$a2	# add mov direction to pos y
		
		# ------------------------
		
		# TODO:
		#  >> check if pos is permited
		#	if not, then doesnt not update it and return 1
		#	if yes, then update it and return 0
		
		# ------------------------
		
		sw	$t0,	($a0)		# store new x
		sw	$t1,	4($a0)		# store new y
		
		li	$v0,	0		# UPDATED
		jr	$ra			# return 0
		