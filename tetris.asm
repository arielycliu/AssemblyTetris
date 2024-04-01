######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
# coordinate system has top left corner as origin -> goes from 0 to 31 assuming default bitmap configuration
##############################################################################

# GENERAL RULES OF THUMB
# stack used for return pointers if function calls another function
# ra used for return pointers if function does not call any other function
# function arguments in a0-a3
# return values in v0-v1
# read values from constants in functions to avoid errors from other programs overriding values (read into t0-t9)
# t9 sometimes used to store return address popped from stack
# current piece x and y is the x, y coord of the top left of the 4x4 grid tetris pieces are drawn from
# the color of the dead piece is stored in the game field

######################## Memory Model Configuration ########################
# - Display address:            $t0 (reload when using)
# - Keyboard address:           $t1 (reload when using)
# - Current piece orientation:  $s0
# - Current piece x:            $s1
# - Current piece y:            $s2
# - Type of current piece:      $s3 (I is 0, O is 1, T is 2, etc for S, Z, J, L)
# - Return address:             $t9 or $t8 (where it's stored when stack is inconvient)
# - Line type argument:         $s7-s6 (extra argument since we don't have enough a0-a3 registers, stores 1 for solid and 2 for dotted lines)
# s values are used when there are too many arguments and when we need to keep function values when calling a sub function
# v0-v1 (return) a0-a3 (arg) t0-t9 s0-s7
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
ADDR_DSPL:
    .word 0x10008000
ADDR_KBRD:
    .word 0xffff0000
BOARD_WIDTH:
    .word 10
BOARD_HEIGHT:
    .word 20
    
UNIT_WIDTH:
    .word 8
UNIT_HEIGHT:
    .word 8
DISPLAY_WIDTH:
    .word 256
DISPLAY_HEIGHT:
    .word 256


##############################################################################
# Mutable Data
##############################################################################
    
    cyan:          .word 0x0000FFFF  # I - 0
    yellow:        .word 0x00FFFF00  # O - 1 
    purple:        .word 0x00800080  # T - 2
    green:         .word 0x0000FF00  # S - 3 
    red:           .word 0x00FF0000  # Z - 4 
    blue:          .word 0x000000FF  # J - 5
    orange:        .word 0x00FF7F00  # L - 6
    white: 	       .word 0x00FFFFFF  # border color
    light_grey:    .word 0x00E0E0E0	 # checkered grid light color
	dark_grey:     .word 0x007F7F7F  # checkered grid dark color
	board_state:   .word 0:200       # used to store current pieces on the board (BOARD_WIDTH * BOARD_HEIGHT = 200)
	                                 # each coordinate will store 0 if no piece is there or the name of the piece I, O, T, S, Z, J, L if it's the top left corner of the piece
	                                 # initialized to value of 0
    
    # TETRIS PIECES
    # Note that moving the address pointer by 64 (which is 16 * sizeof(byte)) we can move to the next position
    sizeof_piece_data: .word 64
    numofrows_piece_data: .word 4
    
    # I piece
    I0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x0000FFFF, 0x0000FFFF, 0x0000FFFF, 0x0000FFFF
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
	
	I1: .word 0x00000000, 0x00000000, 0x0000FFFF, 0x00000000
		.word 0x00000000, 0x00000000, 0x0000FFFF, 0x00000000
		.word 0x00000000, 0x00000000, 0x0000FFFF, 0x00000000
		.word 0x00000000, 0x00000000, 0x0000FFFF, 0x00000000
	
	I2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x0000FFFF, 0x0000FFFF, 0x0000FFFF, 0x0000FFFF
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		
	I3: .word 0x00000000, 0x0000FFFF, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FFFF, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FFFF, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FFFF, 0x00000000, 0x00000000
	
	# O piece
	O0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
	
	O1: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
    
    O2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		
	O3: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00FFFF00, 0x00FFFF00, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
    
    # T piece
    T0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00800080, 0x00000000, 0x00000000
		.word 0x00800080, 0x00800080, 0x00800080, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
	
	T1: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00800080, 0x00000000, 0x00000000
		.word 0x00000000, 0x00800080, 0x00800080, 0x00000000
		.word 0x00000000, 0x00800080, 0x00000000, 0x00000000
		
	T2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00800080, 0x00800080, 0x00800080, 0x00000000
		.word 0x00000000, 0x00800080, 0x00000000, 0x00000000
	
	T3: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00800080, 0x00000000, 0x00000000
		.word 0x00800080, 0x00800080, 0x00000000, 0x00000000
		.word 0x00000000, 0x00800080, 0x00000000, 0x00000000
		
	# S piece
	S0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FF00, 0x0000FF00, 0x00000000
		.word 0x0000FF00, 0x0000FF00, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
	
	S1: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FF00, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FF00, 0x0000FF00, 0x00000000
		.word 0x00000000, 0x00000000, 0x0000FF00, 0x00000000
    
    S2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FF00, 0x0000FF00, 0x00000000
		.word 0x0000FF00, 0x0000FF00, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		
	S3: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x0000FF00, 0x00000000, 0x00000000, 0x00000000
		.word 0x0000FF00, 0x0000FF00, 0x00000000, 0x00000000
		.word 0x00000000, 0x0000FF00, 0x00000000, 0x00000000
		
	# Z piece
	Z0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00FF0000, 0x00FF0000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF0000, 0x00FF0000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
	
	Z1: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00FF0000, 0x00000000
		.word 0x00000000, 0x00FF0000, 0x00FF0000, 0x00000000
		.word 0x00000000, 0x00FF0000, 0x00000000, 0x00000000
    
    Z2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00FF0000, 0x00FF0000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF0000, 0x00FF0000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		
	Z3: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF0000, 0x00000000, 0x00000000
		.word 0x00FF0000, 0x00FF0000, 0x00000000, 0x00000000
		.word 0x00FF0000, 0x00000000, 0x00000000, 0x00000000
		
	# J piece
	J0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x000000FF, 0x000000FF, 0x000000FF, 0x00000000
		.word 0x00000000, 0x00000000, 0x000000FF, 0x00000000
	
	J1: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x000000FF, 0x00000000, 0x00000000
		.word 0x00000000, 0x000000FF, 0x00000000, 0x00000000
		.word 0x000000FF, 0x000000FF, 0x00000000, 0x00000000
    
    J2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x000000FF, 0x00000000, 0x00000000, 0x00000000
		.word 0x000000FF, 0x000000FF, 0x000000FF, 0x00000000
		
	J3: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x000000FF, 0x000000FF, 0x00000000
		.word 0x00000000, 0x000000FF, 0x00000000, 0x00000000
		.word 0x00000000, 0x000000FF, 0x00000000, 0x00000000
		
	# L piece
	L0: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00FF7F00, 0x00FF7F00, 0x00FF7F00, 0x00000000
		.word 0x00FF7F00, 0x00000000, 0x00000000, 0x00000000
	
	L1: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00FF7F00, 0x00FF7F00, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF7F00, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF7F00, 0x00000000, 0x00000000
    
    L2: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00000000, 0x00FF7F00, 0x00000000
		.word 0x00FF7F00, 0x00FF7F00, 0x00FF7F00, 0x00000000
		
	L3: .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF7F00, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF7F00, 0x00000000, 0x00000000
		.word 0x00000000, 0x00FF7F00, 0x00FF7F00, 0x00000000
		
