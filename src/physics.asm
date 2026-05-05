; ─────────────────────────────────────────────────────────────────────────────
; src/physics.asm
; Detección de colisiones, posición inicial y condición de victoria.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

extern player_x
extern player_y
extern get_map_ptr

global scan_player_start
global check_move

section .text

; -----------------------------------------------------------------------------
; scan_player_start
; Propósito: Busca 'P' en el mapa actual, guarda sus coordenadas en
;            player_x / player_y, y reemplaza 'P' con TILE_FLOOR.
; Entradas: Ninguna (usa get_map_ptr internamente).
; Salidas: Ninguna (modifica player_x y player_y en memoria).
; -----------------------------------------------------------------------------
scan_player_start:
    pusha

    call get_map_ptr        ; EAX = puntero base del mapa
    mov esi, eax            ; ESI = base del mapa
    xor ecx, ecx            ; ECX = índice lineal (0..MAP_SIZE-1)

.scan_loop:
    cmp ecx, MAP_SIZE
    jge .done               ; 'P' no encontrado, salir sin cambios

    mov al, byte [esi + ecx]
    cmp al, TILE_PLAYER_START
    je .found

    inc ecx
    jmp .scan_loop

.found:
    ; Reemplazar 'P' con suelo transitable
    mov byte [esi + ecx], TILE_FLOOR

    ; player_y = índice / MAP_WIDTH  (fila)
    ; player_x = índice % MAP_WIDTH  (columna)
    mov eax, ecx
    xor edx, edx
    mov ebx, MAP_WIDTH
    div ebx                 ; EAX = fila, EDX = columna
    mov [player_y], eax
    mov [player_x], edx

.done:
    popa
    ret

; -----------------------------------------------------------------------------
; check_move
; Propósito: Evalúa si la posición (new_x, new_y) es transitable.
; Entradas: EBX = new_x, ECX = new_y.
; Salidas:  EAX = MOVE_BLOCKED (0), MOVE_VALID (1) o MOVE_VICTORY (2).
; -----------------------------------------------------------------------------
check_move:
    push esi
    push ebx
    push ecx
    push edx

    ; offset = new_y * MAP_WIDTH + new_x
    mov eax, ecx
    imul eax, MAP_WIDTH
    add eax, ebx

    push eax                ; guardar offset
    call get_map_ptr        ; EAX = puntero base del mapa
    mov esi, eax
    pop eax                 ; EAX = offset

    movzx eax, byte [esi + eax]

    cmp al, TILE_WALL
    je .blocked

    cmp al, TILE_EXIT
    je .victory

    mov eax, MOVE_VALID
    jmp .done

.blocked:
    mov eax, MOVE_BLOCKED
    jmp .done

.victory:
    mov eax, MOVE_VICTORY

.done:
    pop edx
    pop ecx
    pop ebx
    pop esi
    ret
