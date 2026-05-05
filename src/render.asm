; ─────────────────────────────────────────────────────────────────────────────
; src/render.asm
; Renderizado del mapa y entidades con UTF-8 y colores ANSI.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

section .data
    clear_seq       db 27, "[2J", 27, "[H"
    clear_len       equ $ - clear_seq

    newline         db 10

    ; ── Tiles con color ANSI + carácter UTF-8 ────────────────────────────────

    ; Pared (#): █ azul brillante
    tile_wall       db 27, "[94m", 0xE2, 0x96, 0x88, 27, "[0m"
    tile_wall_len   equ $ - tile_wall

    ; Suelo (_): espacio (fondo de terminal)
    tile_floor      db " "
    tile_floor_len  equ $ - tile_floor

    ; Meta (M): ★ amarillo brillante
    tile_meta       db 27, "[93m", 0xE2, 0x98, 0x85, 27, "[0m"
    tile_meta_len   equ $ - tile_meta

    ; Jugador: ▲ cian brillante
    tile_player     db 27, "[96m", 0xE2, 0x96, 0xB2, 27, "[0m"
    tile_player_len equ $ - tile_player

section .bss
    ansibuf resb 16

section .text
    global clear_terminal
    global print_map
    global render_entity

; -----------------------------------------------------------------------------
; clear_terminal
; -----------------------------------------------------------------------------
clear_terminal:
    pusha
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, clear_seq
    mov edx, clear_len
    int 0x80
    popa
    ret

; -----------------------------------------------------------------------------
; print_map
; Propósito: Imprime el mapa tile por tile, traduciendo cada carácter a su
;            representación visual UTF-8 con color.
; Entradas:  EAX = puntero al mapa.
; -----------------------------------------------------------------------------
print_map:
    pusha
    mov esi, eax            ; ESI = puntero al mapa
    mov edi, MAP_HEIGHT     ; EDI = contador de filas

.row_loop:
    mov ebx, MAP_WIDTH      ; EBX = contador de columnas

.col_loop:
    movzx eax, byte [esi]   ; AL = tile actual
    call print_tile         ; imprime el tile (preserva todos los registros)
    inc esi
    dec ebx
    jnz .col_loop

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newline
    mov edx, 1
    int 0x80

    dec edi
    jnz .row_loop

    popa
    ret

; -----------------------------------------------------------------------------
; print_tile  [rutina interna]
; Propósito: Traduce AL a su secuencia UTF-8+color y la escribe en stdout.
; Entradas:  AL = carácter del tile.
; Preserva:  todos los registros (usa pusha/popa).
; -----------------------------------------------------------------------------
print_tile:
    pusha

    cmp al, TILE_WALL
    je .wall
    cmp al, TILE_EXIT
    je .exit_tile

    ; suelo o cualquier otro carácter → espacio
    mov ecx, tile_floor
    mov edx, tile_floor_len
    jmp .do_print

.wall:
    mov ecx, tile_wall
    mov edx, tile_wall_len
    jmp .do_print

.exit_tile:
    mov ecx, tile_meta
    mov edx, tile_meta_len

.do_print:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    int 0x80

    popa
    ret

; -----------------------------------------------------------------------------
; render_entity
; Propósito: Posiciona el cursor en (X, Y) y dibuja el jugador.
; Entradas:  EAX = X (columna), EBX = Y (fila).
; Nota: coordenadas 0-indexed; la terminal usa 1-indexed.
; -----------------------------------------------------------------------------
render_entity:
    pusha

    mov ecx, eax            ; guardar X en ECX

    ; Construir secuencia ANSI \033[Y;XH en ansibuf
    mov edi, ansibuf
    mov byte [edi], 27
    inc edi
    mov byte [edi], '['
    inc edi

    mov eax, ebx
    inc eax                 ; Y: 0-indexed → 1-indexed
    call int_to_ascii

    mov byte [edi], ';'
    inc edi

    mov eax, ecx
    inc eax                 ; X: 0-indexed → 1-indexed
    call int_to_ascii

    mov byte [edi], 'H'
    inc edi

    mov edx, edi
    sub edx, ansibuf        ; longitud de la secuencia

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, ansibuf
    int 0x80

    ; Imprimir el carácter del jugador
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, tile_player
    mov edx, tile_player_len
    int 0x80

    popa
    ret

; -----------------------------------------------------------------------------
; int_to_ascii  [rutina interna]
; Propósito: Convierte EAX (entero) a dígitos ASCII escritos en [EDI].
; Entradas:  EAX = número, EDI = puntero al buffer de destino.
; Salidas:   EDI avanzado al siguiente byte libre.
; -----------------------------------------------------------------------------
int_to_ascii:
    push ebx
    push ecx
    push edx

    mov ecx, 10
    xor ebx, ebx            ; contador de dígitos

.div_loop:
    xor edx, edx
    div ecx                 ; EAX = cociente, EDX = dígito
    push edx
    inc ebx
    test eax, eax
    jnz .div_loop

.pop_loop:
    pop eax
    add al, '0'
    mov [edi], al
    inc edi
    dec ebx
    jnz .pop_loop

    pop edx
    pop ecx
    pop ebx
    ret
