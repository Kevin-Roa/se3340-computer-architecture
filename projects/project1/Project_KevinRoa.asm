####################################################################################################################
# Name:		Kevin A Roa
# Date:		03/20/2020
# Purpose: 	Compress a file using RLE. Learn to use a seperate macro file to assist the main program
####################################################################################################################
.include	"Project_Macros_KevinRoa.asm"

.data
	# Allocate 1024 bytes in static memory for decompressed file
	# This seems like a weird requirement considering everything else was done dynamically...
	# I still did everything dynamically and just set this at the end
	decompressed:	.space	1024
.text
main:
	# Allocate 1024 bytes dynamic memory for input 
	# Save to $s0
	allocMem(1024, $s0)
	# Allocate 1024 bytes dynamic memory for compressed 
	# Save to $s1
	allocMem(1024, $s1)
	# Allocate 128 bytes dynamic memory for filename 
	# Save to $s2
	allocMem(128, $s2)
	
loop:
	# Prompt user to enter a filename
	newLine
	printStr("Please enter the filename to compress or <enter> to exit: ")
	getStr(128, $s2)		# Store filename in $s2, max 128 bytes
	fixInput(128, $s2)		# Remove the terminator from the input
	
	# Test if input was empty
	testEmptyInput($s2)
	
	newLine
	
	# Open the file
	openFile($s2, $s3)		# Open file and store file descriptor in $s3
	readFile(1024, $s3, $s0, $s4)	# Read the file and store contents in $s0, byte count in $s4
	closeFile($s3)			# Close the file
	
	# Test if file is valid (size > 0)
	testValidFile($s4)

	# Print the uncompressed data
	printFile($s0, "Original data: ")
	
	# Compress the file
	move	$a0, $s0		# Input buffer address
	move	$a1, $s1		# Output buffer address
	move	$a2, $s4		# Size of file
	jal	compress		# Compress the file
	move	$s5, $v0		# Set $s5 to compressed size
	
	# Print the conpressed data
	printFile($s1, "Compressed data: ")
	
	# Decompress the file
	clearBuffer($s0, $s4)		# Clear $s0 to be rewritten when decompressed
	move	$a0, $s1		# Input buffer address
	move	$a1, $s0		# Output buffer address
	move	$a2, $s5		# size of compressed file
	jal 	decompress		# Decompress the file
	writeToLabel($s0, $s4, decompressed)	# Store decompressed to static memory (still think this is unnecessary)
	
	# Print the decompressed data
	printFile($s0, "Decompressed data: ")
	
	# Print file sizes of uncompressed vs compressed
	printData($s4, "Original file size:   ")
	printData($s5, "Compressed file size: ")
	
	# Clear the strings in memory for the next run
	clearBuffer ($s0, $s4)
	clearBuffer ($s1, $s5)
	clearBufferi($s2, 128)
	
	# Return to start of loop
	newLine
	j	loop
	
exit:	KILL
	
####################################################################################################################

# Compress the given data using RLE
# Input:
# $a0 = address of input buffer
# $a1 = address of compression buffer
# $a2 = size of original file
# Output:
# $v0 = size of compressed data
compress:
	li	$t0, 0				# Index 
	li	$t5, 0				# Compressed Index
	compressLoop:
		beq	$t0, $a2, exitCompress	# If index = file size, exit
		
		li	$t2, 1			# Char count
		compressCountLoop:
			add	$t3, $a0, $t0	# Address of current byte
			addi	$t4, $t3, 1	# Address of next byte
			lb	$t3, ($t3)	# Current byte
			lb	$t4, ($t4)	# Next byte
			
			bne	$t3, $t4, exitCountLoop	# If Current and next byte not equal, exit loop
			
			addi	$t2, $t2, 1	# Char count + 1
			addi	$t0, $t0, 1	# Index + 1
			
			j	compressCountLoop
			
		exitCountLoop:
		# Add character to buffer
		add	$t6, $a1, $t5		# Address of end of compression buffer
		add	$t7, $a0, $t0		# Address of current byte
		lb	$t7, ($t7)		# Current byte
		sb	$t7, ($t6)		# Store byte into compression buffer
		addi	$t5, $t5, 1		# Increment compression index
		
		# Add count to buffer
		addi	$t6, $t6, 1		# Next space in compression buffer
		addi	$t8, $t2, 48		# int to char
		sb	$t8, ($t6)		# Store count into compression buffer
		addi	$t5, $t5, 1		# Increment compression index
		
		addi	$t0, $t0, 1		# Index + 1
		
		j	compressLoop
		
	exitCompress:
	move	$v0, $t5			# Store compressed file size in $v0
	
	jr	$ra
	
# Decompress the given data
# Input:
# $a0 = address of input buffer
# $a1 = address of decompression buffer
# $a2 = size of compressed data
decompress:
	li	$t0, 0				# Index
	li	$t5, 0				# Decompressed Index
	
	decompressLoop:
		beq	$t0, $a2, exitDecompress# If index = size, exit loop
		
		# Get char and count
		add	$t1, $a0, $t0		# Address of char
		addi	$t3, $t1, 1		# Address of count
		lb	$t1, ($t1)		# Character
		lb	$t2, ($t3)		# Count
		subi	$t2, $t2, 48		# Subtract 48 from count to convert to int
		
		li	$t3, 0			# Counter
		decompInsertLoop:
			beq	$t2, $t3, exitInsertLoop
			
			# Write char to decompression buffer
			add	$t4, $a1, $t5	# Address of end of decompressed buffer
			sb	$t1, ($t4)	# Store char into decompressed buffer
			addi	$t5, $t5, 1	# Increment decompressed index
			addi	$t3, $t3, 1	# Increment counter
			
			j	decompInsertLoop
			
			exitInsertLoop:
		
		addi	$t0, $t0, 2		# Increment index to next char
		
		j	decompressLoop
	
	exitDecompress:
	jr	$ra



