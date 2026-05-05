; utils.asm - Utilidades del sistema 

section .bss
    ; struct timeval { long tv_sec; long tv_usec; } -> 8 bytes en 32-bits
    timeval resb 8 

section .text
    global get_random_map

; Constantes de Linux 
%define SYS_GETTIMEOFDAY 78

; get_random_map: Devuelve un número (0, 1 o 2) en el registro EAX.
get_random_map:
    push ebx
    push ecx
    push edx

    ; Llamada a sys_gettimeofday
    mov eax, SYS_GETTIMEOFDAY
    mov ebx, timeval        ; Arg 1: Puntero a estructura timeval
    xor ecx, ecx            ; Arg 2: Puntero a timezone (NULL)
    int 0x80

    ; Obtener tv_usec (microsegundos, están en el offset 4 de la estructura)
    mov eax, dword [timeval + 4]

    ; Realizar la operación módulo 3: eax = eax % 3
    xor edx, edx            ; Limpiar EDX antes de DIV
    mov ecx, 3
    div ecx                 ; EDX:EAX / 3 -> Cociente en EAX, Residuo en EDX
    
    mov eax, edx            ; Mover el residuo (0, 1, o 2) a EAX como valor de retorno

    pop edx
    pop ecx
    pop ebx
    ret