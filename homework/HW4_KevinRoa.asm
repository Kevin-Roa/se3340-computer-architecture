####################################################################################################################
# Name:		Kevin A Roa
# Date:		03/07/2020
# Purpose: 	Read input file, extract numbers, selection sort them and then print to console.
#		Calculate mean, median, and standard deviation.
####################################################################################################################
.data 
	buffer:		.space	80
			.align  2
	arr:		.space	80
			.align  2
			
	prompt1:	.asciiz	"The array before: "
	prompt2:	.asciiz "The array after:  "
	prompt3:	.asciiz "The mean is: "
	prompt4:	.asciiz "The meadian is: "
	prompt5:	.asciiz "The standard deviation is: "
	errMsg:		.asciiz "Error: File contains no data."
			.align	2
	newln:		.asciiz	"\n"

	fout:		.asciiz "input.txt"
	
# Make a new line in console
.macro	newLine
	li	$v0, 11
	lw	$a0, newln
	syscall
.end_macro

# Print a line of text in console
.macro 	printText(%text)
	li	$v0, 4
	la	$a0, (%text)
	syscall
.end_macro

.text
main:
	# Read file
	la	$a0, fout
	la	$a1, buffer
	jal 	read
	
	# Check if data was actually read
	blez	$v0, arrErr	
	
	# Convert file contents to ints
	la	$a0, arr
	li	$a1, 20
	la	$a2, buffer
	jal 	convert
	
	# Print unsorted array
	la	$a0, arr
	li	$a1, 20
	la	$a2, prompt1
	jal	printArr

	# Sort the array
	la	$a0, arr
	li	$a1, 20
	jal	sortArr
	
	# Print sorted array
	la	$a0, arr
	li	$a1, 20
	la	$a2, prompt2
	jal	printArr
	
	# Calculate the mean of the array
	la	$a0, arr
	li	$a1, 20
	jal 	calcMean
	
	# Calculate the median of the array
	la	$a0, arr
	li	$a1, 20
	jal	calcMedian
	
	# Calculate the standard deviation of the array
	la	$a0, arr
	li	$a1, 20
	la	$a2, buffer
	jal	calcStDev
	

exit:	# Terminate program
	li	$v0, 10
	syscall
	
####################################################################################################################
# Reads file
# Input:
# $a0 = file name
# $a1 = data buffer
# Output:
# $v0 = # of bytes read
read:
	# Set $a1 to $t1 to be used later
	move 	$t1, $a1
	
	# Open file
	li	$v0, 13
	li	$a1, 0
	li	$a2, 0
	syscall
	
	# Save file descriptor
	move 	$s6, $v0

	# Read File
	li	$v0, 14
	move	$a0, $s6
	move	$a1, $t1
	li	$a2, 80
	syscall
	
	# Save byte count
	move	$t1, $v0
	
	# Close file
	li	$v0, 16
	move 	$a0, $s6
	syscall

	# Set $v0 to byte count
	move 	$v0, $t1
	
	jr 	$ra

# Converts text from the input buffer into actual ints and stores it in array
# Input:
# $a0 = array address
# #a1 = array size
# #a2 = buffer address
convert:
	# Temp holder for calculating int
	li	$t0, 0
	# Temp count for place value
	li	$t2, 0
	# Temp count for total ints
	li	$t3, 0
	
	convLoop:
		# Get byte
		lb	$t1, 0($a2)
		
		# If byte == \n then add int to array and go to start of loop
		beq	$t1, 10, convNextInt
		# Else If int count = array size then exit the loop (You are through the array)
		beq	$a1, $t3, convExit
		# Else If byte < 48 go back to start of loop (not # 0-9)
		blt	$t1, 48, convReset
		# Else If byte > 57 go back to start of loop (not # 0-9)
		bgt	$t1, 57, convReset
		
		
		# Else:
		# Subtract 48 to convert from hex to int
		subi	$t1, $t1, 48
		
		# If $t2 is 0 then skip multiplication
		# This only works for files with ints of length 2
		beqz	$t2, convPass
		mul	$t0, $t0, 10
		
		convPass:
		# Add int to total
		add	$t0, $t0, $t1
		# Increment place value
		addi	$t2, $t2, 1
		
		j	convBreak
		
		convNextInt:
			# Store the calculated int into array
			sw	$t0, 0($a0)
			addi	$a0, $a0, 4
			
			# Increment int count
			addi	$t3, $t3, 1
			
		convReset:
			# Reset temp counters
			li	$t0, 0
			li	$t2, 0
		
		convBreak:
			# Goto next byte location
			addi	$a2, $a2, 1
		
		j	convLoop
	
	convExit:
	jr 	$ra
	
# Prints out contents of array
# Input:
# $a0 = array address
# $a1 = length
# $a2 = prompt address
printArr:
	li	$t0, 0		# Word counter
	move	$t1, $a0
	move	$t2, $a1
	
	printText($a2)
	
	# Loop over all array elements, printing their value with a space after
	printLoop:
		# If the counter = length, exit
		bge	$t0, $t2, printExit
		
		# Get next value in array
		lw	$a0, 0($t1)
		addi	$t1, $t1, 4
		
		# Print number with space after
		li	$v0, 1
		syscall
		li      $v0, 11  
		li      $a0, 32
    		syscall
    		
    		# Increment word counter
    		addi	$t0, $t0, 1
    		
    		j	printLoop
    		
	printExit:
	
	newLine
	
	jr	$ra

