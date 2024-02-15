.data
prompt: .asciiz "Enter your howard ID: "
prompt2: .asciiz "Enter characters(serperate the substring with '/'): "
Char: .asciiz "Enter character code: "
Lower: .asciiz "abcdefghijklmnopqrstuvwxyz"
Upper: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
input: .space 20 
stack: .space 100
output: .space 1000
newline: .asciiz "\n"

.text
main:
    # Enter Howard ID
    li $v0, 4         # syscall code for print_str
    la $a0, prompt    # load address of the prompt string
    syscall

    # Store Howard ID
    li $v0, 5         # syscall code for read_int
    syscall
    move $s0, $v0

    li $t0, 11        # load divisor (11)
    div $s0, $t0      # divide Howard ID by 11
    mfhi $s1          # get the remainder (modulo) and store in $s1

    # Add 26 to the remainder
    li $t2, 26
    add $s1, $s1, $t2
    li $t3, 10
    sub $s1, $s1, $t3


    # Print the character at index 19
    li $v0, 11               # system call code for printing a character
    la $t2, Upper
    li $t4, 1
    sub $s1, $s1, $t4            # load the address of the string
    add $t2, $t2, $s1        # move to the character at index 19
    lb $t2, ($t2)            # load the character
    syscall

    li $v0, 4 
    la $a0, prompt2
    syscall

    # Read string input
    li $v0, 8
    la $a0, input
    li $a1, 20
    syscall

    # Process the input string
    la $a0, input       # Pointer to input string
    la $t1, stack       # Pointer to stack
    la $t2, output      # Pointer to output buffer
    li $t3, 1000        # Maximum output buffer size

    process_input:
        lb $t4, 0($a0)              # Load a character from the input string
        beqz $t4, end_process_input # Exit loop if end of string is reached

        # Check if the character is a valid character
        li $t5, 47                  # ASCII value of '/'
        li $t6, 122                 # ASCII value of 'z'
        ble $t4, $t5, is_not_valid_char
        bgt $t4, $t6, is_not_valid_char

        # Push the character to the stack
        sb $t4, ($t1)               # Store the character on the stack
        addi $t1, $t1, 1            # Move stack pointer to next position

        is_not_valid_char:
            addi $a0, $a0, 1        # Move to next character in the input string
            j process_input

    end_process_input:
        # Process the stack to calculate the sums
        li $t1, 0                   # Initialize sum to 0
        li $t4, 10                  # ASCII value of 'a'/'A'
        li $t5, 26                  # Base (N)
        add $t6, $t5, $s1           # Calculate ASCII value of 't'/'T' (β/Δ)
        li $t7, 96                  # ASCII value of 'a' - 1

        process_stack:
            sub $t1, $t1, $t7       # Convert character to integer
            addi $t1, $t1, 10       # Adjust for base 10
            ble $t1, $t5, is_digit   # Check if character is a digit

            sub $t1, $t1, $t4       # Adjust for character 'a'/'A'
            ble $t1, $t6, is_alpha   # Check if character is between 'a'/'A' and 't'/'T'

            li $t1, '-'             # Set sum to '-' and exit
            j end_process_stack

            is_digit:
                j next_char

            is_alpha:
                sub $t1, $t1, $t4   # Convert character to integer
                add $t1, $t1, $t5   # Adjust for base N

            next_char:
                j next_char

        end_process_stack:
            # Store the sum in the output buffer
            sb $t1, ($t2)           # Store the sum in the output buffer
            addi $t2, $t2, 1        # Move output buffer pointer to next position
            j process_input

    # Print the output buffer
    li $v0, 4
    la $a0, output
    syscall

    # Exit
    li $v0, 10
    syscall