##############################################################################
# Code
##############################################################################
	.text
	.globl main

main:
    
    jal draw_border
    jal draw_checkerboard
    jal generate_new_piece  # generates x, y, type, position of piece and jumps to draw_new_piece
    jal draw_current_piece
    
    # jal store_dead_piece_in_board_state # stores current piece in board
    
    b game_loop
    
    # li $v0, 10     # syscall code for exit
    # syscall        # perform syscall to exit program

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    jal check_for_key_press
    
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# jal draw_checkerboard only draw on update
	# jal draw_dead_pieces
	jal draw_current_piece
	
	
	# 4. Sleep
    li $v0, 32
    li $a0, 3000  # sleep for 100 milliseconds
    #5. Go back to 1
    b game_loop

##################################################################################################################################################################################
# Keyboard sensing logic
##################################################################################################################################################################################

# Function that checks if a key has been pressed, if yes, then calls keyboard_input to handle it
check_for_key_press:    
    lw $t0, ADDR_KBRD
    lw $t1, 0($t0) # Load first word from keyboard
    beq $t1, 1, keyboard_input # If the first word 1, a key has been pressed
    jr $ra # otherwise return

# Function that calls different functions depending on the key pressed
keyboard_input:
    # ra should be unchanged from check_for_key_press
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    lw $t1, 4($t0) # Load second word from keyboard
    beq $t1, 0x71, quit     # quit if key q is pressed
    beq $t1, 119, w_key     # w
    beq $t1, 97, a_key      # a
    beq $t1, 115, s_key     # s
    beq $t1, 100, d_key     # d
    
    j keyboard_input_exit
    
# Code to exit to game_loop
keyboard_input_exit:
     # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra # return to where check_for_key_press was called in game_loop

# Quits the game
quit:
	li $v0, 10
	syscall
	
w_key:
    # change current piece orientation
    add $s0, $s0, 1 # add 1 to current position
    li $t0, 4
    div $s0, $t0  # find newpos % 4 so that the position changes wrap around
    mfhi $s0   # store this remainder as the new position
    jal draw_checkerboard
    j keyboard_input_exit

a_key:
    addi $s1, $s1, -1
    jal draw_checkerboard
    j keyboard_input_exit

s_key:
    addi $s2, $s2, 1
    jal draw_checkerboard
    j keyboard_input_exit

d_key:
    addi $s1, $s1, 1
    jal draw_checkerboard
    j keyboard_input_exit

##################################################################################################################################################################################
# Drawing dead pieces from board state
##################################################################################################################################################################################

