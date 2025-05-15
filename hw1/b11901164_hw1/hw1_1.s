
.data
input: .word 7

.text
.global main

# This is 1132 CA Homework 1
# Implement fact(x) = 4*F(floor(n-1)/2) + 8n + 3 , where F(0)=4
# Input: n in a0(x10)
# Output: fact(n) in a0(x10)
# DO NOT MOTIFY "main" function

main:        
	# Load input into a0
	lw a0, input
	
	# Jump to fact   
	jal fact       

    # You should use ret or jalr x1 to jump back here after function complete
	# Exit program
    # System id for exit is 10 in Ripes, 93 in GEM5 !
    li a7, 10
    ecall

fact:
    addi sp, sp, -8 # Allocate stack frame
    sw ra, 4(sp) # Save return address
    sw a0, 0(sp) # Save argument n
    
    # Base case: if n == 0, return 4
    beqz a0, base_case
    
    # Check if n is odd or even
    andi t0, a0, 1    # t0 = n & 1 (1 if odd, 0 if even)
    bnez t0, odd_case # If n is odd, jump to odd_case
    
even_case:
    # For even n: fact((n-2)/2)
    addi a0, a0, -2   # n-2
    srli a0, a0, 1    # (n-2)/2
    jal fact          # Recursive call
    # Result of fact((n-2)/2) is in a0
    j continue

odd_case:
    # For odd n: fact((n-1)/2)
    addi a0, a0, -1   # n-1
    srli a0, a0, 1    # (n-1)/2
    jal fact          # Recursive call
    # Result of fact((n-1)/2) is in a0

continue:
    # Multiply recursive result by 4
    slli a0, a0, 2    # 4*fact(...)
    
    # Load original n from stack
    lw t0, 0(sp)
    
    # Calculate 8n
    slli t1, t0, 3    # 8n
    
    # Add everything: 4*fact(...) + 8n + 3
    add a0, a0, t1    # Add 8n
    addi a0, a0, 3    # Add 3
    
    # Restore return address and stack pointer
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

base_case:
    li a0, 4          # Return 4 for n=0
    lw ra, 4(sp)
    addi sp, sp, 8
    ret
