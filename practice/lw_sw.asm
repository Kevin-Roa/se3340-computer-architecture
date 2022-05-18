.data
a:	.word	4
b:	.word 	5
c:	.word 	9
d:	.word 	9

.text
main: 	# Main indicates the start of the program
	# Load into t1 the contents of label a
	# Looks at register a, copies it, and sets t1 to it
	lw	$t1, a
	
	# Load b into t2
	lw	$t2, b
	
	# Does the opposite of the lw
	# Copies what is in the register to the memory address
	# Copies what is in t1 into memory address c
	sw	$t1, c
	
	# copy t2 into d
	sw	$t2, d

	# This will just exit the program
exit:	#This label is used later on to jump to
	li $v0, 10 
	syscall 