; ─────────────────────────────────────────────────────────────────────────────
; src/main.asm
; Punto de entrada del juego.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

; ── Globales compartidas con otros módulos ────────────────────────────────────
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
_start:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80
