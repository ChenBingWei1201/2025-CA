.text
.global matrix_chain_multiplication

matrix_chain_multiplication:
    # Prologue - save registers and allocate stack space
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
    
    # Save input parameters
    mv s0, a0        # matrices
    mv s1, a1        # rows
    mv s2, a2        # cols
    mv s3, a3        # count
    
    # OPTIMIZATION 1: Single allocation for M and S tables
    mul t0, s3, s3   # count * count
    slli t1, t0, 3   # * 8 (for both M and S tables)
    mv a0, t1
    call malloc
    mv s4, a0        # s4 = M table
    
    # S table starts after M table
    slli t0, t0, 2   # count * count * 4
    add s5, s4, t0   # s5 = S table
    
    # PHASE 1: DP computation - Initialize M[i][i] = 0
    li t0, 0         # i = 0
init_diagonal:
    mul t1, t0, s3   # i * count
    add t1, t1, t0   # i * count + i
    slli t1, t1, 2   # * 4
    add t1, s4, t1   # &M[i][i]
    sw zero, 0(t1)   # M[i][i] = 0
    
    addi t0, t0, 1   # i++
    blt t0, s3, init_diagonal
    
    # Main DP loop
    li s6, 2         # l = 2 (chain length)
    
for_l:
    li s7, 0         # i = 0
    
for_i:
    # Calculate j = i + l - 1
    add s8, s7, s6   # i + l
    addi s8, s8, -1  # j = i + l - 1
    
    # Initialize M[i][j] to infinity
    li t0, 0x7FFFFFFF
    mul t1, s7, s3   # i * count
    add t1, t1, s8   # i * count + j
    slli t1, t1, 2   # * 4
    add t1, s4, t1   # &M[i][j]
    sw t0, 0(t1)     # M[i][j] = infinity
    
    # OPTIMIZATION 2: Cache dimension values
    slli t1, s7, 2   # i * 4
    add t1, s1, t1   # &rows[i]
    lw s9, 0(t1)     # s9 = rows[i] (cache for k loop)
    
    slli t1, s8, 2   # j * 4
    add t1, s2, t1   # &cols[j]
    lw s10, 0(t1)    # s10 = cols[j] (cache for k loop)
    
    # Try all split points k = i to j-1
    mv s11, s7       # k = i
    
for_k:
    # Calculate cost: M[i][k] + M[k+1][j] + rows[i] * cols[k] * cols[j]

    # Get M[i][k]
    mul t0, s7, s3   # i * count
    add t0, t0, s11  # i * count + k
    slli t0, t0, 2   # * 4
    add t0, s4, t0   # &M[i][k]
    lw t1, 0(t0)     # t1 = M[i][k]
    
    # Get M[k+1][j]
    addi t2, s11, 1  # k + 1
    mul t0, t2, s3   # (k+1) * count
    add t0, t0, s8   # (k+1) * count + j
    slli t0, t0, 2   # * 4
    add t0, s4, t0   # &M[k+1][j]
    lw t2, 0(t0)     # t2 = M[k+1][j]
    
    # Get cols[k]
    slli t0, s11, 2  # k * 4
    add t0, s2, t0   # &cols[k]
    lw t3, 0(t0)     # t3 = cols[k]
    
    # Calculate cost: M[i][k] + M[k+1][j] + rows[i] * cols[k] * cols[j]
    mul t4, s9, t3   # rows[i] * cols[k] (using cached rows[i])
    mul t4, t4, s10  # rows[i] * cols[k] * cols[j] (using cached cols[j])
    add t4, t4, t1   # + M[i][k]
    add t4, t4, t2   # + M[k+1][j]
    
    # Compare with current M[i][j]
    mul t0, s7, s3   # i * count
    add t0, t0, s8   # i * count + j
    slli t0, t0, 2   # * 4
    add t0, s4, t0   # &M[i][j]
    lw t1, 0(t0)     # current M[i][j]
    
    # If new cost is better, update
    bge t4, t1, skip_update
    
    # Update M[i][j]
    sw t4, 0(t0)
    
    # Update S[i][j]
    sub t0, t0, s4   # offset from M table
    add t0, s5, t0   # &S[i][j]
    sw s11, 0(t0)    # S[i][j] = k
    
