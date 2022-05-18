####################################################################################################################
# Name:		Kevin A Roa
# Date:		03/20/2020
# Purpose:	Use the Bitmap Display to draw a moving square with a marqee effect
# Instructions:	1. Connect bitmap display
#		2. Set unit dimensions to 4x4
#		3. Set display dimensions to 256 x 256
#		4. Set $gp as base address
#		5. Connect keyboard
#		6. Use W/A/S/D to move, Esc/Space to exit
#		7. Run program
####################################################################################################################
.include	"Project_Macros_KevinRoa.asm"

# Resolution of 64 x 64
.eqv	WIDTH	64
.eqv	HEIGHT	64

.text
main:
	# Get center position of screen
	setCenter($s1, $s2)	# Set $s1 and $s2 to the screen center point (x,y)
	li	$t8, 0		# Variable for color position (yes I know this shouldn't be a t reg)
	
	wipeScreen		# Clear screen before starting program
	
loop:
	# Draw the box with the top left corner at ($s1, $s2)
	drawBox($s1, $s2)
	
	# Check for user input
	lw	$t0, 0xffff0000
	# If no input, loop back
	beq	$t0, 0, loop	
	# Else:
	# Determine what key was pressed 
	getKey
	
	j loop
	
exit:	# Exit the program
	li	$v0, 10
	syscall
	
####################################################################################################################

# Draw a pixel on the screen
# $a0 = X
# $a1 = Y
# $a2 = Color
drawPixel:
	# Add $ra to stack
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	# Set $t9 to address of current pixel
	mul	$t9, $a1, WIDTH
	add	$t9, $t9, $a0
	mul	$t9, $t9, 4
	add	$t9, $t9, $gp
	
	# Store color at that pixel address
	sw	$a2, ($t9)
	
	# Remove $ra from stack
	lw	$ra, ($sp)
	addi	$sp, $sp, 4	
	
jr 	$ra

# W key pressed
up:
	# Clear the top and bottom rows
	clearRow($s1, $s2)
	addi	$t0, $s2, 7
	clearRow($s1, $t0)
	
	subi	$s2, $s2, 1	# Move Y coord down 1
	
j	loop

# D key pressed	
right:
	# Clear the left and right columns
	clearCol($s1, $s2)
	addi	$t0, $s1, 7
	clearCol($t0, $s2)
	
	addi	$s1, $s1, 1	# Move X coord up 1
	
j	loop

# S key pressed
down:
	# Clear the top and bottom rows
	clearRow($s1, $s2)
	addi	$t0, $s2, 7
	clearRow($s1, $t0)
	
	addi	$s2, $s2, 1	# Move Y coord up 1
	
j	loop
	
# A key pressed
left:
	# Clear the left and right columns
	clearCol($s1, $s2)
	addi	$t0, $s1, 7
	clearCol($t0, $s2)
	
	subi	$s1, $s1, 1	# Move X coord down 1
	
j	loop

# Clear the entire screen by filling it with black
# Inefficient but only runs at start of program
wipeScreen:
	# Add $ra to stack
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	
	li	$t0, 0		# Var for current pos
	li	$t1, WIDTH
	mul	$t1, $t1, $t1	# Width^2
	
	# Loop through every pixel
	# Takes advantage of the fact that the display loops
	# when the x value is greater than the width
	scrWipeLoop:
		beq	$t0, $t1, exitScrWipe
		
		# Set pixel to black
		drawPx($t0, $0, $0)
		
		addi	$t0, $t0, 1
		
		j	scrWipeLoop
	
	exitScrWipe:
	
	# Remove $ra from stack
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	
jr 	$ra
	
