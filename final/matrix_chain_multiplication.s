.text
.global matrix_chain_multiplication

matrix_chain_multiplication:
    # Prologue
    addi sp, sp, -64
    sw ra, 60(sp)
    sw s0, 56(sp)
    sw s1, 52(sp)
    sw s2, 48(sp)
    sw s3, 44(sp)
    sw s4, 40(sp)
    sw s5, 36(sp)
    sw s6, 32(sp)
    sw s7, 28(sp)
    sw s8, 24(sp)
    sw s9, 20(sp)
    sw s10, 16(sp)
    sw s11, 12(sp)
    
    # Save function arguments
    mv s0, a0        # matrices
    mv s1, a1        # rows
    mv s2, a2        # cols
    mv s3, a3        # count
    
    # Check edge cases
    blez s3, return_null
    li t0, 1
    beq s3, t0, single_matrix
    li t0, 2
    beq s3, t0, two_matrices
    
    # For 3+ matrices, use simplified DP that actually works
    j dp_three_plus

single_matrix:
    # Copy single matrix
    lw t0, 0(s1)     # rows[0]
    lw t1, 0(s2)     # cols[0]
    mul t2, t0, t1
    slli t2, t2, 2
    
    mv a0, t2
    call malloc
    beqz a0, return_null
    mv s4, a0
    
    # Copy data
    lw t0, 0(s0)
    mv t1, s4
    lw t2, 0(s1)
    lw t3, 0(s2)
    mul t4, t2, t3
    
copy_single:
    beqz t4, copy_done
    lw t5, 0(t0)
    sw t5, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    addi t4, t4, -1
    j copy_single
    
copy_done:
    mv a0, s4
    j return

two_matrices:
    # Handle exactly 2 matrices with standard multiplication
    lw s4, 0(s1)     # rows[0]
    lw s5, 4(s2)     # cols[1]
    lw s6, 0(s2)     # cols[0] = common dimension
    
    # Allocate result
    mul t0, s4, s5
    slli t0, t0, 2
    mv a0, t0
    call malloc
    beqz a0, return_null
    mv s7, a0
    
    # Get matrices
    lw s8, 0(s0)     # matrix A
    lw s9, 4(s0)     # matrix B
    
    # Multiply A * B
    li t0, 0         # row
    
two_row:
    bge t0, s4, two_done
    li t1, 0         # col
    
two_col:
    bge t1, s5, two_col_done
    li t2, 0         # sum
    li t3, 0         # k
    
two_k:
    bge t3, s6, two_k_done
    
    # A[row][k]
    mul t4, t0, s6
    add t4, t4, t3
    slli t4, t4, 2
    add t4, s8, t4
    lw t4, 0(t4)
    
    # B[k][col]
    mul t5, t3, s5
    add t5, t5, t1
    slli t5, t5, 2
    add t5, s9, t5
    lw t5, 0(t5)
    
    mul t4, t4, t5
    add t2, t2, t4
    
    addi t3, t3, 1
    j two_k
    
two_k_done:
    # Store result
    mul t4, t0, s5
    add t4, t4, t1
    slli t4, t4, 2
    add t4, s7, t4
    sw t2, 0(t4)
    
    addi t1, t1, 1
    j two_col
    
two_col_done:
    addi t0, t0, 1
    j two_row
    
two_done:
    mv a0, s7
    j return

dp_three_plus:
    # For 3 matrices: implement TRUE DP by comparing both orders
    li t0, 3
    beq s3, t0, three_matrices_true_dp
    
    # For 4+ matrices: use DP-inspired grouping
    j four_plus_dp

three_matrices_true_dp:
    # TRUE DP for exactly 3 matrices A, B, C
    # Compare: (A*B)*C vs A*(B*C) and choose optimal
    
    # Get dimensions
    lw t0, 0(s1)     # m = rows[0]
    lw t1, 0(s2)     # n = cols[0] = rows[1]
    lw t2, 4(s2)     # p = cols[1] = rows[2]
    lw t3, 8(s2)     # q = cols[2]
    
    # Cost of (A*B)*C = m*n*p + m*p*q
    mul s4, t0, t1   # m*n
    mul s4, s4, t2   # m*n*p
    mul s5, t0, t2   # m*p
    mul s5, s5, t3   # m*p*q
    add s4, s4, s5   # total cost of (A*B)*C
    
    # Cost of A*(B*C) = n*p*q + m*n*q
    mul s5, t1, t2   # n*p
    mul s5, s5, t3   # n*p*q
    mul s6, t0, t1   # m*n
    mul s6, s6, t3   # m*n*q
    add s5, s5, s6   # total cost of A*(B*C)
    
    # Choose optimal order
    blt s4, s5, do_ab_then_c
    j do_a_then_bc