skip_update:
    addi s11, s11, 1 # k++
    blt s11, s8, for_k
    
    # Continue i loop
    addi s7, s7, 1   # i++
    sub t0, s3, s6   # count - l
    addi t0, t0, 1   # count - l + 1
    blt s7, t0, for_i
    
    # Continue length loop
    addi s6, s6, 1   # l++
    ble s6, s3, for_l
    
    # PHASE 2: Allocate result table
    mul t0, s3, s3   # count * count
    slli t0, t0, 2   # * 4
    mv a0, t0
    call malloc
    mv s6, a0        # s6 = result table
    
    # Initialize result table with single matrices
    li t0, 0         # i = 0
init_result_table:
    # result[i][i] = matrices[i]
    slli t1, t0, 2   # i * 4
    add t1, s0, t1   # &matrices[i]
    lw t2, 0(t1)     # matrices[i]
    
    mul t1, t0, s3   # i * count
    add t1, t1, t0   # i * count + i
    slli t1, t1, 2   # * 4
    add t1, s6, t1   # &result[i][i]
    sw t2, 0(t1)     # result[i][i] = matrices[i]
    
    addi t0, t0, 1   # i++
    blt t0, s3, init_result_table
    
    # PHASE 3: Bottom-up multiplication using S table
    li s7, 2         # l = 2
    
multiply_length_loop:
    li s8, 0         # i = 0
    
multiply_i_loop:
    # Calculate j = i + l - 1
    add s9, s8, s7   # i + l
    addi s9, s9, -1  # j = i + l - 1
    
    # Get optimal split point k = S[i][j]
    mul t0, s8, s3   # i * count
    add t0, t0, s9   # i * count + j
    slli t0, t0, 2   # * 4
    add t0, s5, t0   # &S[i][j]
    lw s10, 0(t0)    # k = S[i][j]
    
    # Get left matrix: result[i][k]
    mul t0, s8, s3   # i * count
    add t0, t0, s10  # i * count + k
    slli t0, t0, 2   # * 4
    add t0, s6, t0   # &result[i][k]
    lw s11, 0(t0)    # left_matrix = result[i][k]
    
    # Get right matrix: result[k+1][j]
    addi t1, s10, 1  # k + 1
    mul t0, t1, s3   # (k+1) * count
    add t0, t0, s9   # (k+1) * count + j
    slli t0, t0, 2   # * 4
    add t0, s6, t0   # &result[k+1][j]
    lw t0, 0(t0)     # right_matrix = result[k+1][j]
    
    # Get dimensions for multiplication
    slli t1, s8, 2   # i * 4
    add t1, s1, t1   # &rows[i]
    lw t1, 0(t1)     # rows_left = rows[i]
    
    slli t2, s10, 2  # k * 4
    add t2, s2, t2   # &cols[k]
    lw t2, 0(t2)     # cols_left = cols[k]
    
    slli t3, s9, 2   # j * 4
    add t3, s2, t3   # &cols[j]
    lw t3, 0(t3)     # cols_right = cols[j]
    
    # Call matrix multiplication
    mv a0, t1        # rows_left
    mv a1, t2        # cols_left
    mv a2, t3        # cols_right
    mv a3, s11       # left_matrix
    mv a4, t0        # right_matrix
    
    # Save registers before function call
    addi sp, sp, -32
    sw s7, 28(sp)
    sw s8, 24(sp)
    sw s9, 20(sp)
    sw s10, 16(sp)
    sw s11, 12(sp)
    sw t0, 8(sp)
    sw t1, 4(sp)
    sw t2, 0(sp)
    
    call multiply_two_matrices
    
    # Restore registers
    lw t2, 0(sp)
    lw t1, 4(sp)
    lw t0, 8(sp)
    lw s11, 12(sp)
    lw s10, 16(sp)
    lw s9, 20(sp)
    lw s8, 24(sp)
    lw s7, 28(sp)
    addi sp, sp, 32
    
    # Store result in result[i][j]
    mul t0, s8, s3   # i * count
    add t0, t0, s9   # i * count + j
    slli t0, t0, 2   # * 4
    add t0, s6, t0   # &result[i][j]
    sw a0, 0(t0)     # result[i][j] = multiplication result
    
    # Continue i loop
    addi s8, s8, 1   # i++
    sub t0, s3, s7   # count - l
    addi t0, t0, 1   # count - l + 1
    blt s8, t0, multiply_i_loop
    
    # Continue length loop
    addi s7, s7, 1   # l++
    ble s7, s3, multiply_length_loop
    
    # Get final result: result[0][count-1]
    addi t0, s3, -1  # count - 1
    slli t0, t0, 2   # * 4
    add t0, s6, t0   # &result[0][count-1]
    lw t1, 0(t0)     # final result matrix
    
    # Free allocated memory
    mv a0, s4        # free M+S table
    call free
    mv a0, s6        # free result table
    call free
    
    # Return final result
    mv a0, t1
    j epilogue


