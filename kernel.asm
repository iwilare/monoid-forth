format pe64 efi
entry main

section ".text" executable readable

struc string [data] {
    common
    local .end
    dq .end - $
    data
    .end:
}

include "uefi.asm"

macro pushr x {
    sub rbp, 8
    mov qword [rbp], x
}

macro popr x {
    mov x, [rbp]
    add rbp, 8
}

macro next {
    lodsq
    jmp qword [rax]
}

last_entry = 0
macro header label, name, immediate {
    local .end
  label#.entry:
    . string db name
    dq last_entry
  label#.content:
    if immediate eq
      db 1
    else
      db 0
    end if
  label:
    last_entry = label#.entry
}

macro forth_asm label, name, immediate {
    next
    header label, name, immediate
    dq $ + 8
}
macro forth_def label, name, immediate {
    header label, name, immediate
    dq forth_def_code
}
macro forth_var label, name, immediate {
    header label, name, immediate
    dq forth_var_code
}

forth_def_code:
    pushr rsi
    lea rsi, [rax + 8]
    next
forth_var_code:
    push qword [rax + 8]
    next

main:
    uefi_initialization
    mov [stack_base], rsp
    mov rsi, main_program
    next

main_program:
    dq QUOTE, '>', PRINT_CHAR
    dq QUOTE, ' ', PRINT_CHAR
    dq REPL
    dq TERMINATE

forth_asm TERMINATE, 'terminate'
    call uefi_terminate
forth_asm RETURN, 'return'
    popr rsi
forth_asm QUOTE, "'"
    lodsq
    push rax
forth_asm EVAL, 'exec'
    pop rax
    jmp qword [rax]
forth_asm BRANCH, 'branch'
    add rsi, [rsi]
forth_asm BRANCH_TRUE, 'branch-true'
    pop rax
    test rax, rax
    mov rax, 8
    cmovnz rax, [rsi]
    add rsi, rax
forth_asm BRANCH_FALSE, 'branch-false'
    pop rax
    test rax, rax
    mov rax, 8
    cmovz rax, [rsi]
    add rsi, rax
; -------------------------------------------
forth_asm X, 'dup'
    push qword [rsp]
forth_asm OVER, 'over'
    push qword [rsp + 8]
forth_asm PICK, 'pick'
    pop rax
    push qword [rsp + 8 * rax]
forth_asm SET_STACK, 'set-stack'
    pop rsp
forth_asm GET_STACK, 'get-stack'
    push rsp
forth_asm STACK_SIZE, 'stack-size'
    mov rax, [stack_base]
    sub rax, rsp
    push rax
forth_asm DROP, 'drop'
    pop rax
forth_asm SWAP, 'swap'
    pop rax
    pop rbx
    push rax
    push rbx
forth_asm PUSHR, '>r'
    pop rax
    pushr rax
forth_asm I, 'i'
    push qword [rbp]
forth_asm POPR, 'r>'
    popr rax
    push rax
; -------------------------------------------
forth_asm ZERO, 'zero'
    push 0
forth_asm GET, '@'
    pop rax
    mov rax, [rax]
    push rax
forth_asm GET_BYTE, '@b'
    pop rax
    movzx rax, byte [rax]
    push rax
forth_asm INC1, '++'
    pop rax
    inc qword [rax]
forth_asm INC8, '++8'
    pop rax
    add qword [rax], 8
forth_asm PUT_BYTE, '!b'
    pop rax
    pop rbx
    mov [rax], bl
forth_asm PUT, '!'
    pop rax
    pop qword [rax]
; -------------------------------------------
forth_asm ADD1, '+1'
    add qword [rsp], 1
forth_asm ADD8, '+8'
    add qword [rsp], 8

macro compare_push j {
    pop rbx
    pop rax
    cmp rax, rbx
    push_condition j
}
macro push_condition j {
    local .true
    j .true
    push 0
    next
  .true:
    push 1
}
macro binary_operation op {
    pop rbx
    pop rax
    op rax, rbx
    push rax
}

forth_asm PLUS, '+'
    binary_operation add
forth_asm MINUS, '-'
    binary_operation sub
forth_asm LOGIC_AND, '&'
    binary_operation and
forth_asm LOGIC_OR, '|'
    binary_operation or
forth_asm LOGIC_NOT, 'not'
    pop rax
    test rax, rax
    push_condition jz
forth_asm LEQ, '<='
    compare_push jle
forth_asm GEQ, '>='
    compare_push jge
forth_asm EQUAL, '='
    compare_push je
; -------------------------------------------
forth_asm STRING_EQUAL, 'string-equal'
    pop rdi
    pop rax
    xchg rax, rsi
    mov rcx, [rsi]
    repe cmpsb
    xchg rax, rsi
    push_condition je
forth_asm STRING_COPY, 'string-copy'
    pop rdi
    pop rax
    xchg rax, rsi
    mov rcx, [rsi]
    rep movsb
    xchg rax, rsi
forth_asm STRING_LENGTH, 'string-length'
    pop rax
    mov rax, [rax]
    sub rax, 8
    push rax
; -------------------------------------------
forth_asm PRINT_INTEGER, '.'
    pop rax
    call uefi_print_integer
forth_asm PRINT_BYTE, 'print-byte'
    pop rax
    call uefi_print_byte
forth_asm PRINT_CHAR, 'print-char'
    pop rax
    call uefi_print_char
forth_asm PRINT_STRING, 'print-string'
    pop rax
    call uefi_print_string
forth_asm READ_CHAR, 'read-char'
    call uefi_read_char
    push rax
