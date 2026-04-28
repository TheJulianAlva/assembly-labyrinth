section .data
    ; Definición de las dimensiones del mapa
    global MAP_WIDTH
    global MAP_HEIGHT
    MAP_WIDTH  equ 20
    MAP_HEIGHT equ 10

    ; Mapa 1
map1:
    db "####################"
    db "#.................S#"
    db "#.################.#"
    db "#.#..............#.#"
    db "#.#.############.#.#"
    db "#.#.#..........#.#.#"
    db "#.#.#.########.#.#.#"
    db "#.#.#........#.#.#.#"
    db "#.#.##########.#.#.#"
    db "####################"

    ; Mapa 2
map2:
    db "####################"
    db "#S...............#.#"
    db "################.#.#"
    db "#..............#.#.#"
    db "#.############.#.#.#"
    db "#..........#...#.#.#"
    db "##########.#.###.#.#"
    db "#........#.#.#...#.#"
    db "#.########.#.#.###.#"
    db "####################"

    ; Mapa 3
map3:
    db "####################"
    db "#.......#..........#"
    db "#.#####.#.########.#"
    db "#.#...#.#.#......#.#"
    db "#.#.#.#.#.#.####.#.#"
    db "#.#.#.#...#.#..S.#.#"
    db "#.#.#.#####.#.####.#"
    db "#.#.#.......#......#"
    db "#.#.#########.####.#"
    db "####################"

    ; Arreglo de punteros a los mapas
    map_pointers dd map1, map2, map3

    ; Variable que guarda el índice del mapa actual (0, 1 o 2)
    current_map_idx dd 0

section .text
    global get_map_ptr
    global set_map_idx

; -----------------------------------------------------------------------------
; get_map_ptr
; Propósito: Devuelve la dirección de memoria del mapa actual.
; Entradas: Ninguna.
; Salidas: EAX = Puntero al inicio del mapa actual.
; -----------------------------------------------------------------------------
get_map_ptr:
    push ebx
    
    ; Leer el índice del mapa actual
    mov ebx, [current_map_idx]
    
    ; Obtener el puntero del arreglo map_pointers
    ; Como cada puntero es de 32 bits (4 bytes), multiplicamos el índice por 4
    mov eax, [map_pointers + ebx * 4]
    
    pop ebx
    ret

; -----------------------------------------------------------------------------
; set_map_idx (Opcional, para cambiar de nivel)
; Propósito: Cambia el mapa actual.
; Entradas: EAX = Nuevo índice de mapa (0, 1 o 2).
; Salidas: Ninguna.
; -----------------------------------------------------------------------------
set_map_idx:
    ; Verificar que el índice sea válido (0 <= EAX <= 2)
    cmp eax, 2
    ja .end            ; Si EAX > 2, ignorar la petición
    mov [current_map_idx], eax
.end:
    ret