# Function that draw the dead pieces on top of the checkerboard 
draw_dead_pieces:
    # No arguments, no return values
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    li $a0, 0 # x
    li $a1, 0 # y
    jal calc_offset_board # RETURNS: $v0 calculated offset for writing to display
    move $s6, $v0 # write to this address
    
    li $s5, 0 # row count
    la $s4, board_state # read from this address
    b draw_dead_pieces_loop # jump to loop
    
# Loop for the function that draws dead pieces that loops 20 times for each row
draw_dead_pieces_loop:
    # ARGUMENTS:
    # - Current address of memory:  $s4 (place we read piece colors from) -> 0x10010048
    # - Rows drawn:                 $s5 (used to check end condition)
    # - Current address of display: $s6 (place we are writing the colors to) -> 0x1000832c
    
    jal draw_dead_pieces_draw_row_intro # one row
    add $s5, $s5, 1 # increment row count by 1
    
    # calculate new display address for next row
    move $a0, $s2  # x coord
    add $a1, $s2, $s5   # new y = y + rows_drawn
    jal calc_offset_board # calculate new display address
    move $s6, $v0 # store new address
    
    lw $t1, BOARD_HEIGHT
    blt $s5, $t1, draw_dead_pieces_loop  # if row_count >= board_height then return    
    
    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra

# Function that stores return pointer outside of loop 
# Without this function, having move $t9, $v0
# would cause $t9 to be overwritten with draw_current_dead_piece_pixel's $ra return address after draw_current_dead_piece_pixel is called
draw_dead_pieces_draw_row_intro:
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    li $a0, 0 # start pixel count
    j draw_dead_pieces_draw_row
# Function that draws BOARD_WIDTH number of pixels to form ONE row
draw_dead_pieces_draw_row:
    # ARGUMENTS: $a0 pixel count
    jal draw_current_dead_piece_pixel # draw a single pixel
    add $a0, $a0, 1
    
    lw $t1, BOARD_WIDTH 
    blt $a0, $t1, draw_dead_pieces_draw_row # if we have not drawn enough pixels to fit the width, then continue

    # RETURN TO: where draw_dead_pieces_draw_row was called in draw_dead_pieces_loop
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra
# Function to draw a single pixel and handles logic for when color is 0 (increment counter and avoid drawing that pixel)
draw_current_dead_piece_pixel:
    # ARGUMENTS:
    # - Current address of piece:   $s4
    # - Current address of display: $s6 (originally from calc_offset_board)
    lw $t0, 0($s4)  # load color at piece data address to t0
    beq $t0, $zero, draw_current_dead_piece_pixel_exit  # if color is zero, exit the function early
    sw $t0, 0($s6)  # draw the pixel
    b draw_current_dead_piece_pixel_exit # exit
draw_current_dead_piece_pixel_exit:
    add $s6, $s6, 4  # move writing pointer by 1 pixel
	add $s4, $s4, 4  # move reading pointer by 1 pixel
    jr $ra
    
##################################################################################################################################################################################
# Storing dead pieces in board state
##################################################################################################################################################################################

# Function that stores the colors of the dead piece in the correct pixels of the board state
# that way we can specifically draw the colors of the dead pieces over the checkered background
store_dead_piece_in_board_state:
    # ARGUMENTS
    # - $s0 current piece orientation
    # - $s1 current piece x 
    # - $s2 current piece y
    # - $s3 current piece type
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    # Prep for loop function to be called later
    lw $t0, sizeof_piece_data  # 64 or piece offset (16 * 4)
    mul $t0, $t0, $s0  # calculate how much to move the address pointer by: $t0 = orientation * 64
    move $s4, $t0  # store the offset in the "future" address pointer - ARG for piece address
    li $s5, 0 # keeps track of pixels drawn in loop - ARG for row count
    jal calc_offset_board_state  # returns address to write to board_state in $v0
    move $s6, $v0 # store in s6 - ARG for writing address

    # Branching logic
    # Loads the address the tetris piece in .data - $a0
    # Loads which color to use when drawing - $a1
    
    li $t0, 0
    beq $s3, $t0, read_I_piece
    
    li $t0, 1
    beq $s3, $t0, read_O_piece
    
    li $t0, 2
    beq $s3, $t0, read_T_piece
    
    li $t0, 3
    beq $s3, $t0, read_S_piece
    
    li $t0, 4
    beq $s3, $t0, read_Z_piece
    
    li $t0, 5
    beq $s3, $t0, read_J_piece
    
    li $t0, 6
    beq $s3, $t0, read_L_piece 
    
read_I_piece:
    la $t0, I0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop

read_O_piece:
    la $t0, O0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop

read_T_piece:
    la $t0, T0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop

read_S_piece:
    la $t0, S0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop

read_Z_piece:
    la $t0, Z0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop

read_J_piece:
    la $t0, J0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop

read_L_piece:
    la $t0, L0  # load piece address
    add $s4, $s4, $t0 # add address to orientation offset
    b store_dead_piece_in_board_state_loop
    
