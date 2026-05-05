section .data
    ; Mapa 1 — P en (5,5), M en (18,1)
map1:
    db "####################"
    db "#_________________M#"
    db "#_################_#"
    db "#_#______________#_#"
    db "#_#_############_#_#"
    db "#_#_#P_________#_#_#"
    db "#_#_#_########_#_#_#"
    db "#_#_#________#_#_#_#"
    db "#___##########___#_#"
    db "####################"

    ; Mapa 2 — P en (1,5), M en (1,1)
map2:
    db "####################"
    db "#M_______________#_#"
    db "################_#_#"
    db "#______________#_#_#"
    db "#_############_#_#_#"
    db "#P_________#___#_#_#"
    db "##########_#_###_#_#"
    db "#________#_#_#___#_#"
    db "#_########_____###_#"
    db "####################"

    ; Mapa 3 — P en (1,8), M en (15,5)
map3:
    db "####################"
    db "#_______#__________#"
    db "#_#####_#_########_#"
    db "#_#___#_#_#______#_#"
    db "#_#_#_#_#_#_####_#_#"
    db "#_#_#_#___#_#__M_#_#"
    db "#_#_#_#####_#_####_#"
    db "#_#_#_______#______#"
    db "#P__#########_####_#"
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
    ja .end ; Si EAX > 2, ignorar la petición
    mov [current_map_idx], eax
.end:
    ret
