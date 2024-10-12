.data
node_size:      .word 8          # Size of each node (4 bytes for data + 4 bytes for pointer)
data_size:      .word 4          # Size of the data field (4 bytes)
pointer_size:   .word 4          # Size of the pointer field (4 bytes)
newline:        .asciiz "\n"    # Newline character for printing
prompt_push:    .asciiz "Enter the value to push onto the stack: "
prompt_pop:     .asciiz "Popped value: "
menu_prompt:    .asciiz "1. Push\n2. Pop\n3. Peek\n4. Exit\nEnter your choice: "
instructions_prompt: .asciiz " Enter the instructions code to be recursively executed "
empty_stack_msg:    .asciiz "Nothing to pop! stack is empty. \n"
prompt_peek_msg: .asciiz "Nothing to peek! stack is empty. \n"
peeked_element: .asciiz "Peeked element is: "

.text
main:
    # Initialize the stack pointer to null
    li $t0, 0

    # Display menu options
    li $v0, 4           # syscall code for print string
    la $a0, instructions_prompt # load address of the menu prompt
    syscall    
    
    li $v0, 4             # syscall code for print string
    la $a0, newline   # load address of the prompt
    syscall               # print the prompt

menu:
    li $v0, 4           # syscall code for print string
    la $a0, menu_prompt # load address of the menu prompt
    syscall             # print the menu prompt

    # Read user choice
    li $v0, 5           # syscall code for read integer
    syscall             # read integer from input
    move $t1, $v0       # store the user choice in $t1

    # Execute user choice
    # Push operation
    beq $t1, 1, push_operation
    # Pop operation
    beq $t1, 2, pop_operation
    # Print stack
    beq $t1, 3, peek
    # Exit program
    beq $t1, 4, exit_program
    # Invalid choice
    j menu

push_operation:
    # Prompt user to enter value to push
    li $v0, 4             # syscall code for print string
    la $a0, prompt_push   # load address of the prompt
    syscall               # print the prompt

    # Read value from user input
    li $v0, 5             # syscall code for read integer
    syscall               # read integer from input
    move $t2, $v0         # store the value to push in $t2

    # Allocate memory for a new node
    li $v0, 9             # syscall code for sbrk (memory allocation)
    lw $a0, node_size     # Load size of node
    syscall               # perform syscall, address of allocated memory stored in $v0
    move $t3, $v0         # Save the address of the new node in $t3

    # Initialize the new node
    sw $t2, 0($t3)        # store data value at the beginning of the node
    sw $t0, 4($t3)        # store current stack pointer in the new node
    move $t0, $t3         # update stack pointer to point to the new node
    
    j menu

pop_operation:
    # Check if the stack is empty
    beq $t0, $zero, empty_stack # If stack pointer is null, go back to the menu

    # Get value from the top of the stack
    lw $t2, 0($t0)        # Load data value from the top of the stack
    
    li $v0, 4             # syscall code for print string
    la $a0, prompt_pop    # load address of the prompt
    syscall               # print the prompt
    
    li $v0, 1             # syscall code for print integer
    move $a0, $t2         # load value to print
    syscall               # print the value
    
    li $v0, 4             # syscall code for print string
    la $a0, newline   # load address of the prompt
    syscall               # print the prompt

    # Update stack pointer to point to the next node
    lw $t0, 4($t0)        # Load pointer to the next node
    j menu
    
empty_stack:
    li $v0, 4           # syscall code for print string
    la $a0, empty_stack_msg # load address of the menu prompt
    syscall    
    j menu
    
peek:
    # Check if the stack is empty
    beq $t0, $zero, prompt_peek  # If stack pointer is null, stack is empty

    # Print the top element of the stack
    lw $t2, 0($t0)                # Load data value from the top of the stack
    
    li $v0, 4           # syscall code for print string
    la $a0, peeked_element # load address of the menu prompt
    syscall   
    
    li $v0, 1                     # syscall code for print integer
    move $a0, $t2                 # load value to print
    syscall                       # print the value
    
    li $v0, 4                     # syscall code for print string
    la $a0, newline               # load address of the prompt
    syscall                       # print the prompt

    j menu                        # Return to the menu

prompt_peek:
    li $v0, 4           # syscall code for print string
    la $a0, prompt_peek_msg # load address of the menu prompt
    syscall 
    
    j menu

exit_program:
    # Exit program
    li $v0, 10            # syscall code for exit
    syscall
    
    
