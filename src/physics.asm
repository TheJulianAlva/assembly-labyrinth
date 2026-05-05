; ─────────────────────────────────────────────────────────────────────────────
; src/physics.asm
; Lógica de físicas del juego: búsqueda del inicio, cálculo de coordenadas y
; validación de movimientos.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

global find_player_start
global coord_to_offset
global check_move
global try_move

extern player_x
extern player_y
extern current_map_index
extern map_data

section .text

; -----------------------------------------------------------------------------
; find_player_start
;  Busca el carácter de inicio (`P`) dentro del mapa activo, guarda su
;  posición en `player_x` / `player_y` y reemplaza el carácter de inicio por
;  piso libre (`TILE_FLOOR`).
;  Retorna EAX = 1 si se encontró el inicio, EAX = 0 si no se encontró.
;  Convención: usa registros EBX/ECX/EDX/ESI/EDI como temporales.
; -----------------------------------------------------------------------------
find_player_start:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Calcular base del mapa activo: map_data + current_map_index * MAP_SIZE
    mov esi, [current_map_index]
    imul esi, esi, MAP_SIZE
    mov edi, map_data
    add edi, esi

    xor ebx, ebx          ; offset dentro del mapa
    mov ecx, MAP_SIZE     ; cantidad de tiles a revisar

.find_loop:
    mov al, byte [edi + ebx]
    cmp al, TILE_PLAYER_START
    jne .next_tile

    ; Guardar coordenadas del jugador (Y = offset / MAP_WIDTH, X = offset % MAP_WIDTH)
    mov eax, ebx
    cdq
    mov edx, MAP_WIDTH
    div edx
    mov [player_y], eax
    mov [player_x], edx

    ; Reemplazar el carácter inicial por piso libre
    mov byte [edi + ebx], TILE_FLOOR

    mov eax, 1
    jmp .finish

.next_tile:
    inc ebx
    dec ecx
    jnz .find_loop

    ; Si no se encontró el punto de inicio
    xor eax, eax

.finish:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; -----------------------------------------------------------------------------
; coord_to_offset
;  Convierte coordenadas de juego (X, Y) a un índice lineal dentro del mapa.
;  Entrada: EBX = X, ECX = Y
;  Salida: EAX = offset
; -----------------------------------------------------------------------------
coord_to_offset:
    push ebx
    push ecx
    push edx

    mov eax, ecx
    imul eax, eax, MAP_WIDTH
    add eax, ebx

    pop edx
    pop ecx
    pop ebx
    ret

; -----------------------------------------------------------------------------
; check_move
;  Valida el movimiento propuesto hacia una posición (X, Y).
;  Entrada: EBX = X, ECX = Y
;  Salida: EAX = MOVE_BLOCKED / MOVE_VALID / MOVE_VICTORY
; -----------------------------------------------------------------------------
check_move:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Validar límites del mapa
    cmp ebx, MAP_WIDTH
    jae .blocked
    cmp ecx, MAP_HEIGHT
    jae .blocked

    ; Offset lineal dentro del mapa
    mov eax, ecx
    imul eax, eax, MAP_WIDTH
    add eax, ebx

    ; Dirección del mapa activo
    mov esi, [current_map_index]
    imul esi, esi, MAP_SIZE
    mov edi, map_data
    add edi, esi

    mov dl, byte [edi + eax]
    cmp dl, TILE_WALL
    je .blocked
    cmp dl, TILE_EXIT
    je .victory

    ; Cualquier otro tile no bloqueante es válido
    mov eax, MOVE_VALID
    jmp .return

.blocked:
    mov eax, MOVE_BLOCKED
    jmp .return

.victory:
    mov eax, MOVE_VICTORY

.return:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; -----------------------------------------------------------------------------
; try_move
;  Intenta aplicar el movimiento hacia (X, Y).
;  Entrada: EBX = X, ECX = Y
;  Salida: EAX = resultado de check_move
;  Si el movimiento es válido, actualiza player_x/player_y.
; -----------------------------------------------------------------------------
try_move:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    call check_move
    cmp eax, MOVE_VALID
    jne .finish_move

    mov [player_x], ebx
    mov [player_y], ecx

.finish_move:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
