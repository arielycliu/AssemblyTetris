######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
# coordinate system has top left corner as origin -> goes from 0 to 31 assuming default bitmap configuration
##############################################################################

# GENERAL RULES OF THUMB
# stack used for return pointers 
# function arguments in a0-a3
# return values in v0-v1
# read values from constants in functions to avoid errors from other programs overriding values (read into t0-t9)
# t9 sometimes used to store return address popped from stack

######################## Memory Model Configuration ########################
# - Display address:            $t0 (reload when using)
# - Keyboard address:           $t1 (reload when using)
# - Current piece orientation:  $s0
# - Current piece x:            $s1
# - Current piece y:            $s2
# - Return address:             $t9 (where it's stored after popping from stack)
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
    
    cyan:          .word 0x0000FFFF  # I
    yellow:        .word 0x00FFFF00  # O
    purple:        .word 0x00800080  # T
    green:         .word 0x0000FF00  # S
    red:           .word 0x00FF0000  # Z
    blue:          .word 0x000000FF  # J
    orange:        .word 0x00FF7F00  # L
    white: 	       .word 0x00FFFFFF  # border color
    light_grey:    .word 0x00E0E0E0	 # checkered grid light color
	dark_grey:     .word 0x007F7F7F  # checkered grid dark color
	board_state:   .word 0:200       # used to store current pieces on the board (BOARD_WIDTH * BOARD_HEIGHT = 200)
	                                 # each coordinate will store 0 if no piece is there or the name of the piece I, O, T, S, Z, J, L if it's the top left corner of the piece
	                                 # initialized to value of 0
    
##############################################################################
# Code
##############################################################################
	.text
	.globl main

main:



game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop

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
    


# Function that takes in x, y coords for WITHIN the white border (inside the game field) and returns offset for display

draw_border:
    