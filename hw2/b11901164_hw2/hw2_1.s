.data
nums:   .word 4, 5, 1, 8, 3, 6, 9 ,2   # input sequence
n:      .word 8                        # sequence length
dp:     .word 0, 0, 0, 0, 0, 0, 0, 0   # dp array


.text
.globl main

# This is 1132 CA Homework 2 Problem 1
# Implement Longest Increasing Subsequence Algorithm
# Input: 
#       sequence length (n) store in a0
#       address of sequence store in a1
#       address of dp array with length n store in a2 (we can decide to use or not)        
# Output: Length of Longest Increasing Subsequenc in a0(x10)

# DO NOT MODIFY "main" FUNCTION !!!

main:

    lw a0, n          # a0 = n
    la a1, nums       # a1 = &nums[0]
    la a2, dp         # a2 = &dp[0] 
      
    jal LIS         # Jump to LIS algorithm
    
    # You should use ret or jalr x1 to jump back after algorithm complete
    # Exit program
    # System id for exit is 10 in Ripes, 93 in GEM5 
    li a7, 10
    nop
    nop
    nop
    ecall

LIS:
    # Preserve return address
    addi sp, sp, -4
    sw ra, 0(sp)

    # Outer loop: for(int i = 1; i < n; i++)
    li s0, 1          # i = 1
outer_loop:
    bge s0, a0, find_max_subsequence  # if i >= n, exit outer loop

    # Inner loop: for(int j = 0; j < i; j++)
    li s1, 0          # j = 0
inner_loop:
    bge s1, s0, increment_i  # if j >= i, exit inner loop

    # Calculate memory addresses for nums[j], nums[i], dp[j], dp[i]
    slli t0, s1, 2    # t0 = j * 4 (word size)
    add t1, a1, t0    # t1 = &nums[j]
    lw t2, 0(t1)      # t2 = nums[j]

    slli t0, s0, 2    # t0 = i * 4
    add t3, a1, t0    # t3 = &nums[i]
    lw t4, 0(t3)      # t4 = nums[i]
    nop
    nop
    bge t2, t4, continue_inner  # if nums[j] >= nums[i], skip

    # Calculate dp[j] and dp[i] addresses
    slli t0, s1, 2
    add t5, a2, t0    # t5 = &dp[j]
    lw a3, 0(t5)       # a3 = dp[j]

    slli t0, s0, 2
    add t5, a2, t0    # t5 = &dp[i]
    lw a4, 0(t5)       # a4 = dp[i]

    # dp[i] = max(dp[i], dp[j] + 1)
    addi a3, a3, 1    # dp[j] + 1
    nop               # Add bubble for a4 hazard
    nop
    bge a4, a3, continue_inner  # if dp[i] >= dp[j]+1, skip

    sw a3, 0(t5)       # update dp[i]

continue_inner:
    addi s1, s1, 1    # j++
    j inner_loop

increment_i:
    addi s0, s0, 1    # i++
    j outer_loop

# Find max value in dp array
find_max_subsequence:
    li t0, 0          # max = 0
    li s1, 0          # i = 0
find_max_loop:
    bge s1, a0, done   # if i >= n, exit

    slli t1, s1, 2     # t1 = i * 4
    add t2, a2, t1     # t2 = &dp[i]
    lw t3, 0(t2)       # t3 = dp[i]
    nop
    nop
    bge t0, t3, continue_max  # if max >= dp[i], skip
    mv t0, t3         # max = dp[i]

continue_max:
    addi s1, s1, 1    # i++
    j find_max_loop

done:
    # Result (max subsequence length) is in t0
    mv a0, t0         # move result to return register
    addi a0, a0, 1    # add 1 to result

    # Restore stack and return
    lw ra, 0(sp)
    addi sp, sp, 4
    nop
    nop
    ret
