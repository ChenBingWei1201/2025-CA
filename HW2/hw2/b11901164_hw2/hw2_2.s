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
    li a7, 93
    ecall

LIS:
     # Preserve return address
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)

    li s2, 0

    # Outer loop: for(int i = 1; i < n; i++)
    li s0, 1          # i = 1
outer_loop:
    bge s0, a0, done

    slli t6, s0, 2        # t6 = i*4
    add t3, a1, t6        # t3 = &nums[i]
    lw t4, 0(t3)          # t4 = nums[i]

    add t5, a2, t6        # t5 = &dp[i]
    lw a4, 0(t5)          # a4 = dp[i]

    li s1, 0              # j = 0
inner_loop:
    bge s1, s0, update_max

    # Calculate memory addresses for nums[j], nums[i], dp[j], dp[i]
    slli t0, s1, 2    # t0 = j * 4 (word size)
    add t1, a1, t0    # t1 = &nums[j]
    lw t2, 0(t1)      # t2 = nums[j]

    bge t2, t4, continue_inner

    add t1, a2, t0    # t1 = &dp[j]
    lw t3, 0(t1)      # a3 = dp[j]

    # dp[i] = max(dp[i], dp[j] + 1)
    addi t3, t3, 1      # dp[j] + 1
    ble t3, a4, continue_inner # if dp[i] >= dp[j] + 1, skip

    mv a4, t3

continue_inner:
    addi s1, s1, 1    # j++
    j inner_loop

update_max:
    sw a4, 0(t5)

    ble a4, s2, increment_i
    mv s2, a4

increment_i:
    addi s0, s0, 1   # i++
    j outer_loop

done:
    # Result (max subsequence length) is in t0
    addi a0, s2, 1      # add 1 to result

    # Restore stack and return
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