store_dead_piece_in_board_state_loop:
    # ARGUMENTS:
    # - Current address of piece:   $s4 (place we read piece colors from)
    # - Rows drawn:                 $s5 (used to check end condition)
    # - Current address of memory:  $s6 (place we are writing the colors to)

	lw $t0, 0($s4)  # load color at piece data address to t0
    sw $t0, 0($s6)  # draw the pixel, it could draw 0
	
	add $s6, $s6, 4  # move memory pointer by 1 pixel
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	lw $t0, 0($s4)  # load color at piece data address to t0
    sw $t0, 0($s6)  # draw the pixel
	
	add $s6, $s6, 4  # move memory pointer by 1 pixel
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	lw $t0, 0($s4)  # load color at piece data address to t0
    sw $t0, 0($s6)  # draw the pixel
	
	add $s6, $s6, 4  # move memory pointer by 1 pixel
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	lw $t0, 0($s4)  # load color at piece data address to t0
    sw $t0, 0($s6)  # draw the pixel
	
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	add $s5, $s5, 1 # drew 4 pixels so increase count of rows by 1
	
	# PREP for next row
	# Move down a row since we must preserve the shape of each object in the board state
	add $s6, $s6, -12 # move memory pointer back to start of row
	
	li $t1, 4 # store 4 for multiplication
	lw $t2, BOARD_WIDTH
	mult $t1, $t1, $t2 # board_width * 4
	add $s6, $s6, $t1 # move memory pointer by 1 row
    
    # if pixels drawn >= 4
    lw $t1, numofrows_piece_data
    blt $s5, $t1, store_dead_piece_in_board_state_loop
    
    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra

# Function that take in x, y coord for a piece on the board and returns the address to start storing in the game_board
# def calc_offset_board_state(x, y):
    # global BOARD_WIDTH, BOARD_HEIGHT
    # offset = y * BOARD_WIDTH * 4  # vertical offset
    # offset += x * 4  # horizontal offset
    # return offset
calc_offset_board_state:
    # ARGUMENTS
    # - $s1 current piece x 
    # - $s2 current piece y
    
    # RETURNS
    # - $v0 offset board state address
    
    # use $t0 to store offset
    lw $t0, BOARD_WIDTH
    mult $t0, $t0, $s2  # board_width * y
    li $t1, 4
    mult $t0, $t0, $t1  # board_width * y * 4 -> vertical offset
    
    mult $t1, $t1, $s1 # t1 = x * 4 -> horizontal offset
    add $t0, $t0, $t1 # add vertical and horizontal offset together
    
    la $t2, board_state  # calculate address + offset
    add $v0, $t2, $t0  # return the address and the offset added together
    
    jr $ra

##################################################################################################################################################################################
# Generating and drawing "current" pieces (aka pieces in play)
##################################################################################################################################################################################

# Function that creates a new piece's information - DOES not call draw_piece
generate_new_piece:
    # No arguments
    # Sets the variables:
    # - $s0, $s1, $s2
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    # Generate a random number between 0 and 6
    li $v0, 42 # command for random number generation
    li $a0, 0  # random number generator ID
    li $a1, 7  # maximum value is exclusive
    syscall # stores return value in $a0
    
    move $s3, $a0  # move to where we are storing the piece type
    
    jal center_border
    # RETURNS:
    # - $v0 x_coord
    # - $v1 y_coord
    
    lw $t0, BOARD_WIDTH    
    srl $t0, $t0, 1 # shift right logical by 1 to divide by 2: find center of the board
    addi $t0, $t0, -2 # move to the left by 2 since the width of the piece field is 4
    
    # INIT PARAMETERS
    li $s0, 0 # current orientation (starts in the same position)
    move $s1, $t0 # store in x
    li $s2, 0 # store y (top of board)
    
    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra
    
# Function that draws the current piece based on s0-s3 variables
draw_current_piece:
    # ARGUMENTS:
    # - Current piece orientation:  $s0
    # - Current piece x:            $s1
    # - Current piece y:            $s2
    # - Type of current piece:      $s3 
    
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push

    # Prep for loop    
    # calculate offset based on current orientation
    lw $t0, sizeof_piece_data  # 64 or piece offset (16 * 4)
    # calculate how much to move the address pointer by
    mul $t0, $t0, $s0  # $t0 = orientation * 64
    # we will move pointer by this offset once we load which address to read from
    # e.g, pointer starts at T0, we can move the pointer to point to T1 instead if the orientation is 1
    move $s4, $t0  # store the offset in the "future" address pointer - ARG for piece address
    
    li $s5, 0 # keeps track of pixels drawn in loop - ARG for row count
    
    move $a0, $s1 # set x argument
    move $a1, $s2 # set y argument
    jal calc_offset_board  # returns display address at $v0, does not impact $s4
    move $s6, $v0 # store in s6 to avoid getting overwritten - ARG for display address

    # Branching logic
    # Loads the address of the tetris piece in .data - $s4
    
    # li $v0, 1
    # move $a0, $s3
    # syscall # print piece type
    
    li $t0, 0
    beq $s3, $t0, load_I_piece
    
    li $t0, 1
    beq $s3, $t0, load_O_piece
    
    li $t0, 2
    beq $s3, $t0, load_T_piece
    
    li $t0, 3
    beq $s3, $t0, load_S_piece
    
    li $t0, 4
    beq $s3, $t0, load_Z_piece
    
    li $t0, 5
    beq $s3, $t0, load_J_piece
    
    li $t0, 6
    beq $s3, $t0, load_L_piece

