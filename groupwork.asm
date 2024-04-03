################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Yenah Lee, 1009276310
# Student 2: Ying Chen (Ariel) Liu, 1008877832
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    96
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
	.data    
##############################################################################
# Immutable Data
##############################################################################
	# Colors
	light_grey: 	.word 0x00E0E0E0	# Light grey color
	dark_grey: 	.word 0x00C0C0C0	# Dark grey color
	black: 		.word 0x00000000	# Black color
    white:      .word 0x00FFFFFF
    pause_grey: .word 0x00adadad
    
	# Constants
	dspl_wdth_unit:	.word 12       		# Unit display width
	dspl_hght_unit:	.word 32       		# Unit display height
	field_wdth:	.word 10		# Game field width
	field_hght:	.word 31		# Game field height
	tmino_ort_off:	.word 64		# Tetromino orientation offset (64 bytes)
	tmino_blk_wdth:	.word 4			# Tetromino block width
	tmino_blk_hght:	.word 4			# Tetromino block height

	# The address of the bitmap display
	ADDR_DSPL:    	.word 0x10008000
	# The address of the keyboard
	ADDR_KBRD:	.word 0xffff0000
	
	# Game field
	game_field:	.word 0:310		# 930 is 30*31, full size of the game field, initialized to 0
	
	# Tetrominoes
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
		
	PITCH: .word 76, 71, 72, 74
       .word 76, 74, 72, 71
       .word 69, 69, 72, 76
       .word 74, 72, 71, 0
       .word 72, 74, 76, 72
       .word 69, 69, 0, 0
       .word 74, 77, 81, 79
       .word 77, 76, 72, 76
       .word 74, 72, 71, 71
       .word 72, 74, 76, 72
       .word 69, 69, 0, 76
       .word 71, 72, 74, 76
       .word 74, 72, 71, 69
       .word 69, 72, 76, 74
       .word 72, 71, 0, 72
       .word 74, 76, 72, 69
       .word 69, 0, 0, 74
       .word 77, 81, 79, 77
       .word 76, 72, 76, 74
       .word 72, 71, 71, 72
       .word 74, 76, 72, 69
       .word 69, 0, 64, 60
       .word 62, 59, 60, 57
       .word 56, 0, 64, 60
       .word 62, 59, 60, 64
       .word 69, 69, 68, 0

DURATION: .word 404, 202, 202, 202
          .word 101, 101, 202, 202
          .word 404, 202, 202, 404
          .word 202, 202, 404, 202
          .word 202, 404, 404, 404
          .word 404, 404, 404, 202
          .word 404, 202, 404, 202
          .word 202, 606, 202, 404
          .word 202, 202, 404, 202
          .word 202, 404, 404, 404
          .word 404, 404, 404, 404
          .word 202, 202, 202, 101
          .word 101, 202, 202, 404
          .word 202, 202, 404, 202
          .word 202, 404, 202, 202
          .word 404, 404, 404, 404
          .word 404, 404, 202, 404
          .word 202, 404, 202, 202
          .word 606, 202, 404, 202
          .word 202, 404, 202, 202
          .word 404, 404, 404, 404
          .word 404, 404, 808, 808
          .word 808, 808, 808, 808
          .word 1212, 404, 808, 808
          .word 808, 808, 404, 404
          .word 404, 404, 808, 808

VOLUME: .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 0
        .word 100, 100, 100, 100
        .word 100, 100, 0, 0
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 0, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 0, 100
        .word 100, 100, 100, 100
        .word 100, 0, 0, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 100
        .word 100, 0, 100, 100
        .word 100, 100, 100, 100
        .word 100, 0, 100, 100
        .word 100, 100, 100, 100
        .word 100, 100, 100, 0

    
    music_counter: .word 0
    
    gravity_count: .word 0
    gravity_time: .word 0x0FFFFF
    decrease_gravity_time_count: .word 0
    
    GG: .word 0x00000000, 0x00000000, 0x00FFFFFF, 0x00FFFFFF
        .word 0x00FFFFFF, 0x00000000, 0x00000000, 0x00FFFFFF
        .word 0x00FFFFFF, 0x00FFFFFF, 0x00000000, 0x00000000
        .word 0x00000000, 0x00FFFFFF, 0x00000000, 0x00000000
        .word 0x00000000, 0x00000000, 0x00FFFFFF, 0x00000000
        .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
        .word 0x00000000, 0x00FFFFFF, 0x00000000, 0x00000000
        .word 0x00000000, 0x00000000, 0x00FFFFFF, 0x00000000
        .word 0x00000000, 0x00000000, 0x00000000, 0x00000000
        .word 0x00000000, 0x00FFFFFF, 0x00000000, 0x00FFFFFF
        .word 0x00FFFFFF, 0x00000000, 0x00FFFFFF, 0x00000000
        .word 0x00FFFFFF, 0x00FFFFFF, 0x00000000, 0x00000000
        .word 0x00000000, 0x00FFFFFF, 0x00000000, 0x00000000 
        .word 0x00FFFFFF, 0x00000000, 0x00FFFFFF, 0x00000000 
        .word 0x00000000, 0x00FFFFFF, 0x00000000, 0x00000000
        .word 0x00000000, 0x00000000, 0x00FFFFFF, 0x00FFFFFF 
        .word 0x00000000, 0x00000000, 0x00000000, 0x00FFFFFF 
        .word 0x00FFFFFF, 0x00000000, 0x00000000, 0x00000000
    