forth_asm READ_LINE, 'read-line'
    call uefi_read_line
    lea rax, [uefi_read_line.string + 8]
    mov qword [line_index], rax
forth_asm PARSE_INTEGER, 'parse-integer'
    pop rbx
    mov r8, 10
    xor rax, rax
    mov rcx, [rbx]
    sub rcx, 8
    add rbx, 8
  .repeat:
    movsx r9, byte [rbx]
    sub r9, '0'
    cmp r9, 9
    ja .invalid
    mul r8
    add rax, r9
    inc rbx
    loop .repeat
  .invalid:
    push rax
; -------------------------------------------
forth_asm HERE, 'here'
    push here
forth_asm LAST, 'last'
    push last
forth_asm LINE, 'line'
    push uefi_read_line.string
forth_asm LINE_INDEX, 'line-index'
    push line_index
forth_asm WORD_INDEX, 'word-index'
    push word_index
forth_asm FORTH_STATUS, 'status'
    push forth_status
; --------------------------------------------------------------------------
section ".data" readable writable

forth_def WORD_NOT_FOUND, 'word-not-found'
    dq QUOTE, word_not_found, PRINT_STRING
    dq PRINT_STRING, QUOTE, 0x0A, PRINT_CHAR
    dq RETURN
forth_def COMMA, ','
    dq HERE, GET, PUT
    dq HERE, INC8
forth_def COMMA_BYTE, ',b'
    dq HERE, GET, PUT_BYTE
    dq HERE, INC1
forth_def IS_ZERO, 'zero?'
    dq ZERO, EQUAL, RETURN
forth_def IS_WHITESPACE, 'whitespace?'
    dq X, QUOTE, ' ', EQUAL, SWAP, QUOTE, '\n', EQUAL, LOGIC_OR, RETURN
forth_def IS_VALID_CHARACTER, 'valid-character?'
    dq X, IS_WHITESPACE, LOGIC_NOT, SWAP, IS_ZERO, LOGIC_NOT, LOGIC_AND, RETURN
forth_def IS_NUMBER, 'number?'
    dq ADD8, GET_BYTE, X, QUOTE, '0', GEQ, SWAP, QUOTE, '9', LEQ, LOGIC_AND, RETURN
forth_def PARSE_WORD, 'parse-word'
    dq HERE, GET, ADD8, WORD_INDEX, PUT
  .skip:
    dq LINE_INDEX, GET, GET_BYTE
    dq X, IS_ZERO, BRANCH_TRUE, .end - $
    dq X, IS_WHITESPACE, BRANCH_FALSE, .save_word - $
    dq LINE_INDEX, INC1
    dq BRANCH, .skip - $
  .save_word:
    dq WORD_INDEX, GET, PUT_BYTE
    dq WORD_INDEX, INC1
    dq LINE_INDEX, INC1
    dq LINE_INDEX, GET, GET_BYTE
    dq X, IS_VALID_CHARACTER, BRANCH_TRUE, .save_word - $
  .end:
    dq DROP
    dq WORD_INDEX, GET, HERE, GET, MINUS, HERE, GET, PUT
    dq HERE, GET
    dq RETURN
forth_def FIND, 'find'
    dq LAST, GET
  .repeat:
    dq OVER, OVER, STRING_EQUAL
    dq BRANCH_TRUE, .found - $
    dq X, GET, PLUS, GET
    dq X, BRANCH_TRUE, .repeat - $
    dq DROP, DROP, ZERO, RETURN
  .found:
    dq SWAP, DROP, X, GET, PLUS, ADD8, RETURN
forth_def CREATE, 'create'
    dq HERE, STRING_COPY
    dq LAST
    dq HERE, LAST, PUT
    dq HERE, GET, HERE, PLUS, HERE, PUT
    dq COMMA
    dq ZERO, COMMA_BYTE
    dq RETURN
forth_def INTERPRET_WORD, 'interpret-word'
    dq STACK_SIZE, PRINT_INTEGER
    dq X, IS_NUMBER, BRANCH_TRUE, .number - $

  .word:
    dq X, FIND
    dq X, BRANCH_TRUE, .word_found - $
    dq DROP, WORD_NOT_FOUND, RETURN
  .word_found:
    dq SWAP, DROP
    dq X, ADD1
    dq SWAP, GET_BYTE, FORTH_STATUS, GET, LOGIC_OR
    dq BRANCH_FALSE, .compile_literal - $
    dq EVAL
    dq RETURN

  .number:
    dq PARSE_INTEGER
    dq FORTH_STATUS, GET, BRANCH_FALSE, .end - $
  .compile_number:
    dq QUOTE, QUOTE, COMMA
  .compile_literal:
    dq COMMA
  .end:
    dq RETURN
forth_def INTERPRET_LINE, 'interpret-line'
  .start:
    dq PARSE_WORD
    dq X, STRING_LENGTH, BRANCH_FALSE, .end - $
    dq INTERPRET_WORD
    dq BRANCH, .start - $
  .end:
    dq DROP, RETURN
forth_def REPL, 'repl'
  .main:
    dq READ_LINE
    dq INTERPRET_LINE
    dq BRANCH, .main - $

dictionary          rq 4096

return_stack_space  rq 1024 - 1
return_stack        rq 1

stack_base          rq 1

here                dq dictionary
last                dq last_entry
line_index          dq uefi_read_line.string + 8
word_index          dq dictionary
forth_status        dq 0 ; 0 for interpretation, 1 for compilation

word_not_found      string db "word not found: "
