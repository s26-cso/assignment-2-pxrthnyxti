.globl make_node
.globl get
.globl insert
.globl getAtMost
make_node:
# saving the things in stack
    addi sp, sp , -16 # minimum of 16 has to be done
    sd ra , 0(sp)
    sd s0 , 8(sp)

    mv s0 , a0 # s0 now has the "val" argument
    li a0 , 24 # we allot 24 bits as every address is 8bits
    call malloc # now malloc gets called and the argument for that is 12 bits
    
# we get a0 now pointing towards the node
    sd s0 , 0(a0) # val gets stored
    sd x0 , 8(a0)  # leftpointer = NULL
    sd x0 , 16(a0)  # rightpointer = NULL
# restoring stack
    ld s0 , 8(sp)
    ld ra , 0(sp)
    addi sp, sp, 16


    ret #a0 holds the  address of struct node




#-----------------------------------------------
insert:
# we have a0 as the root and a1 as the val
# saving on stack first
    addi sp, sp, -48
    sd ra, 0(sp)
    sd s0 , 8(sp)
    sd s1 , 16(sp)
    sd s2 , 24(sp)
    sd s3 , 32(sp)

    mv s0,a0 # now s0 holds a0(the root)
    mv s1,a1 # now s1 hold a1(the val)
    mv a0,a1 # now a0 will hold the val
    call make_node # now a0 hold the pointer to the new node
    mv s2,a0 # now s2 will hold the pointer to the new node
    beq s0,x0,null_case_insert
    mv s3,s0 # s3 becomes the cur node
traversal:
    lw t0,0(s3)
    bgt t0,s1,go_left_insert

go_right_insert:
    ld t1,16(s3) # t1 holds the address for right node now
    beq t1,x0,go_right_null # here if the left pointer is null 
    mv s3,t1
    j traversal

go_right_null:
    sd s2,16(s3)
    mv a0,s0
    j exit_insert

go_left_insert:
    ld t1,8(s3) # t1 holds the address for left node now
    beq t1,x0,go_left_null # here if the left pointer is null 
    mv s3,t1
    j traversal

go_left_null:
    sd s2,8(s3)
    mv a0,s0
    j exit_insert

null_case_insert:
    mv a0,s2
exit_insert:
    ld ra, 0(sp)
    ld s0 , 8(sp)
    ld s1 , 16(sp)
    ld s2 , 24(sp)
    ld s3 , 32(sp)
    addi sp, sp, 48
    ret

#-------------------------------------------------------------------------
get:
# we have a0 as the root node and a1 as the val we are searching for
# saving values on stack first
    addi sp, sp ,-16
    sd ra, 0(sp)
    sd s0, 8(sp)

    mv s0,a1 # now s0 hold a1(the val)

traversal_get:
    beq a0,x0,return_null
    ld t0,0(a0)
    beq t0,s0,exit_get
    bge t0,s0,go_leftget

go_rightget:
    ld t0,16(a0)
    mv a0,t0
    j traversal_get

go_leftget:
    lw t0,8(a0)
    mv a0,t0
    j traversal_get

return_null:
li a0,0

exit_get:
    ld ra, 0(sp)
    ld s0, 8(sp)
    addi sp, sp, 16
    ret #here a0 will have the address of the desired node

# ------------------------------------------------------------
getAtMost:
# here a0 will have the val and a1 will have the root node
# let us store the max value in t2
li t2,-1
beq a1,x0,exit

finding:
lw t0,0(a1) # now t0 holds the value 
blt a0,t0,go_left
bge t0,t2,change_values

go_right:
ld t1,16(a1)
beq t1,x0,exit
mv a1,t1
j finding

go_left:
ld t1,8(a1) # now t1 holds the address of the leftnode
beq t1,x0,exit
mv a1,t1 # now a1 holds the address of the leftnode
j finding

change_values:
mv t2,t0
j go_right

exit:
mv a0 , t2
ret