##############################################################################
# Mutable Data
##############################################################################

# Hard features: full set of tetris pieces
# Easy features:
# 1: gravity
# 2: increase speed of gravity
# 3: tetris pieces have different colors
# 4: space bar drops the piece all the way down
# 5: pause screen
# 6: reset and gg screen

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
	# s0 - address
	# s1 - x
	# s2 - y
	# s3 - orientation
	# s4 - game over
main:
	jal draw_walls			# draw the walls
	jal init_field			# initialize the game field	
	jal draw_field			# draw the game field
	
	# Generate a random number between 0 and 6
    li $v0, 42 # command for random number generation
    li $a0, 0  # random number generator ID
    li $a1, 7  # maximum value is exclusive
    syscall # stores return value in $a0
    
    move $t1, $a0  # move to where we are storing the piece type
    jal return_tetris_piece_data_address
	move $s0, $v0		# load tetromino T address
	
	lw $s1, field_wdth		# load field width
	srl $s1, $s1, 1			# divide by 2 to get the initial x coordinate of tetromino
	addi $s1, $s1, -2		# subtract 1 to center it
	li $s2, 0			# load 0 as initial y coordinate of tetromino
	li $s3, 0			# load 0 as initial orientation of tetromino
	li $s4, 0			# set game over flag to 0
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal draw_tmino			# draw the current tetromino
	
game_loop:
	# 1a. Check if key has been pressed
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # load first word from keyboard
	beq $t8, 1, keyboard_input      # if first word 1, key is pressed
    	
	# Gravity_count: counts up from 0 to gravity_time, when it hits gravity_time -> drop block by 1 y coord
	# Gravity_time: upper limit for gravity_count
	# decrease_gravity_time_count: counts up from 0 to 10, when it hits 10 -> decrease gravity_time by 1
	lw $t1, gravity_count # read gravity count
    addi $t1, $t1, 1  # add one to count down till gravity is applied
    sw $t1, gravity_count # save change
    
    lw $t2, gravity_time  # upper limit for time
    bgt $t1, $t2, gravity  # if count has reached gravity_time then move piece down
	b game_sleep			# else, jump to sleep    	
	# 1b. Check which key has been pressed
gravity:
    sw $zero, gravity_count # reset count
    
    lw $t3, decrease_gravity_time_count # read gravity count
    addi $t3, $t3, 1  # add one to count down till gravity is applied
    sw $t3, decrease_gravity_time_count # save change
    
    li $t2, 1
    bgt $t3, $t2, increase_gravity  # time to decrease gravity_time
    
    jal move_down  # move block down
    
    b game_sleep
increase_gravity:
    lw $t1, gravity_time # read gravity ratio
    addi $t1, $t1, -0x00000F # -0x0000FF  # subtract one to decrease time till block falls
    sw $t1, gravity_time # save change    
    
    jal move_down  # move block down

keyboard_input:
	lw $a0, 4($t0)                  # load second word from keyboard
	
	li $v0, 1 # print piece
	syscall
	
	beq $a0, 0x71, quit     	# if the key q was pressed, jump to quit
	beq $a0, 0x61, move_left	# if the key a was pressed, jump to move tetromino left
	beq $a0, 0x64, move_right	# if the key d was pressed, jump to move tetromino right
	beq $a0, 0x73, move_down	# if the key s was pressed, jump to move tetromino down
	beq $a0, 0x77, rotate		# if the key w was pressed, jump to rotate tetromino
	beq $a0, 0x20, drop		# if the key w was pressed, jump to rotate tetromino
	beq $a0, 0x70, pause
	b game_sleep			# else, jump to sleep
