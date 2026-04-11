.section .data
filename:   .string "input.txt"
mode:       .string "r"
yes_str:    .string "Yes\n"
no_str:     .string "No\n"

.section .text
.global main

main:
    # save the things on the
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)    # will store FILE pointer
    sd s1, 24(sp)    # will store left
    sd s2, 16(sp)    # will store right (file size)
    sd s3, 8(sp)     # temp char storage

    # fopen("input.txt", "r")
    la a0, filename
    la a1, mode
    call fopen
    mv s0, a0        # s0 = FILE pointer
    
    # fseek(fp, 0, SEEK_END)  -- SEEK_END = 2
    mv a0, s0
    li a1, 0
    li a2, 2
    call fseek     # takes file pointer (s0) to the end

    # ftell(fp) -- returns file size
    mv a0, s0
    call ftell
    addi s2, a0, -1  # s2 = right = size - 1
                     # -1 because we ignore newline at end

    # s1 = left = 0
    li s1, 0

loop:
    # if left >= right we're done -> palindrome
    bge s1, s2, print_yes

    # fseek to left position
    mv a0, s0        # file pointer
    mv a1, s1        # offset 
    li a2, 0         # SEEK_SET = 0
    call fseek

    # read left char
    mv a0, s0
    call fgetc
    mv s3, a0        # save left char

    # fseek to right position
    mv a0, s0
    mv a1, s2
    li a2, 0         # SEEK_SET = 0
    call fseek

    # read right char
    mv a0, s0
    call fgetc       # a0 = right char

    # compare left and right chars
    bne s3, a0, print_no

    # move pointers inward
    addi s1, s1, 1   # left++
    addi s2, s2, -1  # right--
    j loop

print_yes:
    la a0, yes_str
    call puts
    j done

print_no:
    la a0, no_str
    call puts

done:
    # restore registers and return
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    addi sp, sp, 48
    li a0, 0
    ret