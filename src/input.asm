; input.asm - Manejo del teclado y terminal 

section .bss
    orig_termios resb 64    ; Buffer para guardar el estado original de la terminal
    new_termios  resb 64    ; Buffer para el nuevo estado
    char_buf     resb 1     ; Buffer de 1 byte para leer la tecla

section .text
    global init_terminal
    global restore_terminal
    global read_key

; Constantes de Linux x86-32 
%define SYS_READ  3
%define SYS_IOCTL 54
%define STDIN     0
%define TCGETS    0x5401    ; Obtener configuración de terminal
%define TCSETS    0x5402    ; Establecer configuración de terminal

; Bits de la terminal (c_lflag) 
%define ICANON    2         ; Modo canónico
%define ECHO      8         ; Eco de caracteres

; init_terminal: Desactiva el modo canónico y el eco.
init_terminal:
    pusha

    ; 1. Obtener la configuración actual (TCGETS)
    mov eax, SYS_IOCTL
    mov ebx, STDIN
    mov ecx, TCGETS
    mov edx, orig_termios
    int 0x80

    ; 2. Copiar la configuración original a la nueva
    mov esi, orig_termios
    mov edi, new_termios
    mov ecx, 16             ; 16 dwords = 64 bytes
    rep movsd

    ; 3. Modificar la bandera c_lflag (offset 12 en struct termios)
    mov eax, dword [new_termios + 12]
    and eax, 0xFFFFFFF5     
    mov dword [new_termios + 12], eax

    ; 4. Aplicar la nueva configuración (TCSETS)
    mov eax, SYS_IOCTL
    mov ebx, STDIN
    mov ecx, TCSETS
    mov edx, new_termios
    int 0x80

    popa
    ret

; restore_terminal: Vital para no dejar inutilizada la consola al salir.
restore_terminal:
    pusha
    mov eax, SYS_IOCTL
    mov ebx, STDIN
    mov ecx, TCSETS
    mov edx, orig_termios
    int 0x80
    popa
    ret

; read_key: Espera una tecla W, A, S, D (ignora mayúsculas y otras teclas)
; Devuelve el caracter ASCII en el registro AL.
read_key:
.wait_input:
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, char_buf
    mov edx, 1              ; Leer 1 solo byte
    int 0x80

    ; Verificar si hubo error o no se leyó nada
    cmp eax, 1
    jne .wait_input

    mov al, byte [char_buf]

    ; Convertir mayúsculas a minúsculas para simplificar 
    cmp al, 'A'
    jl .check_valid
    cmp al, 'Z'
    jg .check_valid
    add al, 32              ; Sumar 32 convierte 'A' en 'a'

.check_valid:
    ; Validar si es WASD, Q o ESC
    cmp al, 'w'
    je .done
    cmp al, 'a'
    je .done
    cmp al, 's'
    je .done
    cmp al, 'd'
    je .done
    cmp al, 'q'
    je .done
    cmp al, 0x1B ; ESC
    je .done

    ; Si presionan cualquier otra cosa, vuelve a esperar
    jmp .wait_input

.done:
    ret