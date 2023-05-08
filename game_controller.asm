.data
    can_move_arr: .word 1, 1, 1, 1
.text
    .globl select_
    select_:
        # $a0 = team address
        # $a1 = cells address
        # $a2 = pieces address

        subi $sp, $sp, 16 # allocate space for $ra, a0, a1 a2
        sw $ra, 12($sp) # save $ra
        sw $a0, 8($sp) # save $a0
        sw $a1, 4($sp) # save $a1
        sw $a2, 0($sp) # save $a2

        # $a0 = team address
        
        jal filter_team_number # $a0 = team address
        move $s0, $v0 # $s0 = team number
        jal filter_selected # $a0 = team address
        move $s1, $v0 # $s1 = selected number
        la $s2, can_move_arr
        sll $t0, $s1, 2
        add $s3, $s2, $t0 # $s3 = can move address

        # check if there is at least one piece that can move
        li $t1, 0
        move $t3, $s3
        loop_check_can_move:
            beq $t1, 4, cannot_move_select
            lw $t2, 0($t3)
            beq $t2, 1, select_loop
            addi $t1, $t1, 1
            addi $t3, $t3, 4
            j loop_check_can_move
        
        cannot_move_select:
            li $v0, 0
            jr $ra

        select_loop:
            li  $v0, 12 # syscall code for read character
            syscall

            # if the character is 'Enter', try to select the piece
            beq $v0, 10, select_piece

            # if the character is 'A', Select the previous piece
            beq $v0, 97, select_previous

            # if the character is 's', Select the next piece
            #beq $v0, 115, select_next

            j select_loop

            select_piece:
                # $s0 = team number
                # $s1 = selected number

                lw $ra, 12($sp) # restore $ra

                jr $ra
            
            select_previous:
                beqz $s1, reset_selected_max
                addi $s1, $s1, -1

                # check if the piece can move
                sll $t0, $s1, 2
                add $s3, $s2, $t0 # $s3 = can move address
                lw $t1, 0($s3) # $t1 = can move
                beq $t1, 0, select_previous

                move $a0,   $s0 # $a0 = team numbr
                move $a1,   $s1 # $a1 = selected number
                lw $a2, 4($sp) # $a2 = cells address
                lw $a3, 0($sp) # $a3 = pieces address

                jal select_cell

                j select_loop

                reset_selected_max:
                    li $s1, 3

                    # move $a0,   $s0 # $a0 = team numbr    
                    # move $a1,   $s1 # $a1 = selected number
                    # lw $a2, 4($sp) # $a2 = cells address
                    # lw $a3, 0($sp) # $a3 = pieces address

                    # $a0 = team address in memory
		            # $a1 = selected value
                    lw $a0, 8($sp) # $a0 = team address

                    # check if the piece can move
                    sll $t0, $s1, 2
                    add $s3, $s2, $t0 # $s3 = can move address
                    lw $t1, 0($s3) # $t1 = can move
                    beq $t1, 0, select_previous

                    move $a1, $s1 # $a1 = selected number
                    jal set_selected

                    move $a0,   $s0 # $a0 = team numbr
                    move $a1,   $s1 # $a1 = selected number
                    lw $a2, 4($sp) # $a2 = cells address
                    lw $a3, 0($sp) # $a3 = pieces address

                    jal select_cell

                    j select_loop

            select_next:
                beq $s1, 3, reset_selected_min
                addi $s1, $s1, 1


                # check if the piece can move
                sll $t0, $s1, 2
                add $s3, $s2, $t0 # $s3 = can move address
                lw $t1, 0($s3) # $t1 = can move
                beq $t1, 0, select_next

                move $a0,   $s0 # $a0 = team numbr
                move $a1, $s1 # $a1 = selected number
                jal set_selected

                move $a0,   $s0 # $a0 = team numbr
                move $a1,   $s1 # $a1 = selected number
                lw $a2, 4($sp) # $a2 = cells address
                lw $a3, 0($sp) # $a3 = pieces address

                jal select_cell

                j select_loop

                reset_selected_min:
                    li $s1, 0

                    # check if the piece can move
                    sll $t0, $s1, 2
                    add $s3, $s2, $t0 # $s3 = can move address
                    lw $t1, 0($s3) # $t1 = can move
                    beq $t1, 0, select_next

                    move $a1, $s1 # $a1 = selected number
                    jal set_selected

                    move $a0,   $s0 # $a0 = team numbr
                    move $a1,   $s1 # $a1 = selected number
                    lw $a2, 4($sp) # $a2 = cells address
                    lw $a3, 0($sp) # $a3 = pieces address

                    jal select_cell

                    j select_loop

    select_cell:        
        # $a0 = team number
        # $a1 = selected number
        # $a2 = cells address
        # $a3 = pieces address

        subi $sp, $sp, 8 # allocate space for $ra and $s0
        sw $ra, 4($sp) # save $ra
        sw $s0, 0($sp) # save $s0

        # Get position of the selected piece in cells
        sll $t0, $a0, 6
        add $t1, $a3, $t0 # $t1 = first piece of the team
        sll $t2, $a1, 2 # $t2 = selected number * 4
        add $a0, $t1, $t2 # $a0 = selected piece

        jal filter_piece_pos

        move $t0, $v0 # $t0 = piece position in cells array
        sll $t0, $t0, 2 # $t0 = piece position * 4
        add $a0, $a2, $t0 # $a0 = selected cell

        jal filter_cell_pos

        move $a1, $v0 # $a1 = cell position

        jal selected

        lw $ra, 4($sp) # restore $ra
        lw $s0, 0($sp) # restore $s0
        addi $sp, $sp, 8 # deallocate space for $ra and $s0

        jr $ra
        # $a0 = team number
        # $a1 = selected number
        # $a2 = cells address
        # $a3 = pieces address

        subi $sp, $sp, 8 # allocate space for $ra and $s0
        sw $ra, 4($sp) # save $ra
        sw $s0, 0($sp) # save $s0

        # Get cell position
        sll $t0, $a0, 6
        add $s0, $a3, $t0 # $s0 = first piece of the team
        sll $t1, $a1, 2 # $t0 = selected number * 4
        # filter piece position in the cells array
        jal filter_piece_pos
        move $s1, $v0 # $s1 = piece position
        sll $t0, $s1, 2 # $t0 = piece position * 4
        add $a0, $a2, $t0  # $a0 = cell address
        # filter cell position
        jal filter_cell_pos
        
        move $a1, $v0 # $s2 = cell position

        jal selected

        lw $ra, 4($sp) # restore $ra
        lw $s0, 0($sp) # restore $s0
        addi $sp, $sp, 8 # deallocate space for $ra and $s0

        jr $ra


    .globl check_if_can_move
    check_if_can_move:
        # $a0 = piece address
        # $a1 = number of the die's face
        # $a2 = cells address

        lw $t0, 0($a0) # $t0 = piece number

        jal filter_piece_status
        move $t1, $v0 # $t1 = piece status

        beq $t1, 0, check_if_can_move_reserve
        beq $t1, 1, check_if_can_move_in_play
        beq $t1, 2, cannot_move

        # In reserve: Take the piece out of reserve when the die's face is 6 or 1
        check_if_can_move_reserve:
        beq $a1, 6, can_move
        beq $a1, 1, can_move
        j cannot_move

        # In play: Check if the piece can move
        check_if_can_move_in_play:
        #  - Walk from current position to the next position and check if there is no barrier
        jal walk_cells
        beq $v0, 0, cannot_move
        j can_move

        cannot_move:
            li $v0, 0
            jr $ra
        
        can_move:
            li $v0, 1
            jr $ra


    .globl move_piece
    move_piece:
        
    .globl check_all
    check_all:
        # $a0 = first piece address
        # $a1 = number of the die's face
        # $a2 = cells address

        la	$s0,    can_move_arr
        li $s1,    0    # $s1 = can move counter

        loop_check:
            beq $s0, 4, end_check

            # $a0 = piece address
            # $a1 = number of the die's face
            # $a2 = cells address
            jal check_if_can_move
            sw $v0, 0($s0)

            addi $s0, $s0, 4
            addi $s1, $s1, 1

            j loop_check

        end_check:
            li $v0, 0
            jr $ra