####################################################################################################################
# Name:		Kevin A Roa
# Date:		03/20/2020
# Purpose: 	File that contains various useful macros for the main program
####################################################################################################################

# Print an integer to console
# %int = register with int value
.macro printInt (%int)
	li	$v0, 1
	move	$a0, %int
	syscall
.end_macro

# Print a char to console
# %char = char value
.macro printChar (%char)
	li	$v0, 11
	la	$a0, %char
	syscall
.end_macro

# Print a string to console
# %str = String in quotes
.macro printStr (%str)
	.data
			.align	2
	macro_str:	.asciiz %str
	.text
	li	$v0, 4
	la	$a0, macro_str
	syscall
.end_macro

# Get a string from the user
# %len = number of characters to read
# %buffer = label of input buffer
.macro getStr (%len, %buffer)
	li	$v0, 8
	move	$a0, %buffer
	li	$a1, %len
	syscall
.end_macro

# Open a file
# %name = register with string of filename
# %ret = register to store file descriptor
.macro openFile (%name, %ret)
	li	$v0, 13
	move	$a0, %name
	li	$a1, 0
	li	$a2, 0
	syscall
	move 	%ret, $v0
.end_macro

# Read the contents of a file
# %size = number of characters to read
# %desc = file descriptor
# %buffer = address of input buffer
# %count = register to store byte count
.macro readFile (%size, %desc, %buffer, %count)
	li	$v0, 14
	move	$a0, %desc
	move	$a1, %buffer
	li	$a2, %size
	syscall
	move	%count, $v0
.end_macro

# Close a file
# %desc = file descriptor
.macro closeFile (%desc)
	li	$v0, 16
	addi	$a0, %desc, 0
	syscall
.end_macro

# Allocate 1024 bytes of memory in the heap
# %size = number of bytes to allocate
# %ret = register to store address of allocated memory
.macro allocMem (%size, %ret)
	li	$v0, 9
	li	$a0, %size
	syscall
	move	%ret, $v0
.end_macro

# Make a new line in console
.macro newLine
	.data
		.align 2
	newln:	.asciiz	"\n"
	.text
	li	$v0, 11
	lw	$a0, newln
	syscall
.end_macro

# Remove the \n from the input so that it actually finds the file
# %len = max length of the string
# %input = register of input string
.macro fixInput (%len, %input)
	li	$t2, %len
	li	$t0, 0			# Byte index
	fixInputLoop:
	la	$t1, (%input)		# Get the next character
	add	$t1, $t1, $t0		# |
	lb	$t1, ($t1)		# |
	
	addi	$t0, $t0, 1		# Increment index
	bnez	$t1, fixInputLoop	# If character != 0 then loop
	beq	$t2, $t0, exitFixInput	# If index = max length then exit
	
	subiu	$t0, $t0, 2		# Go back 2 bytes
	la	$t1, (%input)		# Replace \n with 0
	add	$t1, $t1, $t0		# |
	sb	$0, ($t1)		# |
	exitFixInput:
.end_macro

# Exit the program if nothing was intered for file name
# %input = register of input string
.macro	testEmptyInput (%input)
	lb	$t0, (%input)		# Load the first index of string
	beq	$t0, $0, exit		# If it is 0 then exit
.end_macro

# Print out an error message for having an invalid file
# %count = register with number of bytes in file
.macro	testValidFile (%count)
	bgtz	%count, fileValid	# If count < 0 then print error
	printStr("Error opening file. Program terminating. ")
	newLine
	j exit
	fileValid:
.end_macro

# Print out the string to console
# %string = register to string
# %print = text to print out before printing file
.macro 	printFile(%string, %print)
	printStr(%print)		# Print identifier text
	newLine
	
	li	$v0, 4			# Print file contents
	move	$a0, %string		# |
	syscall				# |
	newLine
.end_macro

# Print out string with int afterwards
# %int = register with int to print
# %text = text in quotations to print
.macro	printData(%int, %text)
	newLine
	printStr(%text)
	printInt(%int)
.end_macro

# Take the data from a register and write it to static memory label
# I think this is an unnecessary requirement but whatever
# %data = register with string
# %size = register with size of string
# %label = text of label
.macro	writeToLabel(%data, %size, %label)
	li	$t0, 0			# Index
	writeLabelLoop:
		beq	$t0, %size, exitLabelLoop	# If index = size, exit
		
		add	$t1, %data, $t0	# Address of char
		lb	$t1, ($t1)	# Byte at address
		sb	$t1, %label($t0)# Store byte into label
		
		addi	$t0, $t0, 1
		
		j	writeLabelLoop
	exitLabelLoop:
	sb	$0, %label($t0)		# Put a 0 at the end to signify end of string
.end_macro

.macro	clearLabel(%label, %size)
	li	$t0, 0			# Index
	clearLabelLoop:
		beq	$t0, %size, exitClearLabelLoop	# If index = size, exit
		
		sb	$0, %label($t0)	# Clear byte
		
		addi	$t0, $t0, 1
		
		j 	clearLabelLoop
	exitClearLabelLoop:
.end_macro

# Clear the buffer
# %address = register with address of buffer
# %len = register with size of buffer
.macro clearBuffer(%address, %len)
	#li	$t0, %len		# Max length of buffer
	li	$t1, 0			# Index
	clearLoop:
	la	$t2, (%address)		# Get the next character
	add	$t2, $t2, $t1		# |
	sb	$0, ($t2)		# Change the character to 0
	
	addi	$t1, $t1, 1		# Increment index
	
	beq	%len, $t1, exitClear	# If Index = Max length, exit
	
	j	clearLoop
	exitClear:
.end_macro

# Clear the buffer immediate
# Used when you dont know exact length but maximum
# %address = register with address of buffer
# %len = max size of buffer
.macro clearBufferi(%address, %len)
	li	$t0, %len		# Max length of buffer
	li	$t1, 0			# Index
	clearLoop:
	la	$t2, (%address)		# Get the next character
	add	$t2, $t2, $t1		# |
	sb	$0, ($t2)		# Change the character to 0
	
	addi	$t1, $t1, 1		# Increment index
	
	beq	$t0, $t1, exitClear	# If Index = Max length, exit
	
	j	clearLoop
	exitClear:
.end_macro

# Terminate the program
.macro KILL
	li	$v0, 10
	syscall
.end_macro












