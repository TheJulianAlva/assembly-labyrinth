; ─────────────────────────────────────────────────────────────────────────────
; src/main.asm
; Punto de entrada del juego.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

; ── Globals shared with other modules ─────────────────────────────────────────
global player_x
global player_y
global current_map_index

section .bss

player_x:           resd 1   ; columna actual del jugador
player_y:           resd 1   ; fila actual del jugador
current_map_index:  resd 1   ; índice del mapa activo (0, 1 o 2)

section .data

msg     db "Assembly Labyrinth - OK", 0x0A
msg_len equ $ - msg

section .text

global _start
extern find_player_start
extern try_move

_start:
    ; Selecciona el mapa inicial
    mov dword [current_map_index], 0

    ; Inicializa la posición del jugador desde el mapa
    call find_player_start
    cmp eax, 1
    jne .exit_error

    ; Muestra un mensaje inicial
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    ; Prueba un movimiento hacia la derecha
    mov ebx, [player_x]
    add ebx, 1
    mov ecx, [player_y]
    call try_move

    ; Salir devolviendo el resultado de física en EBX
    mov ebx, eax
    mov eax, SYS_EXIT
    int 0x80

.exit_error:
    mov eax, SYS_EXIT
    mov ebx, 255
    int 0x80