move_left:
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	addi $a2, $s1, -1		# $a2 = tetromino block x coordinate - 1
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal check_collision		# check for possible collision on the left side
	bnez $v0, draw_screen		# if collision happened, jump to draw screen
	addi $s1, $s1, -1		# decrement the x coordinate to move left
	b draw_screen			# jump to draw screen
move_right:
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	addi $a2, $s1, 1		# $a2 = tetromino block x coordinate + 1
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal check_collision		# check for possible collision on the right side
	bnez $v0, draw_screen		# if collision happened, jump to draw screen
	addi $s1, $s1, 1		# increment the x coordinate to move right
	b draw_screen			# jump to draw screen
pause:
    # li $v0, 33    # async play note syscall
    # li $a0, 78    # midi pitch
    # li $a1, 1  # duration
    # li $a2, 90     # instrument
    # li $a3, 100   # volume
    # syscall
    jal draw_paused_screen
pause2:
    # play tetris theme
    li $t0, 4
	lw $t1, music_counter
	mult $t1, $t1, $t0 # calc offset
	la $t2, PITCH
	la $t3, DURATION
	la $t4, VOLUME
	add $t2, $t2, $t1 # add offset to notes and rests address
	add $t3, $t3, $t1 
	add $t4, $t4, $t1 
	li $v0, 33
    lw $a0, 0($t2)
    lw $a1, 0($t3)
    li $a2, 0
    lw $a3, 0($t4)
    syscall # music note
    
    # increment music counter
    lw $t1, music_counter
    add $t1, $t1, 1
    li $t0, 104  # mod by note count
    div $t1, $t0
    mfhi $t1
    sw $t1, music_counter
    
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # load first word from keyboard
	beq $t8, 1, paused_key_pressed      # if first word 1, key is pressed
	b pause2
paused_key_pressed:
    lw $a0, 4($t0)                  # load second word from keyboard
    beq $a0, 0x70, unpause  # if it's p then unpase
    b pause2 # otherwise loop back to pause
unpause:
    sw $zero, music_counter  # reset counter
    li $v0, 33    # async play note syscall
    li $a0, 78    # midi pitch
    li $a1, 1  # duration
    li $a2, 103     # instrument
    li $a3, 100   # volume
    syscall
    b draw_screen
drop:
    li $v0, 33    # async play note syscall
    li $a0, 78    # midi pitch
    li $a1, 1  # duration
    li $a2, 127     # instrument
    li $a3, 50   # volume
    syscall
    move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	addi $a3, $s2, 1		# $a3 = tetromino block y coordinate + 1
	jal check_collision		# check if tetromino will land
	beqz $v0, drop_by_one
	# there is a collision
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal store_tmino			# otherwise, store the current tetromino
	jal remove_lines		# remove the filled lines of blocks
	b generate_tmino		# and jump to generate a new one
drop_by_one:
    addi $s2, $s2, 1	# increment y
    b drop  # loop back to drop further
	
move_down:    
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	addi $a3, $s2, 1		# $a3 = tetromino block y coordinate + 1
	jal check_collision		# check if tetromino will land
	beqz $v0, cont_mdown		# if no, proceed with moving down
	
	# collision
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal store_tmino			# otherwise, store the current tetromino
	jal remove_lines		# remove the filled lines of blocks
	b generate_tmino		# and jump to generate a new one
cont_mdown:
	addi $s2, $s2, 1		# else, increment the y coordinate to move down
	b draw_screen			# jump to draw screen
rotate:
    li $v0, 33    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 1  # duration
    li $a2, 90     # instrument
    li $a3, 100   # volume
    syscall
	move $a0, $s0			# $a0 = tetromino memory address
	addi $a1, $s3, 1		# $a1 = tetromino orientation + 1
	move $a2, $s1			# $a2 = tetromino block x coordinate
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal check_collision		# check for possible collision
	bnez $v0, draw_screen		# if collision happened, jump to draw screen
	addi $s3, $s3, 1		# otherwise, increment the orientation to rotate
	andi $s3, $s3, 0x03		# take the modulo 4 value, as orientation 4 is equivalent to 0
	b draw_screen			# jump to draw screen
generate_tmino:
	# la $s0, tmino_T0		# load tetromino T address
	# Generate a random number between 0 and 6
    li $v0, 42 # command for random number generation
    li $a0, 0  # random number generator ID
    li $a1, 7  # maximum value is exclusive
    syscall # stores return value in $a0
    
    move $t1, $a0  # move to where we are storing the piece type
    jal return_tetris_piece_data_address
    move $s0, $v0 # move to store in s0
	
	lw $s1, field_wdth		# load field width
	srl $s1, $s1, 1			# divide by 2 to get the initial x coordinate of tetromino
	addi $s1, $s1, -2		# add 2 to center it
	li $s2, -1			# load 0 as initial y coordinate of tetromino
	li $s3, 0			# load 0 as initial orientation of tetromino
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal check_collision		# check for possible collision
	beqz $v0, draw_screen		# if there is no collision, continue
	li $s4, 1			# else, set the game over flag
	b quit
	# 3. Draw the screen