# Sort the array using selection sort
# Input:
# $a0 = array address
# $a1 = length	
sortArr:
	move	$t0, $a0	# Array Address
	move	$t2, $a1	# Length
	
	li	$t3, 0		# Outer loop counter
	li	$t4, 0		# Inner loop counter
	subi	$t5, $t2, 1	# Length - 1
	sortLoop:
		# If outer counter = length, exit
		bgt	$t3, $t5, sortExit
		
		add	$t6, $t3, 0	# Minimum value
		
		addi	$t4, $t3, 1
		innerSortLoop:
			bgt	$t4, $t2, innerSortExit
			
			# Get values at index and minimum
			sll	$t7, $t4, 2
			sll	$t8, $t6, 2
			add	$s0, $t0, $t7
			add	$s1, $t0, $t8
			lw	$t7, ($s0)
			lw	$t8, ($s1)
			# If value at index less than minimum, replace min
			bgt	$t7, $t8, minBranch
			addi	$t6, $t4, 0
			
			minBranch:
			# Increment counter
			addi	$t4, $t4, 1
			
			j innerSortLoop
			
		innerSortExit:
		# If min != i
		beq	$t6, $t3, swapBranch
		# Get values at addresses
		sll	$t7, $t3, 2
		sll	$t8, $t6, 2
		add	$s0, $t0, $t7
		add	$s1, $t0, $t8
		# Swap
		lw	$t7, ($s0)
		lw	$t8, ($s1)
		sw	$t8, ($s0)
		sw	$t7, ($s1)
		
		swapBranch:
		# Increment counter
		addi	$t3, $t3, 1
		
		j sortLoop
		
	sortExit:
	jr 	$ra

# Add emelents in an array
# Input:
# $a0 = array address
# $a1 = length
# Output:
# $v0 = total
addArr:
	li	$t0, 0		# Int counter
	move	$t1, $a0
	move	$t2, $a1
	li	$v0, 0		# Total	
	addLoop:
		# If the counter = length, exit
		bge	$t0, $t2, addExit
		
		# Get next value in array
		lw	$t3, 0($t1)
		addi	$t1, $t1, 4
		
		# Add element to total
		add	$v0, $v0, $t3
    		
    		# Increment word counter
    		addi	$t0, $t0, 1
    		
    		j	addLoop
    		
	addExit:
	jr	$ra

# Calculate the mean of the array
# Input:
# $a0 = array address
# $a1 = length
# Output:
# $f11 = mean
calcMean:
	# Add $ra to stack
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	# Get total of array elements
	jal	addArr
	
	# Move total into coproc 1
	mtc1	$v0, $f1
	cvt.s.w	$f1, $f1
	# Move length into coproc 1
	mtc1	$a1, $f3
	cvt.s.w	$f3, $f3
	# Divide total by length to get single precision mean
	div.s	$f12, $f1, $f3
	
	# Print out the mean
	la	$t1, prompt3
	printText($t1)
	li	$v0, 2
	syscall
	
	mov.s	$f11, $f12
	
	# Remove $ra from stack
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	
	newLine
	
	jr 	$ra

# Calculate the median of the array
# Input:
# $a0 = array address
# $a1 = length
calcMedian:
	# Test if length even or odd. If odd $t0 = 0, else = 1
	andi	$t0, $a1, 1
	
	beqz	$t0, calcEven
	
	# Odd:
	# Get the index of middle number
	div	$t0, $a1, 2
	mflo	$t0
	sll	$t0, $t0, 2
	add	$t0, $t0, $a0
	
	# Get the median number and convert to float 
	# The instructions said to use $v1 as a flag but this does the same thing
	lw	$t0, ($t0)
	mtc1	$t0, $f1
	cvt.s.w	$f12, $f1
	
	j	printMedian
	
	calcEven:
	# Get the index of middle numbers
	div	$t0, $a1, 2
	mflo	$t0
	sll	$t0, $t0, 2
	add	$t0, $t0, $a0
	
	# Get the contents of both middle numbers
	lw	$t1, ($t0)
	lw	$t2, -4($t0)
	
	# Add them
	add	$t0, $t1, $t2
	
	# Divide them using single precision
	mtc1	$t0, $f1
	cvt.s.w	$f1, $f1
	li	$t1, 2
	mtc1	$t1, $f3
	cvt.s.w	$f3, $f3
	div.s	$f12, $f1, $f3
	
	# Print out the median
	printMedian:
	la	$t1, prompt4
	printText($t1)
	li	$v0, 2
	syscall
	
	newLine
	
	jr	$ra

# Calculate the standard deviation of the array
# Input:
# $a0 = array address
# $a1 = length
# $f11 = mean
calcStDev:
	li	$t0, 0		# Word counter
	li	$t1, 0		# Total
	mtc1	$t1, $f1
	cvt.s.w	$f1, $f1
	
	stDevLoop:
		# If the counter = length, exit
		bge	$t0, $a1, stDevExit
		
		# Get next int
		lw	$t3, 0($a0)
		addi	$a0, $a0, 4
		# Convert it to float
		mtc1	$t3, $f3
		cvt.s.w	$f3, $f3
		
		# Subtract it from mean
		sub.s	$f3, $f3, $f11
		# Square it
		mul.s	$f3, $f3, $f3
		# Add it to total
		add.s	$f1, $f1, $f3
		
		# Increment counter
		addi	$t0, $t0, 1
		
		j	stDevLoop
		
	stDevExit:
	# Divide by # of values - 1
	subi	$a1, $a1, 1
	mtc1	$a1, $f3
	cvt.s.w	$f3, $f3
	div.s	$f1, $f1, $f3
	# Sqrt the result from above
	sqrt.s	$f12, $f1
	
	# Print out the standard deviation
	la	$t1, prompt5
	printText($t1)
	li	$v0, 2
	syscall
	newLine
	
	jr	$ra

# Print out an error message for having no file/empty file	
arrErr:
	li	$v0, 4
	la	$a0, errMsg
	syscall
	newLine
	j exit