# 7 functions for loading the address and the color
# ARGUMENTS: $s0 for piece orientation
# RETURNS: $s4 updated to reflect offset + base address of piece
# Loads the address the tetris piece in .data (accounts for orientation) - $a0
# Which color is encoded in the tetris piece
load_I_piece:
    la $t0, I0
    add $s4, $s4, $t0 # add address to offset
    b draw_current_piece_loop

load_O_piece:
    la $t0, O0
    add $s4, $s4, $t0 # address + offset
    b draw_current_piece_loop

load_T_piece:
    la $t0, T0
    add $s4, $s4, $t0 # address + offset
    b draw_current_piece_loop

load_S_piece:
    la $t0, S0
    add $s4, $s4, $t0 # address + offset
    b draw_current_piece_loop

load_Z_piece:
    la $t0, Z0
    add $s4, $s4, $t0 # address + offset
    b draw_current_piece_loop

load_J_piece:
    la $t0, J0
    add $s4, $s4, $t0 # address + offset
    b draw_current_piece_loop

load_L_piece:
    la $t0, L0
    add $s4, $s4, $t0 # address + offset
    b draw_current_piece_loop

# Helper function for draw_current_piece_loop that handles the branching: to draw or not to draw the pixel
# We want to print the pixel only when the value is not 0 (aka black)
# By separating this out into a function, we can call it with jal and return to the same location
draw_current_piece_pixel:
    # ARGUMENTS:
    # - Current address of piece:   $s4
    # - Current address of display: $s6 (originally from calc_offset_board)
    lw $t0, 0($s4)  # load color at piece data address to t0
    beq $t0, $zero, draw_current_piece_pixel_exit  # if color is zero, exit the function early
    sw $t0, 0($s6)  # draw the pixel
    b draw_current_piece_pixel_exit # exit
draw_current_piece_pixel_exit:
    jr $ra
# Function that draws one line of the tetris piece and loops until the whole piece is drawn
draw_current_piece_loop:
    # ARGUMENTS:
    # - Current address of piece:   $s4
    # - Rows drawn:                 $s5 (used to check end condition when we've drawn 64 pixels)
    # - Current address of display: $s6 (originally from calc_offset_board)
    
	jal draw_current_piece_pixel
	
	add $s6, $s6, 4  # move display pointer by 1 pixel
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	jal draw_current_piece_pixel
	
	add $s6, $s6, 4  # move display pointer by 1 pixel
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	jal draw_current_piece_pixel
	
	add $s6, $s6, 4  # move display pointer by 1 pixel
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	jal draw_current_piece_pixel
	
	add $s4, $s4, 4  # move piece pointer by 1 pixel
	add $s5, $s5, 1 # drew 4 pixels so increase count of rows by 1
	
	# PREP for next row
	move $a0, $s1 # set x argument
    move $a1, $s2 # set y argument
    add $a1, $a1, $s5 # add the row count to the y argument
    jal calc_offset_board  # returns display address at $v0, does not impact $s4
    move $s6, $v0 # store in s6 to avoid getting overwritten - ARG for display address
	# we can leave the piece pointer alone as it will just continue to read the next value stored "chronologically"
    
    # if pixels drawn >= 4
    lw $t1, numofrows_piece_data
    blt $s5, $t1, draw_current_piece_loop
    
    # Otherwise, activate return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra


##################################################################################################################################################################################
# Basic drawing helper functions (perform calculations)
##################################################################################################################################################################################

# Function that take display stats and board stats to decide where the border starts and ends
# Python equivalent:
# def center_border():
    # global DISPLAY_WIDTH, DISPLAY_HEIGHT, UNIT_WIDTH, UNIT_HEIGHT, BOARD_WIDTH, BOARD_HEIGHT
    # DISPLAY_WIDTH = DISPLAY_WIDTH // UNIT_WIDTH
    # DISPLAY_HEIGHT = DISPLAY_HEIGHT // UNIT_HEIGHT
    # x_coord = (DISPLAY_WIDTH - BOARD_WIDTH) // 2 - 1
    # y_coord = (DISPLAY_HEIGHT - BOARD_HEIGHT) // 2 - 1
    # return x_coord, y_coord -> calculate x_coord + board_width + 1, y_coord + board_height + 1 (bottom right coord)