draw_screen:
	jal draw_field			# draw the field
	move $a0, $s0			# $a0 = tetromino memory address
	move $a1, $s3			# $a1 = tetromino orientation
	move $a2, $s1			# $a2 = tetromino block x coordinate
	move $a3, $s2			# $a3 = tetromino block y coordinate
	jal draw_tmino			# draw the current tetromino
	bnez $s4, quit			# if the game is over, exit the loop
	# 4. Sleep
game_sleep:
    # 4. Sleep
    li $v0, 32
    li $a0, 10000  # sleep for 100 milliseconds
    # 5. Go back to 1
	b game_loop			# repeat all over again
quit:
    li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 1000  # duration
    li $a2, 90     # instrument
    li $a3, 127   # volume
    syscall
    
    jal draw_quit_screen_top
    jal draw_quit_screen_middle
    jal draw_quit_screen_bottom
    
    b quit_wait
    
quit_wait:
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # load first word from keyboard
	beq $t8, 1, quit_key_pressed      # if first word 1, key is pressed
	b quit_wait
quit_key_pressed:
    lw $a0, 4($t0)                  # load second word from keyboard
    beq $a0, 0x71, quit_program  # if it's q then fully quit
    beq $a0, 0x72, restart  # if it's r then restart
    b quit_wait # otherwise loop back to waiting
restart:
    b main
    
quit_program:
	li $v0, 10              	# terminate the program gracefully
	syscall
	
draw_quit_screen_top:
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    lw $t0, ADDR_DSPL	# load display base address
    lw $t1, dspl_wdth_unit	# load game field width
	li $t2, 13  	# load game field height
	li $t3, 0		# initialize height counter
draw_quit_black_top:
    li $t4, 0		# initialize width counter
draw_quit_rowblack_top:
    sw $zero, 0($t0)
quit_continue_loop_top:
	add $t0, $t0, 4		# increment the display pointer
	add $t4, $t4, 1		# increment the width counter
	bne $t4, $t1, draw_quit_rowblack_top	# loop until it reaches the width value
	# add $t0, $t0, 4		# increment the display pointer to skip the right wall
	add $t3, $t3, 1		# increment the height counter
	bne $t3, $t2, draw_quit_black_top	# loop until it reaches the height value

    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra

draw_quit_screen_middle:
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push

    la $t7, GG
    lw $t0, ADDR_DSPL	# load display base address
    lw $t1, dspl_wdth_unit	# load game field width
	li $t2, 6	# load game field height
	li $t3, 0		# initialize height counter
	addi $t0, $t0, 624  # offset starting row
draw_quit_black_middle:
    li $t4, 0		# initialize width counter
draw_quit_rowblack_middle:
    lw $t9, 0($t7) # load pixel from GG
    sw $t9, 0($t0) # color
quit_continue_loop_middle:
	add $t0, $t0, 4		# increment the display pointer
	add $t7, $t7, 4     # increment the GG counter
	add $t4, $t4, 1		# increment the width counter
	bne $t4, $t1, draw_quit_rowblack_middle	# loop until it reaches the width value
	# add $t0, $t0, 4		# increment the display pointer to skip the right wall
	add $t3, $t3, 1		# increment the height counter
	bne $t3, $t2, draw_quit_black_middle	# loop until it reaches the height value

    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra

draw_quit_screen_bottom:
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    lw $t0, ADDR_DSPL	# load display base address
    lw $t1, dspl_wdth_unit	# load game field width
	lw $t2, dspl_hght_unit	# load game field height
	li $t3, 15		# initialize height counter
	addi $t0, $t0, 912  # offset starting row
draw_quit_black_bottom:
    li $t4, 0		# initialize width counter
draw_quit_rowblack_bottom:
    sw $zero, 0($t0)
quit_continue_loop_bottom:
	add $t0, $t0, 4		# increment the display pointer
	add $t4, $t4, 1		# increment the width counter
	bne $t4, $t1, draw_quit_rowblack_bottom	# loop until it reaches the width value
	# add $t0, $t0, 4		# increment the display pointer to skip the right wall
	add $t3, $t3, 1		# increment the height counter
	bne $t3, $t2, draw_quit_black_bottom	# loop until it reaches the height value

    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra



# check collision
# $a0 = tetromino memory address
# $a1 = tetromino orientation (can be 0, 1, 2, 3)
# $a2 = x coordinate
# $a3 = y coordinate
# returns:
# $v0 = 0 if no collision, 1 otherwise
check_collision:
	la $t0, game_field	# load game field base address
	lw $t1, field_wdth	# load game field width
	lw $t2, tmino_ort_off	# load tetromino orientation offset
	mul $t2, $t2, $a1	# multiply the offset by orientation value
	add $a0, $a0, $t2	# calculate the base address of tetromino with corresponding orientation
	lw $t2, field_hght	# load game field height
	move $t3, $a2		# copy x to $t3
	li $v0, 0		# initialize return value to 0 (no collision)
	lw $t4, tmino_blk_hght	# load tetromino block height for counting	
chck_next:
	lw $t5, tmino_blk_wdth	# load tetromino block width for counting
chck_row:
	lw $t6, 0($a0)		# load tetromino pixel
	beqz $t6, cont_chck	# if empty, skip it
	bltz $t3, chck_set	# else, if x < 0, set the return value to 1, collision
	bge $t3, $t1, chck_set	# else, if x >= field width, set the return value to 1, collision
	bge $a3, $t2, chck_set	# else, if y >= field height, set the return value to 1, collision
	b chck_fld		# else, jump to check the field pixel
chck_set:
	li $v0, 1		# set collision to 1 (wall collision happened)
	b chck_end		# and jump to return
chck_fld:
	mul $t8, $t1, $a3	# $t8 = field width * y
	add $t8, $t8, $t3	# $t8 = field width * y + x
	sll $t8, $t8, 2		# multiply by 4 to get the offset in bytes
	add $t8, $t8, $t0	# add the base address of the game field 
	lw $t9, 0($t8)		# load pixel from the game field
	lw $t7, light_grey	# load light grey to compare
	beq $t9, $t7, cont_chck	# if the pixel is light grey, continue, no collison happened
	lw $t7, dark_grey	# load dark grey to compare
	beq $t9, $t7, cont_chck	# if the pixel is dark grey, continue, no collison happened
	li $v0, 1		# otherwise, set collision to 1 (tetromino collision happened)
	b chck_end		# and jump to return
cont_chck:
	addi $a0, $a0, 4	# increment the tetromino block pointer
	addi $t3, $t3, 1	# increment x
	addi $t5, $t5, -1	# decrement the counter
	bnez $t5, chck_row	# loop for every pixel in the row
	addi $a3, $a3, 1	# increment y
	move $t3, $a2		# reset x
	addi $t4, $t4, -1	# decrement the height counter
	bnez $t4, chck_next	# loop for every row
chck_end:
	jr $ra			# return
	
# shifts game field lines down by one
# $a0 = y coordinate of the row to start
shift_lines:
	la $t0, game_field	# load game field base address
	lw $t1, field_wdth	# load game field width
	sll $t2, $t1, 2		# multiply by 4 to get the bytes width
	mul $t3, $t2, $a0	# multiply y by width in bytes to get the offset
	add $t3, $t3, $t0	# add the base address, $t3 now points to the destination line
	sub $t4, $t3, $t2	# subtract one width in bytes to get the pointer to the source line
	lw $t5, light_grey	# load light grey color for comparison
	lw $t6, dark_grey	# load dark grey color for comparison
shft_line:
	beqz $a0, shft_clr	# if destination y is 0, jump to make it empty line
	move $t8, $t1		# initialize width counter
	move $t0, $t3		# copy destination address to $t0
	li $t7, 1		# set exit flag to 1
shft_next:
	lw $t9, 0($t4)		# get a pixel from the source
	# the light and dark grey alternate in different lines
	# so we must ensure that we invert them here while copying the line
	beq $t9, $t5, shft_dark	# if light grey, jump to store dark
	beq $t9, $t6, shft_lght	# if dark grey, jump to store light
	li $t7, 0		# else, set exit flag to 0 (line not empty)
	sw $t9, 0($t0)		# copy the pixel to the destination
	b shft_cont		# and jump to continue
shft_lght:
	sw $t5, 0($t0)		# store light grey to the destination
	b shft_cont		# jump to continue
shft_dark:
	sw $t6, 0($t0)		# store dark grey to the destination
