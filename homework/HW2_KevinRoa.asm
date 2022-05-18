.data
a:	.word	0
b:	.word	0
c:	.word	0
out1:	.asciiz	"output 1"
out2:	.asciiz "output 2"
out3:	.asciiz	"output 3"
name:	.space 20
prompt1:.asciiz	"What is your name? "
prompt2:.asciiz	"Enter an integer from 1-100: "
prompt3:.asciiz	"Your answers are: "

.text
main:	
	# output name prompt
	li	$v0, 4
	la	$a0, prompt1
	syscall
	
	# input name
	li	$v0, 8
	li	$a1, 20
	la	$a0, name
	syscall

exit:
	li	$v0, 10
	syscall
