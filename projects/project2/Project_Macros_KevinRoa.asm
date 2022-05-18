####################################################################################################################
# Name:		Kevin A Roa
# Date:		03/20/2020
# Purpose:	Macros for HW8 main file
####################################################################################################################

.eqv	OFFSET	5000
.eqv	SLEEP	0

# Draw a pixel on screen
# %x = X position
# %y = Y position
# %color = 24bit RGB value
.macro	drawPx (%x, %y, %color)
	move	$a0, %x		# Set $a0 to current x value
	move	$a1, %y		# Set $a1 to current y value
	move	$a2, %color	# Set $a2 to the color
	jal	drawPixel
.end_macro

# Draw a box
# %x = top left x value
# %y = top left y value
.macro	drawBox(%x, %y)
	drawTop(%x, %y)
	drawRight(%x, %y)
	drawBottom(%x, %y)
	drawLeft(%x, %y)
.end_macro

# Draw the top of the box
# %x = top left x value
# %y = top left y value
.macro drawTop(%x, %y)
	move	$t0, %x		# Move current X to $t0
	li	$t1, 0		# Counter for X position
	
	# Loop through pixels in row
	dTopLoop:
		beq	$t1, 7, dTopExit
		
		add	$t0, %x, $t1	# Current X + counter
		
		addi	$t8, $t8, OFFSET
		drawPx($t0, %y, $t8)
		
		addi	$t1, $t1, 1	# Next X pos

		sleep(SLEEP)
		j 	dTopLoop
	
	dTopExit:
.end_macro

# Draw the bottom of the box
# %x = top left x value
# %y = top left y value
.macro drawRight(%x, %y)
	addi	$t0, %x, 7
	li	$t1, 0
	move	$t2, %y
	
	# Loop through pixels in col
	dRightLoop:
		beq	$t1, 7, dRightExit
		
		add	$t2, %y, $t1	# Current X + counter
		
		addi	$t8, $t8, OFFSET
		drawPx($t0, $t2, $t8)
		
		addi	$t1, $t1, 1	# Next X pos
		
		sleep(SLEEP)
		j 	dRightLoop
	
	dRightExit:
.end_macro

# Draw the top of the box
# %x = top left x value
# %y = top left y value
.macro drawBottom(%x, %y)
	addi	$t0, %x, 7
	li	$t1, 7
	addi	$t2, %y, 7
	
	# Loop through pixels in row
	dBottomLoop:
		beqz	$t1, dBottomExit
		
		add	$t0, %x, $t1	# Current X + counter
		
		addi	$t8, $t8, OFFSET
		drawPx($t0, $t2, $t8)
		
		subi	$t1, $t1, 1	# Next X pos

		sleep(SLEEP)
		j 	dBottomLoop
	
	dBottomExit:
.end_macro

# Draw the left of the box
# %x = top left x value
# %y = top left y value
.macro drawLeft(%x, %y)
	move	$t0, %x
	li	$t1, 7
	addi	$t2, %y, 7
	
	# Loop through pixels in col
	dLeftLoop:
		beqz	$t1, dLeftExit
		
		add	$t0, %y, $t1	# Current X + counter
		
		addi	$t8, $t8, OFFSET
		drawPx(%x, $t0, $t8)
		
		subi	$t1, $t1, 1	# Next X pos
		
		sleep(SLEEP)
		j 	dLeftLoop
	
	dLeftExit:
.end_macro

# Pause the program for a set amount of time
# %time = time in ms
.macro sleep(%time)
	li	$a0, %time
	li	$v0, 32
	syscall
.end_macro

# Clear the entire screen
.macro wipeScreen
	jal	wipeScreen
.end_macro

# Get the center of the screen given any screen size
# %xReg = register holding the main X coord of the box
# %yReg = register holding the main Y coord of the box
.macro setCenter(%xReg, %yReg)
	addi 	$t0, $0, WIDTH		# $s1 = width
	sra 	$t0, $t0, 1		# width / 2
	subi	%xReg, $t0, 4		# subtract half of block
	addi 	$t1, $0, HEIGHT		# $s2 = height
	sra 	$t1, $t1, 1		# height / 2
	subi	%yReg, $t1, 4		# subtract half of block
.end_macro

# Clear a row of pixels
# %x = top left x value
# %y = top left y value
.macro	clearRow(%x, %y)
	li	$t7, 0
	
	# Loop through pixels in row
	cRowLoop:
		beq	$t7, 8, exitCRow
		
		add	$t1, %x, $t7
		drawPx($t1, %y, $0)
		
		addi	$t7, $t7, 1
		
		j	cRowLoop
	exitCRow:
.end_macro

# Clear a column of pixels
# %x = top left x value
# %y = top left y value
.macro	clearCol(%x, %y)
	li	$t7, 0
	
	# Loop through pixels in col
	cColLoop:
		beq	$t7, 8, exitCCol
		
		add	$t1, %y, $t7
		drawPx(%x, $t1, $0)
		
		addi	$t7, $t7, 1
		
		j	cColLoop
	exitCCol:
.end_macro

# Find out what key was pressed
.macro getKey
	lw	$s3, 0xffff0004
	
	beq	$s3, 119, up		# W
	beq	$s3, 100, right		# D
	beq	$s3, 115, down		# S
	beq	$s3, 97, left		# A
	beq	$s3, 32, exit		# Space
	beq	$s3, 27, exit		# Esc
.end_macro