shft_cont:
	addi $t0, $t0, 4	# increment the destination pointer
	addi $t4, $t4, 4	# increment the source pointer
	addi $t8, $t8, -1	# decrement the width counter
	bnez $t8, shft_next	# loop for all the pixels in the line
	sub $t3, $t3, $t2	# decrement the destination address to point to the previous row
	sub $t4, $t3, $t2	# the source register points one row before the destination
	addi $a0, $a0, -1	# decrement the y coordinate (destination)
	beqz $t7, shft_line	# loop while exit flag is 0
	b shft_end		# otherwise, jump to finish
shft_clr:
	li $t8, 0		# initialize width counter to 0
shft_clrn:
	andi $t0, $t8, 1	# check if the width counter is even
	bnez $t0, shft_dgry	# if not, jump to store dark grey color
	sw $t5, 0($t3)		# otherwise, store light grey pixel
	b shft_cntc		# and jump to continue
shft_dgry:
	sw $t6, 0($t3)		# store dark grey pixel
shft_cntc:
	addi $t3, $t3, 4	# increment the destination pointer
	addi $t8, $t8, 1	# increment the width counter
	bne $t8, $t1, shft_clrn	# loop for every pixel in line
shft_end:	
	jr $ra			# return
	
# removes lines in the game field filled with tetromino squares
remove_lines:
	addi $sp, $sp, -36	# make space on stack
	sw $s7, 32($sp)		# store $s7
	sw $s6, 28($sp)		# store $s6
	sw $s5, 24($sp)		# store $s5
	sw $s4, 20($sp)		# store $s4
	sw $s3, 16($sp)		# store $s3
	sw $s2, 12($sp)		# store $s2
	sw $s1, 8($sp)		# store $s1
	sw $s0, 4($sp)		# store $s0
	sw $ra, 0($sp)		# store $ra
	
	la $s0, game_field	# load game field base address
	lw $s1, field_wdth	# load game field width
	sll $s4, $s1, 2		# multiply by 4 to get the bytes width
	lw $s2, field_hght	# load game field height
	addi $s2, $s2, -1	# decrement the height
	mul $t0, $s2, $s1	# multiply by width
	sll $t0, $t0, 2		# multiply by 4 to get the byte offset
	add $s0, $s0, $t0	# now $s0 points to the first pixel in the last row
	lw $s5, light_grey	# load light grey color for comparison
	lw $s6, dark_grey	# load dark grey color for comparison
next_line:
	move $s3, $s1		# initialize width counter
	move $s7, $s0		# copy current row address to $s7
next_pxl:
	lw $t0, 0($s7)		# load next pixel
	beq $t0, $s5, skip_line	# if light grey, skip the line
	beq $t0, $s6, skip_line	# if dark grey, skip the line
	addi $s7, $s7, 4	# increment the game field pointer to the next pixel in line
	addi $s3, $s3, -1	# decrement the width counter
	bnez $s3, next_pxl	# loop for each pixel in the row
	move $a0, $s2		# else, the line is full, copy y counter to $a0
	jal shift_lines		# shift all the lines down
	# all the lines will shift down by one position
	# so we should keep processing the line with the same y value
	b next_line		# jump to continue with the same line
skip_line:
	sub $s0, $s0, $s4	# decrement the game field pointer to point the previous row
	addi $s2, $s2, -1	# decrement the line counter
	bgez $s2, next_line	# loop for each line

	lw $s7, 32($sp)		# restore $s7
	lw $s6, 28($sp)		# restore $s6
	lw $s5, 24($sp)		# restore $s5
	lw $s4, 20($sp)		# restore $s4
	lw $s3, 16($sp)		# restore $s3	
	lw $s2, 12($sp)		# restore $s2	
	lw $s1, 8($sp)		# restore $s1
	lw $s0, 4($sp)		# restore $s0
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 36	# free space on stack
	jr $ra			# return

# stores a tetromino to the game field
# $a0 = tetromino memory address
# $a1 = tetromino orientation (can be 0, 1, 2, 3)
# $a2 = x coordinate
# $a3 = y coordinate
store_tmino:
	la $t0, game_field	# load game field base address
	lw $t1, field_wdth	# load game field width
	lw $t2, tmino_ort_off	# load tetromino orientation offset
	mul $t2, $t2, $a1	# multiply the offset by orientation value
	add $a0, $a0, $t2	# calculate the base address of tetromino with corresponding orientation
	move $t3, $a2		# copy x to $t3
	lw $t4, tmino_blk_hght	# load tetromino block height for counting	
stre_next:
	lw $t5, tmino_blk_wdth	# load tetromino block width for counting
