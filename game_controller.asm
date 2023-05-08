.data
    can_move_arr: .word 1, 1, 1, 1
.text
    .globl select_
    select_:
        subi $sp, $sp, 8 # allocate space for $ra and $s0
        sw $ra, 4($sp) # save $ra
        sw $s0, 0($sp) # save $s0

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
            beq $v0, 115, select_next

            j select_loop

            select_piece:
                # $s0 = team number
                # $s1 = selected number

                lw $ra, 4($sp) # restore $ra
                lw $s0, 0($sp) # restore $s0

                jr $ra
            
            select_previous:
                beqz $s1, reset_selected_max
                addi $s1, $s1, -1

                move $a1, $s1 # $a1 = selected number
                jal set_selected

                # check if the piece can move
                sll $t0, $s1, 2
                add $s3, $s2, $t0 # $s3 = can move address
                lw $t1, 0($s3) # $t1 = can move
                beq $t1, 0, select_previous

                j select_loop

                reset_selected_max:
                    li $s1, 3

                    move $a1, $s1 # $a1 = selected number
                    jal set_selected

                    # check if the piece can move
                    sll $t0, $s1, 2
                    add $s3, $s2, $t0 # $s3 = can move address
                    lw $t1, 0($s3) # $t1 = can move
                    beq $t1, 0, select_previous

                    j select_loop

            select_next:
                beq $s1, 3, reset_selected_min
                addi $s1, $s1, 1

                move $a1, $s1 # $a1 = selected number
                jal set_selected

                # check if the piece can move
                sll $t0, $s1, 2
                add $s3, $s2, $t0 # $s3 = can move address
                lw $t1, 0($s3) # $t1 = can move
                beq $t1, 0, select_next

                j select_loop

                reset_selected_min:
                    li $s1, 0

                    move $a1, $s1 # $a1 = selected number
                    jal set_selected

                    # check if the piece can move
                    sll $t0, $s1, 2
                    add $s3, $s2, $t0 # $s3 = can move address
                    lw $t1, 0($s3) # $t1 = can move
                    beq $t1, 0, select_next

                    j select_loop

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