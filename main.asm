.data
	msg:	.asciiz	"\nHello, Ludo!\n"
.text
main:
	li	$v0,	4	# code: print
	la	$a0,	msg	# put msg address on a0
	syscall
	
	li	$v0,	10	# code: finish
	syscall