.text
.global matrix_chain_multiplication

matrix_chain_multiplication:

    # Your implementation here



    # Return to main program after completion (Remember to store the return address at the beginning)
    # jr ra
# << stored ra >>
    # stored ra to main 
    addi sp, sp, -4    
    sw   ra, 0(sp)

# << input >>
    
    # int **matrices, int *rows, int *cols, int count
    # load address
    
    # a0 = **matrices
    # a1 = *rows
    # a2 = *cols
    # a3 = n
    
# << create M,S >>

# create m[1:n,1:n], just using n*n

mul t0, a3,a3             # t0=n*n
mv a0, t0
call malloc               # m adress in a0
mv a4, a0                 # move malloc result to a4

# create s[1:n-1,2:n], just using n*n

mv a0, t0
call malloc               # s adress in a0
mv a5, a0                 # move malloc result to a5  


# assume initial value if '0'

# << NOTE for variable >>

# l(s1): 2~n
# i(s2): 1~n-l+1
# k(s3): i~j-1
# j(s4)


# t5,t6,t7 
# s5,s6,s7,.....for compute
# s4=5,s6 in loop k
# s7: stored n-l+1 for # of loop i

# << loop >>

addi s1, zero,2    # initial l=2



for_l:
    addi s2, zero, 1                # initial i=1 
    #compute n(a3) - l(s1)+1 for    # of loop i (s7)
    addi s7, a3, 1
    sub  s7, s7, s1

for_i:

    # s4: j=i+l-1
    add  s4, s2, s1    # i+l
    addi s4, s4,-1     # (i+l)-1
    
    # m[i,j]=inf,using initial m[i,j]=m[i,i]+m[i+1,j]+P_i-1 P_i P_j, k start from i+1 to j-1
    
    # t2=m[i,i]
    mul  t0, s2, a3    # i*n
    add  t0, t0, s2    # i*n+i
    slli t0, t0, 2     # (i*n+i)*4
    add  t0, t0, a4    # m[i,i]->a4+4[n*i+i]
    lw   t2, 0(t0)     # t2=m[i,i]
    
    # t3=m[i+1,j]
    addi t1, s2, 1     # i+1
    mul  t0, t1, a3    # (i+1)*n
    add  t0, t0, s4    # (i+1)*n+j
    slli t0, t0, 2     # ((i+1)*n+j)*4
    add  t0, t0, a4    # m[i,i]->a4+4[(i+1)*n+j]
    lw   t3, 0(t0)     # t3=m[i+1,j]
    
    
    # t4=P_i-1=row[i],keep using in k
    slli t0, s2, 2    # 4*i
    add  t0, t0, a1   # 4*i+a1
    lw   t4, 0(t0)    # t3=P_i-1
    
    # t5=P_i=col[i],
    slli t0, s2, 2    # 4*i
    add  t0, t0, a2   # 4*i+a2
    lw   t5, 0(t0)    # t3=P_i
    
    # t6=P_j=col[j],keep using in k
    slli t0, s4, 2    # 4*j
    add  t0, t0, a2   # 4*j+a2
    lw   t6, 0(t0)    # t3=P_j

    
    # comput m[i,j]=m[i,i]+m[i+1,j]+P_i-1 P_i P_j(in s5)
    
    mul s5, t4, t5    # P_i-1 P_i
    mul s5, s5, t6    # P_i-1 P_i P_j
    add s5, s5, t2    # m[i,i]+P_i-1 P_i P_j
    add s5, s5, t3    # m[i,i]+m[i+1,j]+P_i-1 P_i P_j
    
    #stored m[i,j]
    mul  t0, s2, a3    # i*n
    add  t0, t0, s4    # i*n+j
    slli t0, t0, 2     # (i*n+j)*4
    add  t0, t0, a4    # m[i,j]->a4+4[n*i+j]
    sw   s5, 0(t0)     # s5->m[i,j]
    
    
    # initial k=i+1
    addi s3, s2, 1
    
for_k:
    
    # m[i,j]=m[i,k]+m[k+1,j]+P_i-1 P_k P_j
    
    # t2=m[i,k]
    mul  t0, s2, a3    # i*n
    add  t0, t0, s3    # i*n+k
    slli t0, t0, 2     # (i*n+k)*4
    add  t0, t0, a4    # m[i,k]->a4+4[n*i+k]
    lw   t2, 0(t0)     # t2=m[i,k]
    
    # t3=m[k+1,j]
    addi t1, s3, 1     # k+1
    mul  t0, t1, a3    # (k+1)*n
    add  t0, t0, s4    # (k+1)*n+j
    slli t0, t0, 2     # ((k+1)*n+j)*4
    add  t0, t0, a4    # m[i,i]->a4+4[(i+1)*n+j]
    lw   t3, 0(t0)     # t3=m[k+1,j]

    # t5=P_k=col[k],
    slli t0, s3, 2    # 4*k
    add  t0, t0, a2   # 4*k+a2
    lw   t5, 0(t0)    # t5=P_k
    
    
    # load m[i,j] for compared (s6)
    mul  t0, s2, a3    # i*n
    add  t0, t0, s4    # i*n+j
    slli t0, t0, 2     # (i*n+j)*4
    add  t0, t0, a4    # m[i,j]->a4+4[n*i+j]
    lw   s6, 0(t0)     # s5->m[i,j]
    
    # comput new m[i,j]=m[i,k]+m[k+1,j]+P_i-1 P_k P_j (s5)
    mul s5, t4, t5    # P_i-1 P_k
    mul s5, s5, t6    # P_i-1 P_k P_j
    add s5, s5, t2    # m[i,k]+P_i-1 P_k P_j
    add s5, s5, t3    # m[i,i]+m[k+1,j]+P_i-1 P_k P_j
    
    # compared
    bge s5, s6, continued_loop    # if s5>=s6 -> no change
    
    # stored m[i,j]
    sw  s5, 0(t0)   # stored s5 for new m[i,j] , t0=m[i,j]->a4+4[n*i+j] (no change)
    
    # stored s[i,j]=k
    sub  t0, t0, a4    # 4[n*i+j]
    add  t0, t0, a5    # s[i,j]->a5+4[n*i+j]
    sw   s3, 0(t0)     # stored k(s3) for s[i,j]    
    

continued_loop:
        
    # k
    addi s3, s3, 1        # k++
    blt  s3, s4, for_k    # if k(s3)<j(s4), go back    (k=i,i+1~j-1)
    
    # i
    addi s2, s2, 1        # i++
    bge  s7, s2, for_i    # if s7(n(a3) - l(s1)+1)>=i, go back    (i=1~n(a3) - l(s1)+1)
    
    # l
    addi s1, s1, 1        # l++
    bge  a3, s1, for_l    # if n(a3)>=l(s1), go back    (l=2~n(a3))
    
# << end loop >>

# << implement multiplication of s table >>