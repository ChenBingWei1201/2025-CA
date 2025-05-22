.text
.global matrix_chain_multiplication

matrix_chain_multiplication:
    # Prologue - allocate more stack space for DP tables
    addi sp, sp, -128
    sw ra, 124(sp)
    sw s0, 120(sp)
    sw s1, 116(sp)
    sw s2, 112(sp)
    sw s3, 108(sp)
    sw s4, 104(sp)
    sw s5, 100(sp)
    sw s6, 96(sp)
    sw s7, 92(sp)
    sw s8, 88(sp)
    sw s9, 84(sp)
    sw s10, 80(sp)
    sw s11, 76(sp)
    
    # Save function arguments
    mv s0, a0        # matrices
    mv s1, a1        # rows
    mv s2, a2        # cols
    mv s3, a3        # count
    
    # Check edge cases
    blez s3, return_null
    li t0, 1
    beq s3, t0, single_matrix
    
    # For small cases (2-3 matrices), use simple approach
    li t0, 4
    blt s3, t0, simple_multiplication
    
    # For larger cases, implement DP optimization here
    # For now, fall back to simple multiplication
    j simple_multiplication

single_matrix:
    # Handle single matrix case
    lw t0, 0(s1)     # rows[0]
    lw t1, 0(s2)     # cols[0]
    mul t2, t0, t1   # size = rows * cols
    slli t2, t2, 2   # size in bytes
    
    mv a0, t2
    call malloc
    beqz a0, return_null
    mv s4, a0
    
    # Copy matrix
    lw t0, 0(s0)     # source matrix
    mv t1, t0
    mv t2, s4
    lw t3, 0(s1)
    lw t4, 0(s2)
    mul t5, t3, t4
    
copy_single:
    beqz t5, single_done
    lw t6, 0(t1)
    sw t6, 0(t2)
    addi t1, t1, 4
    addi t2, t2, 4
    addi t5, t5, -1
    j copy_single
    
single_done:
    mv a0, s4
    j return

simple_multiplication:
    # Use left-to-right multiplication for simplicity
    # This is not optimal but will work correctly
    
    # Initialize with first matrix
    lw s4, 0(s1)     # current_rows
    lw s5, 0(s2)     # current_cols
    
    # Allocate space for current result
    mul t0, s4, s5
    slli t0, t0, 2
    mv a0, t0
    call malloc
    beqz a0, return_null
    mv s6, a0        # current result
    
    # Copy first matrix
    lw t0, 0(s0)
    mv t1, t0
    mv t2, s6
    mul t3, s4, s5
    
copy_first:
    beqz t3, first_copied
    lw t4, 0(t1)
    sw t4, 0(t2)
    addi t1, t1, 4
    addi t2, t2, 4
    addi t3, t3, -1
    j copy_first
    
first_copied:
    li s7, 1         # matrix index

multiply_next:
    bge s7, s3, multiplication_done
    
    # Get next matrix info
    slli t0, s7, 2
    add t1, s1, t0
    lw s8, 0(t1)     # next_rows
    add t1, s2, t0
    lw s9, 0(t1)     # next_cols
    add t1, s0, t0
    lw s10, 0(t1)    # next_matrix
    
    # Check compatibility
    bne s5, s8, error_exit
    
    # Allocate new result
    mul t0, s4, s9
    slli t0, t0, 2
    mv a0, t0
    call malloc
    beqz a0, error_exit
    mv s11, a0       # new result
    
    # Perform matrix multiplication
    li t0, 0         # row
    
mult_row_loop:
    bge t0, s4, mult_row_done
    li t1, 0         # col
    
mult_col_loop:
    bge t1, s9, mult_col_done
    li t2, 0         # sum
    li t3, 0         # k
    
mult_k_loop:
    bge t3, s5, mult_k_done
    
    # Get current[row][k]
    mul t4, t0, s5
    add t4, t4, t3
    slli t4, t4, 2
    add t4, s6, t4
    lw t4, 0(t4)
    
    # Get next[k][col]
    mul t5, t3, s9
    add t5, t5, t1
    slli t5, t5, 2
    add t5, s10, t5
    lw t5, 0(t5)
    
    # Multiply and add
    mul t4, t4, t5
    add t2, t2, t4
    
    addi t3, t3, 1
    j mult_k_loop
    
mult_k_done:
    # Store result
    mul t4, t0, s9
    add t4, t4, t1
    slli t4, t4, 2
    add t4, s11, t4
    sw t2, 0(t4)
    
    addi t1, t1, 1
    j mult_col_loop
    
mult_col_done:
    addi t0, t0, 1
    j mult_row_loop
    
mult_row_done:
    # Free old result and update
    mv a0, s6
    call free
    mv s6, s11
    mv s5, s9
    
    addi s7, s7, 1
    j multiply_next
    
multiplication_done:
    mv a0, s6
    j return
    
error_exit:
    beqz s6, return_null
    mv a0, s6
    call free
    
return_null:
    li a0, 0
    
return:
    # Epilogue
    lw s11, 76(sp)
    lw s10, 80(sp)
    lw s9, 84(sp)
    lw s8, 88(sp)
    lw s7, 92(sp)
    lw s6, 96(sp)
    lw s5, 100(sp)
    lw s4, 104(sp)
    lw s3, 108(sp)
    lw s2, 112(sp)
    lw s1, 116(sp)
    lw s0, 120(sp)
    lw ra, 124(sp)
    addi sp, sp, 128
    
    jr ra
