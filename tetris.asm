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



# Function that takes in x, y coords for WITHIN the white border (inside the game field) and returns offset for display

draw_border:
    