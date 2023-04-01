.data
	msg:	.asciiz	"\nHello, Ludo!\n"
.text
.globl main
main:
	jal	roll_die
	li	$v0,	1
	syscall
	
	li	$v0,	10
	syscall