.data
    format_str:  .string "%d "   
    newline_str: .string "\n"    

.text
.globl main
main:
# here a0 will have the number of argumnets 
# and a1 will be the pointer to the array of strings

# saving the stack before
addi sp , sp , -64
sd ra , 0(sp)
sd s0 , 8(sp)
sd s1 , 16(sp)
sd s2 , 24(sp)
sd s3 , 32(sp)
sd s4 , 40(sp)
sd s5 , 48(sp)

mv s0 , a0 # now s0 holds the number of arguments
mv s1 , a1 # now s1 hold the pointer to the array of strings
li s2 , 1 # index i = 1 is store in s2
slli a0,s0,2 # now a0 = s0 * 4
call malloc 
mv s4 , a0 # now s4 holds the memory address of the malloced array
mv s5 , s4 # let this be the temporary address we keep for incrementing the value
addi s4, s4 ,4
getting_values:
    bge s2 , s0 , main_logic

    slli  t0 , s2 , 3 # now what this does is multiplies the index by 3 and stores it in t0
    add t0 , s1 , t0 # now t0 hold the pointer to the string
    ld a0 , 0(t0)
    call atoi   # now a0 will hold the value
    sw a0,0(s4)
    addi s4 , s4 , 4
    add s2 , s2 , 1
    j getting_values

main_logic:
# now we have the pointer to array of int(4 bits) we needed in s4
# but since we don't need s1 , s5 , we can reorganise things node
mv s1 , s5 # now s1 has the pointer to array , s0 has the number of int , s2 has the index
# we need 2 arrays now more , one as a stack(let it be s4) , and one as an answer array(let it be s5)
mv a0 , s0
slli a0 , a0 , 2
call malloc # let this be the stack
mv s4 , a0 # now s4 stores the stack
mv a0 , s0
slli a0 , a0 , 2 
call malloc # let this be answer array
mv s5 , a0

addi s0 , s0 , -1 # since we know it also takes ./q1 as an argument so s0 has to be subtracted by 2 , now s0 = n
mv s2, s0 # s2 = n , this is the index
li t3, -1 # this is the stack pointer we assign it to -1 initially
final_calculation:
    beq s2, x0 , end
    slli t0,s2,2
    add t0, s1, t0
    lw t0 , 0(t0) # now t0 holds the value of array element

        stack_loop:
        blt t3 , x0 , endloop
        slli t2 , t3 , 2
        add t4,t2,s4
        lw t1 , 0(t4) # now t1 holds the top of stack (which is an index)
        slli t5, t1, 2
        add t5, s1, t5
        lw t5, 0(t5) # now t5 holds the actual array value for comparison
        bgt t5,t0,endloop
        addi t3,t3,-1
        j stack_loop

    endloop:
        blt t3,x0,empty_stack_case
        slli t2 , t3 , 2
        add t4,t2,s4
        lw t1 , 0(t4) # now t1 holds the stack top element (index)
        addi t1, t1, -1 # convert 1-based index to 0-based
        slli t2,s2,2 # t2 = index * 4
        add t4,t2,s5 # now t4 = t2(s5) , where s5 = ans array
        sw t1,0(t4) # now t1 gets stored here at j(ans) for j = 1,...,n
        addi t3,t3,1 # stackpointer++
        slli t2,t3,2 # stackpointer * 4 stored in t2
        add t4,s4,t2
        sw s2,0(t4) # stack[stacpoi.] = s2(array's index) basically pushed
        addi s2 , s2 , -1
        j final_calculation

    empty_stack_case:
        li t1 ,-1
        slli t2,s2,2 # t2 = index * 4
        add t4,t2,s5 # now t4 = t2(s5) , where s5 = ans array
        sw t1,0(t4)
        addi t3,t3,1 # stackpointer++
        slli t2,t3,2 # stackpointer * 4 stored in t2
        add t4, s4, t2
        sw s2,0(t4) # stack[stacpoi.] = s2(array's index) basically pushed
        addi s2 , s2 , -1
        j final_calculation

end:
    # --- PRINTING THE ANSWER ARRAY ---
    li s2, 1               # Reset index to 1 (since we used 1-based indexing!)

print_loop:
    bgt s2, s0, print_done # If index > n, we are done printing!

    # 1. Fetch the answer from memory into a1 (printf's 2nd argument)
    slli t0, s2, 2         # t0 = index * 4
    add t0, s5, t0         # Add base address of Ans array (s5)
    lw a1, 0(t0)           # a1 = ans[index]

    # 2. Load the format string into a0 (printf's 1st argument)
    la a0, format_str      # 'la' stands for Load Address
    
    # 3. Call printf
    call printf

    # 4. Increment and loop
    addi s2, s2, 1         # index++
    j print_loop

print_done:
    # Optional: Print a newline at the very end to make the terminal look clean
    la a0, newline_str
    call printf

    # --- EPILOGUE ---
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    ld s5, 48(sp)
    addi sp, sp, 64
    
    li a0, 0               # Return 0 (Success)
    ret