center_border:
    # ARGUMENTS (not passed in, loaded from constants):
    # - $a0 DISPLAY_WIDTH
    # - $a1 DISPLAY_HEIGHT
    # - $a2 BOARD_WIDTH
    # - $a3 BOARD_HEIGHT
    
    # RETURNS:
    # - $v0 x_coord
    # - $v1 y_coord
    
    # Load in arguments
    lw $a0, DISPLAY_WIDTH
    lw $a1, DISPLAY_HEIGHT
    lw $a2, BOARD_WIDTH
    lw $a3, BOARD_HEIGHT
    lw $t2, UNIT_WIDTH
    lw $t3, UNIT_HEIGHT
    
    # Use $t2 and $t3 for intermediate temp values in the calculations
    # calculate "new" display width and display height, divide them by unit width and unit hieght
    div $a0, $t2 # divide display width by unit width
    mflo $a0 # got "new" display width
    div $a1, $t3 # divide display height by unit height
    mflo $a1 # got "new" display height
    
    
    # calculate (display_width - board_width)
    sub $t2, $a0, $a2
    # calculate (display_height - board_height)
    sub $t3, $a1, $a3
    
    # store 2 in a register
    li $t4, 2
    # calculate (display_width - board_width) // 2
    div $t2, $t4
    mflo $t2 # load result from division 
    addi $v0, $t2, -1  # store x_coord - 1 in return register
    
    # calculate (display_height - board_height) // 2
    div $t3, $t4
    mflo $t3 # load result from division
    addi $v1, $t3, -1  # store y_coord - 1 in return register
    
    jr $ra # return

# Function that take display stats and board stats to decide where the board starts and ends
# Python equivalent:
# def center_board():
    # global DISPLAY_WIDTH, DISPLAY_HEIGHT, UNIT_WIDTH, UNIT_HEIGHT, BOARD_WIDTH, BOARD_HEIGHT
    # DISPLAY_WIDTH = DISPLAY_WIDTH // UNIT_WIDTH
    # DISPLAY_HEIGHT = DISPLAY_HEIGHT // UNIT_HEIGHT
    # x_coord = (DISPLAY_WIDTH - BOARD_WIDTH) // 2
    # y_coord = (DISPLAY_HEIGHT - BOARD_HEIGHT) // 2
    # return x_coord, y_coord
center_board:
    # ARGUMENTS (not passed in, loaded from constants):
    # - $t0 DISPLAY_WIDTH
    # - $t1 DISPLAY_HEIGHT
    # - $t2 BOARD_WIDTH
    # - $t3 BOARD_HEIGHT
    
    # RETURNS:
    # - $v0 x_coord
    # - $v1 y_coord
    
    # Load in arguments
    lw $t0, DISPLAY_WIDTH
    lw $t1, DISPLAY_HEIGHT
    lw $t2, BOARD_WIDTH
    lw $t3, BOARD_HEIGHT
    lw $t4, UNIT_WIDTH
    lw $t5, UNIT_HEIGHT
    
    # Use $t4 and $t5 for intermediate temp values in the calculations
    # calculate "new" display width and display height, divide them by unit width and unit hieght
    div $t0, $t4 # divide display width by unit width
    mflo $t0 # got "new" display width
    div $t1, $t5 # divide display height by unit height
    mflo $t1 # got "new" display height
    
    # calculate (display_width - board_width)
    sub $t4, $t0, $t2
    # calculate (display_height - board_height)
    sub $t5, $t1, $t3
    
    # store 2 in a register
    li $t6, 2
    # calculate (display_width - board_width) // 2
    div $t4, $t6
    mflo $v0 # store x_coord in return register
    
    # calculate (display_height - board_height) // 2
    div $t5, $t6
    mflo $v1 # store y_coord in return register
    
    jr $ra # return

# Function that takes in x, y coords and returns offset ADDRESS for display (origin at lower left corner)
# def calc_offset_display(x_coordinate, y_coordinate):
    # global DISPLAY_WIDTH, DISPLAY_HEIGHT, UNIT_WIDTH, UNIT_HEIGHT
    # DISPLAY_WIDTH = DISPLAY_WIDTH // UNIT_WIDTH
    # DISPLAY_HEIGHT = DISPLAY_HEIGHT // UNIT_HEIGHT
    
    # vertical_offset = y_coordinate * DISPLAY_WIDTH * 4  
    # horizontal_offset = x_coordinate * 4
    # return vertical_offset + horizontal_offset