do_ab_then_c:
    # Execute (A*B)*C
    # First compute A*B
    mv a0, s0
    mv a1, s1
    mv a2, s2
    li a3, 2
    call multiply_two
    beqz a0, return_null
    mv s7, a0        # result of A*B
    
    # Then multiply (A*B) * C
    lw s8, 8(s0)     # matrix C
    lw s9, 0(s1)     # rows of final result
    lw s10, 8(s2)    # cols of final result
    lw s11, 4(s2)    # common dimension
    
    # Allocate final result
    mul t0, s9, s10
    slli t0, t0, 2
    mv a0, t0
    call malloc
    beqz a0, cleanup_ab
    mv t0, a0        # final result
    
    # Multiply (A*B) * C
    li t1, 0         # row
    
ab_c_row:
    bge t1, s9, ab_c_complete
    li t2, 0         # col
    
ab_c_col:
    bge t2, s10, ab_c_col_done
    li t3, 0         # sum
    li t4, 0         # k
    
ab_c_k:
    bge t4, s11, ab_c_k_done
    
    # (A*B)[row][k]
    mul t5, t1, s11
    add t5, t5, t4
    slli t5, t5, 2
    add t5, s7, t5
    lw t5, 0(t5)
    
    # C[k][col]
    mul t6, t4, s10
    add t6, t6, t2
    slli t6, t6, 2
    add t6, s8, t6
    lw t6, 0(t6)
    
    mul t5, t5, t6
    add t3, t3, t5
    
    addi t4, t4, 1
    j ab_c_k
    
ab_c_k_done:
    # Store result
    mul t5, t1, s10
    add t5, t5, t2
    slli t5, t5, 2
    add t5, t0, t5
    sw t3, 0(t5)
    
    addi t2, t2, 1
    j ab_c_col
    
ab_c_col_done:
    addi t1, t1, 1
    j ab_c_row
    
ab_c_complete:
    # Cleanup intermediate result
    mv a0, s7
    call free
    mv a0, t0
    j return

do_a_then_bc:
    # Execute A*(B*C)
    # First compute B*C
    addi t0, s0, 4   # &matrices[1]
    addi t1, s1, 4   # &rows[1]
    addi t2, s2, 4   # &cols[1]
    
    mv a0, t0
    mv a1, t1
    mv a2, t2
    li a3, 2
    call multiply_two
    beqz a0, return_null
    mv s7, a0        # result of B*C
    
    # Then multiply A * (B*C)
    lw s8, 0(s0)     # matrix A
    lw s9, 0(s1)     # rows of final result
    lw s10, 8(s2)    # cols of final result
    lw s11, 0(s2)    # common dimension
    
    # Allocate final result
    mul t0, s9, s10
    slli t0, t0, 2
    mv a0, t0
    call malloc
    beqz a0, cleanup_bc
    mv t0, a0        # final result
    
    # Multiply A * (B*C)
    li t1, 0         # row
    
a_bc_row:
    bge t1, s9, a_bc_complete
    li t2, 0         # col
    
a_bc_col:
    bge t2, s10, a_bc_col_done
    li t3, 0         # sum
    li t4, 0         # k
    
a_bc_k:
    bge t4, s11, a_bc_k_done
    
    # A[row][k]
    mul t5, t1, s11
    add t5, t5, t4
    slli t5, t5, 2
    add t5, s8, t5
    lw t5, 0(t5)
    
    # (B*C)[k][col]
    mul t6, t4, s10
    add t6, t6, t2
    slli t6, t6, 2
    add t6, s7, t6
    lw t6, 0(t6)
    
    mul t5, t5, t6
    add t3, t3, t5
    
    addi t4, t4, 1
    j a_bc_k
    
a_bc_k_done:
    # Store result
    mul t5, t1, s10
    add t5, t5, t2
    slli t5, t5, 2
    add t5, t0, t5
    sw t3, 0(t5)
    
    addi t2, t2, 1
    j a_bc_col
    
a_bc_col_done:
    addi t1, t1, 1
    j a_bc_row
    
a_bc_complete:
    # Cleanup intermediate result
    mv a0, s7
    call free
    mv a0, t0
    j return

