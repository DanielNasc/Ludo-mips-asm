.text
	.globl roll_die
    	roll_die:				# gen numbers in range [0,6]
      		li 	$a1,	7		# upper bound of random number
      		li	$v0,	42		# 42 -> code for "random int range"
	      	syscall
      	
	      	jr	$ra			# back from subroutine, $a0 = random int