calc_offset_display:
    # ARGUMENTS (not passed in, loaded from constants):
    # - $t0 DISPLAY_WIDTH
    # - $t1 DISPLAY_HEIGHT
    # - $t2 UNIT_WIDTH
    # - $t3 UNIT_HEIGHT
    
    # ACTUAL ARGUMENTS
    # - $a0 x_coordinate
    # - $a1 y_coordinate
    
    # RETURNS:
    # - $v0 calculated offset for writing to display
    
    # Load in arguments
    lw $t0, DISPLAY_WIDTH
    lw $t1, DISPLAY_HEIGHT
    lw $t2, UNIT_WIDTH
    lw $t3, UNIT_HEIGHT
    
    # calculate "new" display width and display height, divide them by unit width and unit hieght
    div $t0, $t2 # divide display width by unit width
    mflo $t0 # got "new" display width
    div $t1, $t3 # divide display height by unit height
    mflo $t1 # got "new" display height

    # use t4 and t5 to store offsets, store constant 4 in $t6 which represents the byte size
    li $t6, 4
    # calculate vertical offset and store it in t4
    mul $t4, $a1, $t0  # multiply y coord with new display width
    mul $t4, $t4, $t6  # multiply by 4
    
    # calculate horizontal offset and store in t5
    mult $t5, $a0, $t6  # multiply x coord by 4
    
    # add vertical and horizontal offset together
    add $v0, $t4, $t5
    
    # add base display address to $v0
    lw $t0, ADDR_DSPL
    add $v0, $v0, $t0
    
    jr $ra
    
# Function that takes in x, y coords for WITHIN the white border (inside the game field) and returns offset ADDRESS for display (origin at lower left corner)
# def calc_offset_board(x_coordinate, y_coordinate): # coordinate for WITHIN the game board
    # global BOARD_WIDTH, BOARD_HEIGHT
    # if x_coordinate >= BOARD_WIDTH: error return -1 
    # if y_coordinate >= BOARD_HEIGHT: error return -1
    
    # x_board_offset, y_board_offset = center_board()
    # new_x = x_coordinate + x_board_offset
    # new_y = y_coordinate + y_board_offset

    # offset_board = calc_offset_display(new_x, new_y)
    # return offset_board
calc_offset_board:
    # ARGUMENTS (not passed in, loaded from constants):
    # - $t0 BOARD_WIDTH
    # - $t1 BOARD_HEIGHT
    
    # ACTUAL ARGUMENTS
    # - $a0 x_coordinate in board
    # - $a1 y_coordinate in board
    
    # RETURNS:
    # - $v0 calculated offset for writing to display
    
    # push return address onto stack
    addi $sp, $sp, -4 # make space in stack
    sw $ra, 0($sp) # store return on stack
    
    
    lw $t0, BOARD_WIDTH # load in global variables
    lw $t1, BOARD_HEIGHT
    
    # if x_coordinate >= BOARD_WIDTH: error return -1 
    bge $a0, $t0, calc_offset_board_ERROR
    # if y_coordinate >= BOARD_HEIGHT: error return -1 
    bge $a1, $t1, calc_offset_board_ERROR
    
    # call center_board to find top left corner of board
    jal center_board    
    # RETURNS:
    # - $v0 x_coord
    # - $v1 y_coord
    
    # find new x_coord relative to display instead of board
    add $a0, $a0, $v0 # take x coord in board and add to top left corner of board in display coords
    add $a1, $a1, $v1 # do the same for y
    
    # ARGUMENTS for calc_offset_display
    # - $a0 x_coordinate
    # - $a1 y_coordinate
    jal calc_offset_display  # returns offset for writing to display in $v0
    
    lw $ra, 0($sp) # load last return address to stack
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra # return
# Error function: returns -1 stored at $v0 if the new coordinate is invalid
calc_offset_board_ERROR:
    li $v0, -1
    lw $ra, 0($sp) # load last return address to stack
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra # return

##################################################################################################################################################################################
# Background of game field functions 
##################################################################################################################################################################################

# Function that draws the white border around the game board
draw_border:
    # NO ARGS NO RETURN VALS
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    # TOP HORIZONTAL LINE
    # return x_coord, y_coord -> calculate x_coord + board_width + 1, y_coord + board_height + 1 (bottom right coord)
    jal center_border # returns coordinates of top left corner of border in v0, v1
    move $a0, $v0 # move to a0
    move $a1, $v1 # move to a1
    lw $a2, BOARD_WIDTH # load board width for line length argument to draw_horizontal_line
    add $a2, $a2, 2  # add 2 to board width to account for border being 2 wider and taller than the board
    lw $a3, white # load in the color
    li $s7, 1 # set the line type to solid    
    jal draw_horizontal_line

    # BOTTOM HORIZONTAL LINE
    jal center_border # returns coordinates of top left corner of border in v0, v1
    move $a0, $v0 # move to a0 (x)
    move $a1, $v1 # move to a1 (y)
    lw $t0, BOARD_HEIGHT # load board height to determine bottom horizontal line's y coord
    addi $t0, $t0, 1    # add 1 to board height to accomodate for border being around the board and thus greater
    add $a1, $a1, $t0  # y_coord = (board_height + 1)
    lw $a2, BOARD_WIDTH # load board width for line length argument to draw_horizontal_line
    add $a2, $a2, 2  # add 2 to board width to account for border being 2 wider and taller than the board
    lw $a3, white # load in the color
    li $s7, 1 # set the line type to solid  
    jal draw_horizontal_line
    
    # LEFT VERTICAL LINE    
    jal center_border # returns coordinates of top left corner of border in v0, v1
    move $a0, $v0 # move to a0 (x)
    move $a1, $v1 # move to a1 (y)    
    lw $a2, BOARD_HEIGHT # load board_height for line_length
    add $a2, $a2, 1  # add one to account for border being 2 bigger than the board
    lw $a3, white # load in color
    li $s7, 1 # set line type
    jal draw_vertical_line
    
    # RIGHT VERTICAL LINE
    jal center_border # returns coordinates of top left corner of border in v0, v1
    move $a0, $v0 # move to a0 (x)
    move $a1, $v1 # move to a1 (y) 
    lw $t0, BOARD_WIDTH  # load board_width to calculate new x_coord
    addi $t0, $t0, 1    # add 1 to board height 
    add $a0, $a0, $t0  # x_coord = board_width + 1
    lw $a2, BOARD_HEIGHT # load board_height for line_length
    add $a2, $a2, 1  # add one to account for border being 2 bigger than the board
    lw $a3, white # load in color
    li $s7, 1 # set line type
    jal draw_vertical_line
    
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra

# Function that can draw a solid or dotted line, used to draw checkered board pattern and white border
draw_horizontal_line:    
    # ARGUMENTS:
    # - $a0 starting x_coord
    # - $a1 starting y_coord
    # - $a2 line length
    # - $a3 color
    # - $s7 line_type (didn't want to use temp in case calc_offset_display overrode and didn't want to use s0 in case overriding piece pos)
    
    # RETURNS:
    # - Nothing
    
    # store return address
    move $t8, $ra
    b draw_horizontal_line_loop
draw_horizontal_line_loop:
    jal calc_offset_display # calculate display offset to draw the pixel
    sw $a3 0($v0) # draw the pixel to display
    add $a0, $a0, $s7  # calculate incremented x_coord
    sub $a2, $a2, $s7 # use $a2 to store line length left to draw
    bgt $a2, $zero, draw_horizontal_line_loop # repeat until line is drawn
    jr $t8 # return otherwise
    
# Function that can draw a solid or dotted line, used to draw white border
draw_vertical_line:
    # ARGUMENTS:
    # - $a0 starting x_coord
    # - $a1 starting y_coord
    # - $a2 line length
    # - $a3 color
    # - $s7 line_type
    
    # RETURNS:
    # - Nothing
    
    # store return address
    move $t9, $ra 
    b draw_vertical_line_loop
draw_vertical_line_loop:
    jal calc_offset_display # calculate display offset to draw the pixel
    sw $a3 0($v0) # draw the pixel to display
    add $a1, $a1, $s7  # calculate incremented y coordinate
    sub $a2, $a2, $s7 # use $a2 to store line length left to draw
    bgt $a2, $zero, draw_vertical_line_loop # repeat until line is drawn
    jr $t9 # return otherwise
    
# Function that draws the checkerboard design
draw_checkerboard:
    # NO ARGS NO RETURN VALS    
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    lw $a3, light_grey # MAIN COLOR
    lw $s6, dark_grey # SECONDARY COLOR
    
    jal center_board # returns coordinates of top left corner of board in v0, v1
    move $s4, $v0 # x
    move $s5, $v1 # y
    b draw_checkerboard_helper
    
# Function draws one row of checkered squares, increment y, and loops
draw_checkerboard_helper: # helper function that draws one row
    # ARGUMENTS:
    # - $s4 for x value
    # - $s5 for y value
    # - $s7 used for line type
    
    # Variables:
    # - $t0 used for temp storage of the number 2 and the reading from high
    # - $t1 used for temp storage of board height
    
    # Draw a solid light grey line
    move $a0, $s4 # x
    move $a1, $s5 # y
    lw $a2, BOARD_WIDTH # line_length
    lw $a3, light_grey # color
    li $s7, 1 # line type    
    jal draw_horizontal_line # DRAW solid line
    
    # On top we will draw alternating dark grey squares
    move $a0, $s4 # x
    move $a1, $s5 # y
    li $t0, 2 # temp value to hold 2
    div $a1, $t0  # divide y coord by 2 to get it's modulo which will alternate between 0 or 1
    mfhi $t0 # we will use the remainder to stagger the rows horizontally
    add $a0, $a0, $t0 # add the remainder to create stagger
    lw $a2, BOARD_WIDTH # line_length
    lw $a3, dark_grey # color is already set to a3
    li $s7, 2 # set the line type to dotted    
    jal draw_horizontal_line # DRAW dotted line
    
    addi $s5, $s5, 1  # increment y value
    
    # Determine if we have drawn enough rows to fill the grid
    jal center_border
    lw $t1, BOARD_HEIGHT # load board height
    add $t1, $t1, $v1  # add center_border y value to board height
    addi $t1, $t1, 1  # add 1 to stretch to end of board
    blt $s5, $t1, draw_checkerboard_helper # repeat as long as y < board_height
    
    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra
    