stre_row:
	lw $t6, 0($a0)		# load tetromino pixel
	beqz $t6, cont_stre	# if empty, skip it
	mul $t8, $t1, $a3	# $t8 = field width * y
	add $t8, $t8, $t3	# $t8 = field width * y + x
	sll $t8, $t8, 2		# multiply by 4 to get the offset in bytes
	add $t8, $t8, $t0	# add the base address of the game field 
	sw $t6, 0($t8)		# store pixel to the game field
cont_stre:
	addi $a0, $a0, 4	# increment the tetromino block pointer
	addi $t3, $t3, 1	# increment x
	addi $t5, $t5, -1	# decrement the counter
	bnez $t5, stre_row	# loop for every pixel in the row
	addi $a3, $a3, 1	# increment y
	move $t3, $a2		# reset x
	addi $t4, $t4, -1	# decrement the height counter
	bnez $t4, stre_next	# loop for every row
	jr $ra			# return

# draws a tetromino
# $a0 = tetromino memory address
# $a1 = tetromino orientation (can be 0, 1, 2, 3)
# $a2 = x coordinate
# $a3 = y coordinate
draw_tmino:
	lw $t0, ADDR_DSPL	# load display base address
	lw $t1, dspl_wdth_unit	# load unit display width
	lw $t2, tmino_ort_off	# load tetromino orientation offset
	mul $t2, $t2, $a1	# multiply the offset by orientation value
	add $a0, $a0, $t2	# calculate the base address of tetromino with corresponding orientation
	
	mul $t3, $t1, $a3	# $t3 = y * width
	add $t3, $t3, $a2	# $t3 = y * width + x 
	addi $t3, $t3, 1	# add 1 for wall width
	
	lw $t4, tmino_blk_hght	# load tetromino block height as initial value for height counter
draw_tblk:
	lw $t5, tmino_blk_wdth	# load tetromino block width as initial value for width counter
	sll $t6, $t3, 2		# multiply display offset by 4 to get the offset value in bytes
	add $t6, $t6, $t0	# add the base address to the offset
draw_trow:
	lw $t7, 0($a0)		# load tetromino pixel
	beqz $t7, skip_tpix	# if zero, skip it, do not draw it
	sw $t7, 0($t6)		# otherwise, draw the pixel to the display
skip_tpix:
	add $t6, $t6, 4		# increment the display pointer
	addi $a2, $a2, 1	# increment x coordinate
	addi $a0, $a0, 4	# increment the tetromino block pointer
	addi $t5, $t5, -1	# decrement the width counter
	bnez $t5, draw_trow	# loop for every pixel in the block row
	addi $a3, $a3, 1	# increment y coordinate
	add $t3, $t3, $t1	# add width to the display offset to go to the next row
	addi $t4, $t4, -1	# decrement the height counter
	bnez $t4, draw_tblk	# loop for every block row
	
	jr $ra			# return

# initializes the game field with the light-dark grey chessboard grid
init_field:
	la $t0, game_field	# get the game field address
	lw $t1, light_grey	# load light grey color
	lw $t2, dark_grey	# load dark grey color
	lw $t3, field_wdth	# load field width
	lw $t4, field_hght	# load field height
	li $t5, 0		# initialize height counter
init_grid:
	li $t6, 0		# initialize width counter
init_row:
	andi $t7, $t5, 1	# check if the height counter is even
	andi $t8, $t6, 1	# check if the width counter is even
	xor $t8, $t8, $t7	# perform logical XOR on these two results
	# this will ensure alternating on both width and height, as a chess board
	beqz $t8, init_light	# if 0, initialize it with light grey color
	sw $t2, 0($t0)		# otherwise, initialize it with dark grey
	b cont_init		# and jump to continue
init_light:
	sw $t1, 0($t0)		# draw light grey pixel
cont_init:
	add $t0, $t0, 4		# increment the field pointer
	add $t6, $t6, 1		# increment the width counter
	bne $t6, $t3, init_row	# loop until it reaches the width value
	add $t5, $t5, 1		# increment the height counter
	bne $t5, $t4, init_grid	# loop until it reaches the height value
	
	jr $ra			# return

# draws the game field
draw_field:
	lw $t0, ADDR_DSPL	# load display base address
	la $t9, game_field	# load game field address
	
	lw $t1, field_wdth	# load game field width
	lw $t2, field_hght	# load game field height
	li $t3, 0		# initialize height counter
draw_grid:
	li $t4, 0		# initialize width counter
	add $t0, $t0, 4		# increment the display pointer to skip the left wall