epilogue:
    # Restore registers and return
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

# OPTIMIZATION 3: Optimized matrix multiplication with reduced instruction overhead
multiply_two_matrices:
    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)
    
    mv s0, a0        # rows_left
    mv s1, a1        # cols_left
    mv s2, a2        # cols_right
    mv s3, a3        # left_matrix
    mv s4, a4        # right_matrix
    
    # Allocate result matrix
    mul t0, s0, s2   # rows_left * cols_right
    slli t0, t0, 2   # * 4 bytes
    mv a0, t0
    call malloc
    mv s5, a0        # s5 = result_matrix
    
    # Cache row size calculations to reduce multiplications
    slli s6, s2, 2   # cols_right * 4 (for B row stride)
    
    # Triple nested loop for matrix multiplication
    li t0, 0         # i = 0
    mv t6, s3        # current A row pointer = left_matrix
    
mult_i_loop:
    li t1, 0         # j = 0
    mv t5, s5        # result row start
    mul a0, t0, s2   # i * cols_right
    slli a0, a0, 2   # * 4
    add t5, s5, a0   # &result[i][0]
    
mult_j_loop:
    li t2, 0         # k = 0
    li a1, 0         # sum = 0
    mv a2, t6        # A row pointer
    mv a3, s4        # B start
    slli a0, t1, 2   # j * 4
    add a3, s4, a0   # &B[0][j]
    
mult_k_loop:
    # Load A[i][k] - use row pointer
    lw a4, 0(a2)     # A[i][k]
    addi a2, a2, 4   # advance A pointer
    
    # Load B[k][j] - use column pointer  
    lw a5, 0(a3)     # B[k][j]
    add a3, a3, s6   # advance B pointer by row stride (cols_right * 4)
    
    # Multiply and accumulate: sum += A[i][k] * B[k][j]
    mul a6, a4, a5   # A[i][k] * B[k][j]
    add a1, a1, a6   # sum += product
    
    # Continue k loop
    addi t2, t2, 1   # k++
    blt t2, s1, mult_k_loop
    
    # Store C[i][j] = sum
    sw a1, 0(t5)     # result[i][j] = sum
    addi t5, t5, 4   # advance result pointer
    
    # Continue j loop
    addi t1, t1, 1   # j++
    blt t1, s2, mult_j_loop
    
    # Advance to next A row
    slli a0, s1, 2   # cols_left * 4 
    add t6, t6, a0   # advance A row pointer
    
    # Continue i loop
    addi t0, t0, 1   # i++
    blt t0, s0, mult_i_loop
    
    # Return result matrix
    mv a0, s5
    
    # Epilogue
    lw s6, 0(sp)
    lw s5, 4(sp)
    lw s4, 8(sp)
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw s0, 24(sp)
    lw ra, 28(sp)
    addi sp, sp, 32
    jr ra
