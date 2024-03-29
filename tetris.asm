######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
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
