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
    
    mv s0, a0        # matrices
    mv s1, a1        # rows
    mv s2, a2        # cols
    mv s3, a3        # count
    

# << create M,S >>
    
    addi t0,a3,0
    addi t0,s3,0
    mul t0, a3, a3
    slli t0, t0, 2
    mv a0, t0
    call malloc
    mv s4, a0        # current result
    
    mv a0, t0
    call malloc
    mv s5, a0        # current result
    
    mv a0, s0        # matrices
    mv a1, s1        # rows
    mv a2, s2        # cols
    mv a3, s3        # count
    mv a4, s4        # M
    mv a5, s5        # S
    

# << NOTE for variable >>


# matrix base->'0'
# l(s1): 2~n
# i(s2): 0~n-l
# k(s3): i~j-1
# j(s4): j=i+l-1
# s7: stored n-l+1 for # of loop i
# change for base '0'

# t5,t6,t7 
# s5,s6,s7,.....for compute
# using s5,s6 in loop k


# << loop >>

addi s1, zero,2    # initial l=2



for_l:
    addi s2, zero,0                # initial i=0
     
    # compute n(a3) - l(s1)+1 for loop i (s7)
    sub  s7,a3,s1


for_i:

    # s4: j=i+l-1
    add  s4, s2,s1    # i+l
    addi s4, s4,-1    # (i+l)-1
    
    # m[i,j]=inf,using initial m[i,j]=m[i,i]+m[i+1,j]+P_i-1 P_i P_j, k start from i+1 to j-1
    
    # t2=m[i,i]
    mul  t0,s2,a3    # i*n
    add  t0,t0,s2    # i*n+i
    slli t0,t0,2
    add  t0,t0,a4    # m[i,i]->a4+4[n*i+i]
    lw   t2, 0(t0)   # t2=m[i,i]
    
    # t3=m[i+1,j]
    addi t1,s2,1     # i+1
    mul  t0,t1,a3    # (i+1)*n
    add  t0,t0,s4    # (i+1)*n+j
    slli t0,t0,2
    add  t0,t0,a4    # m[i,i]->a4+4[(i+1)*n+j]
    lw   t3, 0(t0)   # t3=m[i+1,j]
    
    
    # t4=P_i-1=row[i],keep using in k
    slli t0,s2,2    # 4*i
    add  t0,t0,a1   # 4*i+a1
    lw   t4,0(t0)   # t3=P_i-1
    
    # t5=P_i=col[i],
    slli t0,s2,2    # 4*i
    add  t0,t0,a2   # 4*i+a2
    lw   t5,0(t0)   # t3=P_i
    
    # t6=P_j=col[j],keep using in k
    slli t0,s4,2    # 4*j
    add  t0,t0,a2   # 4*j+a2
    lw   t6,0(t0)   # t3=P_j

    
    # comput m[i,j]=m[i,i]+m[i+1,j]+P_i-1 P_i P_j(in s5)
    
    mul s5,t4,t5    # P_i-1 P_i
    mul s5,s5,t6    # P_i-1 P_i P_j
    add s5,s5,t2    # m[i,i]+P_i-1 P_i P_j
    add s5,s5,t3    # m[i,i]+m[i+1,j]+P_i-1 P_i P_j
    
    #stored m[i,j], s[i,j]
    mul  t0,s2,a3    # i*n
    add  t0,t0,s4    # i*n+j
    slli t0,t0,2
    
    add  t0,t0,a5    # s[i,j]->a5+4[n*i+j]
    sw   s2, 0(t0)   # stored k(s3)=i for s[i,j] 
    
    sub  t0,t0,a5    # 4[n*i+j]
    add  t0,t0,a4    # m[i,j]->a4+4[n*i+j]
    sw   s5, 0(t0)   # s5->m[i,j]
    
    
    # initial k=i+1
    addi s3,s2,1
    
for_k:
    
    # m[i,j]=m[i,k]+m[k+1,j]+P_i-1 P_k P_j
    
    # t2=m[i,k]
    mul  t0,s2,a3    # i*n
    add  t0,t0,s3    # i*n+k
    slli t0,t0,2
    add  t0,t0,a4    # m[i,k]->a4+4[n*i+k]
    lw   t2, 0(t0)   # t2=m[i,k]
    
    # t3=m[k+1,j]
    addi t1,s3,1     # k+1
    mul  t0,t1,a3    # (k+1)*n
    add  t0,t0,s4    # (k+1)*n+j
    slli t0,t0,2
    add  t0,t0,a4    # m[i,i]->a4+4[(i+1)*n+j]
    lw   t3, 0(t0)   # t3=m[k+1,j]

    # t5=P_k=col[k],
    slli t0,s3,2    # 4*k
    add  t0,t0,a2   # 4*k+a2
    lw   t5,0(t0)   # t5=P_k
    
    
    # load m[i,j] for compared (s5)
    mul  t0,s2,a3    # i*n
    add  t0,t0,s4    # i*n+j
    slli t0,t0,2
    add  t0,t0,a4    # m[i,j]->a4+4[n*i+j]
    lw   s5, 0(t0)   # s5->m[i,j]
    
    # comput new m[i,j]=m[i,k]+m[k+1,j]+P_i-1 P_k P_j (s6)
    mul s6,t4,t5    # P_i-1 P_k
    mul s6,s6,t6    # P_i-1 P_k P_j
    add s6,s6,t2    # m[i,k]+P_i-1 P_k P_j
    add s6,s6,t3    # m[i,i]+m[k+1,j]+P_i-1 P_k P_j
    
    # compared
    bge s6,s5, continued_loop        # if s6>=s5 -> no change
    
    # stored m[i,j]
    sw  s6, 0(t0)   # stored s5 for new m[i,j] , t0=m[i,j]->a4+4[n*i+j] (no change)
    
    # stored s[i,j]=k
    sub  t0,t0,a4    # 4[n*i+j]
    add  t0,t0,a5    # s[i,j]->a5+4[n*i+j]
    sw   s3, 0(t0)   # stored k(s3) for s[i,j]    
    

continued_loop:
        
    # k
    addi s3,s3,1         # k++
    blt  s3,s4, for_k    # if k(s3)<j(s4), go back    (k=i,i+1~j-1)
    
    # i
    addi s2,s2,1         # i++
    bge  s7,s2, for_i    # if n(a3) - l(s1)>=i, go back    (i=0~n(a3) - l(s1)+1)
    
    # l
    addi s1,s1,1         # l++
    bge  a3,s1, for_l    # if  n(a3)>=l, go back    ( l=1~n(a3)-1 )
    
    
# << end loop >>


# ************************************************************************************************************************************


# M,S matrix address in a4, a5 will be remove after call malloc. Save them in other space excipt a1~an
    
    # Save function arguments
    mv s0, a0        # matrices
    mv s1, a1        # rows
    mv s2, a2        # cols
    mv s3, a3        # count

# TODO: multiply matrix based on S matrix

# << return >>
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
