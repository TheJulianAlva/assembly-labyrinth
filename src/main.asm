; ─────────────────────────────────────────────────────────────────────────────
; src/main.asm
; Punto de entrada y bucle principal del juego.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

; ── Símbolos de otros módulos ─────────────────────────────────────────────────
extern get_random_map
extern set_map_idx
extern load_map
extern get_map_ptr

extern scan_player_start
extern check_move

extern init_terminal
extern restore_terminal
extern read_key

extern clear_terminal
extern print_map
extern render_entity

; ── Variables globales compartidas con physics.asm ────────────────────────────
global player_x
global player_y
global current_map_index

section .bss
player_x:           resd 1
player_y:           resd 1
current_map_index:  resd 1

section .data
msg_victoria     db 0x0A, "Felicidades! Completaste el laberinto.", 0x0A
msg_victoria_len equ $ - msg_victoria

section .text
global _start

_start:
    ; Seleccionar mapa aleatorio y activarlo
    call get_random_map        ; EAX = 0 / 1 / 2
    call set_map_idx
    call load_map              ; leer mapa desde archivo externo → loaded_map

    ; Buscar 'P' en el mapa → inicializa player_x, player_y
    call scan_player_start

    ; Activar modo raw (sin eco, sin buffering)
    call init_terminal

.game_loop:
    call clear_terminal

    call get_map_ptr           ; EAX = puntero al mapa activo
    call print_map

    mov eax, [player_x]        ; X (columna)
    mov ebx, [player_y]        ; Y (fila)
    call render_entity

    call read_key              ; AL = tecla ('w','a','s','d','q',ESC)

    ; ── Comprobar salida ──────────────────────────────────────────────────────
    cmp al, 'q'
    je .exit
    cmp al, KEY_ESC
    je .exit

    ; ── Calcular posición tentativa ───────────────────────────────────────────
    mov ebx, [player_x]
    mov ecx, [player_y]

    cmp al, 'w'
    je .move_up
    cmp al, 'a'
    je .move_left
    cmp al, 's'
    je .move_down
    ; else 'd'
    inc ebx
    jmp .do_check

.move_up:
    dec ecx
    jmp .do_check

.move_down:
    inc ecx
    jmp .do_check

.move_left:
    dec ebx

.do_check:
    ; EBX = tentative_x, ECX = tentative_y (preservados por check_move)
    call check_move            ; EAX = MOVE_BLOCKED / MOVE_VALID / MOVE_VICTORY

    cmp eax, MOVE_BLOCKED
    je .game_loop

    cmp eax, MOVE_VICTORY
    je .victory

    ; MOVE_VALID: actualizar posición del jugador
    mov [player_x], ebx
    mov [player_y], ecx
    jmp .game_loop

.victory:
    call restore_terminal
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg_victoria
    mov edx, msg_victoria_len
    int 0x80
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

.exit:
    call restore_terminal
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80
