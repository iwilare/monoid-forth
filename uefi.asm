include "uefi_structs.asm"

macro uefi_initialization {
    mov [system_stack_pointer], rsp
    mov [system_table], rdx
}

uefi_terminate:
    mov rsp, [system_stack_pointer]
    ret

uefi_read_char: ; Out: RAX = character read, uses RDX, RCX, R8
    mov rdx, uefi_read_char.input_key
    mov rcx, [system_table]
    mov rcx, [rcx + EFI_SYSTEM_TABLE.ConIn]
    mov rax, [rcx + EFI_SIMPLE_TEXT_INPUT_PROTOCOL.ReadKeyStroke]
    call rax
    mov r8, EFI_NOT_READY
    cmp rax, r8
    je uefi_read_char
    mov ax, word [uefi_read_char.input_key + EFI_INPUT_KEY.UnicodeChar]
    cmp ax, 0x0D
    jne .not_enter
    mov al, 0x0A
  .not_enter:
    ret

uefi_print_string: ; In: RAX = length-prefixed string to print, uses RAX, RDX, RCX, RDI
    push rsi
    push rdi
    mov rsi, rax
    lodsq
    mov rcx, rax
    sub rcx, 8
    mov rdi, uefi_print_string.zero_buffer
  .copy:
    test rcx, rcx
    jz .done
    sub rcx, 1
    lodsb
    cmp al, 0x0A
    jne .no_newline
    stosw
    mov al, 0x0D
  .no_newline:
    stosw
    jmp .copy
  .done:
    mov word [rdi], 0
    mov rdx, uefi_print_string.zero_buffer
    call uefi_print_stringzero
    pop rdi
    pop rsi
    ret

uefi_print_stringzero: ; In: RDX = string to print, uses RCX, RAX
    mov rcx, [system_table]
    mov rcx, [rcx + EFI_SYSTEM_TABLE.ConOut]
    mov rax, [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]
    call rax
    ret

uefi_print_char: ; In: RAX = char to print, uses RAX, RCX, RDX
    mov byte [uefi_print_char.string + 8], al
    mov rax, uefi_print_char.string
    call uefi_print_string
    ret

uefi_print_byte: ; In: RAX = number to print, uses RCX, RDX, R8
    mov r8, rax
    and r8, 0x0F
    mov r8b, byte [hex_table + r8]
    mov word [uefi_print_byte.buffer + 2], r8w
    shr rax, 4
    mov r8, rax
    and r8, 0x0F
    mov r8b, byte [hex_table + r8]
    mov word [uefi_print_byte.buffer], r8w
    mov rdx, uefi_print_byte.buffer
    call uefi_print_stringzero
    ret

uefi_print_hex: ; In: RAX = number to print, uses RCX, RDX, R8
    mov rcx, 16
  .repeat:
    mov r8, rax
    and r8, 0x0F
    mov r8b, [hex_table + r8]
    mov byte [uefi_print_hex.buffer + 2*rcx - 2], r8b
    shr rax, 4
    loop .repeat
    mov rdx, uefi_print_hex.buffer
    call uefi_print_stringzero
    ret

uefi_print_integer: ; In: RAX = integer to print, uses RCX, RDX, R8
    mov r8, 10
    mov rcx, uefi_print_integer.buffer_end
  .repeat:
    sub rcx, 2
    mov rdx, 0
    div r8
    mov dl, [hex_table + rdx]
    mov byte [rcx], dl
    cmp rax, 0
    jg .repeat
    mov rdx, rcx
    call uefi_print_stringzero
    ret

uefi_print_binary: ; In: RAX = number to print, uses RCX, RDX, R8
    mov rcx, 64
  .repeat:
    mov r8, rax
    and r8, 0x1
    add r8, '0'
    mov byte [uefi_print_binary.buffer + 2*rcx - 2], r8b
    shr rax, 1
    loop .repeat
    mov rdx, uefi_print_binary.buffer
    call uefi_print_stringzero
    ret

uefi_read_line: ; In: RDI = output buffer, uses RDX, RCX, R8
    lea rbx, [uefi_read_line.string + 8]
    mov rdi, rbx
  .repeat:
    call uefi_read_char
    cmp rax, 0x08
    jne .no_delete
    cmp rdi, rbx
    jbe .repeat
    dec rdi
    push rax
    call uefi_print_char
    pop rax
    jmp .repeat
  .no_delete:
    push rax
    call uefi_print_char
    pop rax
    cmp rax, 0x0A
    je .end
    stosb
    jmp .repeat
  .end:
    mov byte [rdi], 0x00 ; Null terminate for easier parsing
    sub rdi, uefi_read_line.string
    mov qword [uefi_read_line.string], rdi
    ret

system_table                  rq 1
system_stack_pointer          rq 1
system_final_return           rq 1

hex_table                     db "0123456789ABCDEF"
uefi_print_byte.buffer        rw 2
uefi_print_byte.buffer_end    dw 0x00
uefi_print_hex.buffer         rw 16
uefi_print_hex.buffer_end     dw 0x0D, 0x0A, 0x00
uefi_print_integer.buffer     rw 21
uefi_print_integer.buffer_end dw 0x0D, 0x0A, 0x00
uefi_print_binary.buffer      rw 64
uefi_print_binary.buffer_end  dw 0x0D, 0x0A, 0x00

uefi_print_char.string        string rb 1
uefi_print_string.zero_buffer rw 1024

uefi_read_char.input_key      rw 1
uefi_read_line.string         string rw 1024