draw_row:
	lw $t5, 0($t9)		# load pixel from the game field
	sw $t5, 0($t0)		# draw it on the display
	add $t9, $t9, 4		# increment the game field pointer
	add $t0, $t0, 4		# increment the display pointer
	add $t4, $t4, 1		# increment the width counter
	bne $t4, $t1, draw_row	# loop until it reaches the width value
	add $t0, $t0, 4		# increment the display pointer to skip the right wall
	add $t3, $t3, 1		# increment the height counter
	bne $t3, $t2, draw_grid	# loop until it reaches the height value

	# jr $ra			# return commented out so that walls are also always drawn

# draws walls
draw_walls:
	lw $t0, ADDR_DSPL	# load display base address
	lw $t1, black		# load black color for wall
	lw $t2, dspl_wdth_unit	# load unit display width
	sll $t2, $t2, 2		# multiply unit display width by 4 to get the offset
	lw $t3, dspl_hght_unit	# load unit display height
draw_w:
	sw $t1, 0($t0)		# draw a pixel of the left wall
	add $t0, $t0, $t2	# add the width offset (go to the next row)
	sw $t1, -4($t0)		# draw a pixel of the right wall
	addi $t3, $t3, -1	# decrement the height counter
	bne $t3, 1, draw_w	# loop until it reaches 1, as the last row is drawn fully
	lw $t3, dspl_wdth_unit	# initialize the counter to unit width
draw_lw:
	sw $t1, 0($t0)		# draw a pixel of the bottom wall
	addi $t0, $t0, 4	# increment the display pointer
	addi $t3, $t3, -1	# decrement the counter
	bnez $t3, draw_lw	# loop for each pixel in the row
	jr $ra			# return


# Function that returns the memory address to start reading tetris data by
return_tetris_piece_data_address:
    # ARGUMENTS:
    # - $t1 piece type
    # RETURNS:
    # - $v0 piece address
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    li $t0, 0
    beq $t1, $t0, return_I_piece_address
    
    li $t0, 1
    beq $t1, $t0, return_O_piece_address
    
    li $t0, 2
    beq $t1, $t0, return_T_piece_address
    
    li $t0, 3
    beq $t1, $t0, return_S_piece_address
    
    li $t0, 4
    beq $t1, $t0, return_Z_piece_address
    
    li $t0, 5
    beq $t1, $t0, return_J_piece_address
    
    li $t0, 6
    beq $t1, $t0, return_L_piece_address 

return_tetris_piece_data_address_exit:
    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra # return to where check_for_key_press was called in game_loop
    
return_I_piece_address:
    la $v0, I0
    j return_tetris_piece_data_address_exit

return_O_piece_address:
    la $v0, O0
    j return_tetris_piece_data_address_exit

return_T_piece_address:
    la $v0, T0
    j return_tetris_piece_data_address_exit

return_S_piece_address:
    la $v0, S0
    j return_tetris_piece_data_address_exit

return_Z_piece_address:
    la $v0, Z0
    j return_tetris_piece_data_address_exit
    
return_J_piece_address:
    la $v0, J0
    j return_tetris_piece_data_address_exit

return_L_piece_address:
    la $v0, L0
    j return_tetris_piece_data_address_exit


# Function that draws screen by decreasing the saturation of the color
draw_paused_screen:
    addi $sp, $sp, -4 # allocate space
    sw $ra, 0($sp) # push
    
    lw $t0, ADDR_DSPL	# load display base address
    lw $t1, dspl_wdth_unit	# load game field width
	lw $t2, dspl_hght_unit	# load game field height
	li $t3, 0		# initialize height counter
draw_paused:
    li $t4, 0		# initialize width counter
draw_paused_row:
    lw $t5, 0($t0)		# load pixel from the display
    lw $t6, light_grey
    beq $t5, $t6, draw_paused_skip_pixel
    lw $t6, dark_grey
    beq $t5, $t6, draw_paused_skip_pixel
    b draw_paused_pixel
    
draw_paused_skip_pixel:
    b continue_loop
draw_paused_pixel:
    lw $t5, pause_grey
    sw $t5, 0($t0)		# draw it on the display
    b continue_loop
    
continue_loop:
	add $t0, $t0, 4		# increment the display pointer
	add $t4, $t4, 1		# increment the width counter
	bne $t4, $t1, draw_paused_row	# loop until it reaches the width value
	# add $t0, $t0, 4		# increment the display pointer to skip the right wall
	add $t3, $t3, 1		# increment the height counter
	bne $t3, $t2, draw_paused	# loop until it reaches the height value

    # Return logic
    lw $ra, 0($sp) # pop value
    addi $sp, $sp, 4 # deallocate space on stack
    jr $ra