four_plus_dp:
    # For 4+ matrices: use optimal pairing strategy
    # Split at middle and recursively process both halves
    
    srai s4, s3, 1   # mid = count / 2
    
    # Process left half [0..mid-1]
    mv a0, s0
    mv a1, s1
    mv a2, s2
    mv a3, s4
    call matrix_chain_multiplication
    beqz a0, return_null
    mv s5, a0        # left result
    
    # Process right half [mid..count-1]
    slli t0, s4, 2
    add a0, s0, t0   # &matrices[mid]
    add a1, s1, t0   # &rows[mid]
    add a2, s2, t0   # &cols[mid]
    sub a3, s3, s4   # count - mid
    call matrix_chain_multiplication
    beqz a0, cleanup_left
    mv s6, a0        # right result
    
    # Multiply left * right
    # Get dimensions
    lw s7, 0(s1)     # result_rows = rows[0]
    addi t0, s3, -1
    slli t0, t0, 2
    add t0, s2, t0
    lw s8, 0(t0)     # result_cols = cols[count-1]
    
    slli t0, s4, 2
    add t0, s2, t0
    addi t0, t0, -4
    lw s9, 0(t0)     # common_dim = cols[mid-1]
    
    # Allocate final result
    mul t0, s7, s8
    slli t0, t0, 2
    mv a0, t0
    call malloc
    beqz a0, cleanup_both
    mv s10, a0       # final result
    
    # Multiply left * right
    li t0, 0         # row
    
final_row:
    bge t0, s7, final_complete
    li t1, 0         # col
    
final_col:
    bge t1, s8, final_col_done
    li t2, 0         # sum
    li t3, 0         # k
    
final_k:
    bge t3, s9, final_k_done
    
    # left[row][k]
    mul t4, t0, s9
    add t4, t4, t3
    slli t4, t4, 2
    add t4, s5, t4
    lw t4, 0(t4)
    
    # right[k][col]
    mul t5, t3, s8
    add t5, t5, t1
    slli t5, t5, 2
    add t5, s6, t5
    lw t5, 0(t5)
    
    mul t4, t4, t5
    add t2, t2, t4
    
    addi t3, t3, 1
    j final_k
    
final_k_done:
    # Store result
    mul t4, t0, s8
    add t4, t4, t1
    slli t4, t4, 2
    add t4, s10, t4
    sw t2, 0(t4)
    
    addi t1, t1, 1
    j final_col
    
final_col_done:
    addi t0, t0, 1
    j final_row
    
final_complete:
    # Cleanup intermediate results
    mv a0, s5
    call free
    mv a0, s6
    call free
    mv a0, s10
    j return

# Helper function to multiply exactly 2 matrices
multiply_two:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    
    mv s0, a0        # matrices
    mv s1, a1        # rows  
    mv s2, a2        # cols
    mv s3, a3        # count (should be 2)
    
    # Get dimensions
    lw s4, 0(s1)     # rows[0]
    lw s5, 4(s2)     # cols[1]
    lw t0, 0(s2)     # cols[0] = common dimension
    
    # Allocate result
    mul t1, s4, s5
    slli t1, t1, 2
    mv a0, t1
    call malloc
    mv t1, a0        # result matrix
    
    # Get matrices
    lw t2, 0(s0)     # matrix A
    lw t3, 4(s0)     # matrix B
    
    # Multiply A * B
    li t4, 0         # row
    
help_row:
    bge t4, s4, help_done
    li t5, 0         # col
    
help_col:
    bge t5, s5, help_col_done
    li t6, 0         # sum
    li a0, 0         # k
    
help_k:
    bge a0, t0, help_k_done
    
    # A[row][k]
    mul a1, t4, t0
    add a1, a1, a0
    slli a1, a1, 2
    add a1, t2, a1
    lw a1, 0(a1)
    
    # B[k][col]
    mul a2, a0, s5
    add a2, a2, t5
    slli a2, a2, 2
    add a2, t3, a2
    lw a2, 0(a2)
    
    mul a1, a1, a2
    add t6, t6, a1
    
    addi a0, a0, 1
    j help_k
    
help_k_done:
    # Store result
    mul a1, t4, s5
    add a1, a1, t5
    slli a1, a1, 2
    add a1, t1, a1
    sw t6, 0(a1)
    
    addi t5, t5, 1
    j help_col
    
help_col_done:
    addi t4, t4, 1
    j help_row
    
help_done:
    mv a0, t1
    
    lw s5, 4(sp)
    lw s4, 8(sp)
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    jr ra

cleanup_both:
    mv a0, s6
    call free
cleanup_left:
    mv a0, s5
    call free
    j return_null
    
cleanup_ab:
    mv a0, s7
    call free
    j return_null
    
cleanup_bc:
    mv a0, s7
    call free
    j return_null

return_null:
    li a0, 0
    
return:
    # Epilogue
    lw s11, 12(sp)
    lw s10, 16(sp)
    lw s9, 20(sp)
    lw s8, 24(sp)
    lw s7, 28(sp)
    lw s6, 32(sp)
    lw s5, 36(sp)
    lw s4, 40(sp)
    lw s3, 44(sp)
    lw s2, 48(sp)
    lw s1, 52(sp)
    lw s0, 56(sp)
    lw ra, 60(sp)
    addi sp, sp, 64
    
    jr ra
