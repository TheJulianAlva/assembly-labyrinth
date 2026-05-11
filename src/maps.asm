%include "constants.inc"

section .data
    ; Mapas hardcoded — usados como fallback si el archivo no existe
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

    map_pointers dd map1, map2, map3

    current_map_idx dd 0

    ; Rutas a los archivos de mapa externos
map_file1 db "maps/map1.txt", 0
map_file2 db "maps/map2.txt", 0
map_file3 db "maps/map3.txt", 0
map_file_ptrs dd map_file1, map_file2, map_file3

section .bss
    file_read_buf  resb MAP_FILE_BUFSIZE   ; buffer de lectura cruda (210 bytes)
    loaded_map     resb MAP_SIZE           ; mapa final sin newlines (200 bytes)
    file_fd        resd 1                  ; descriptor de archivo temporal

section .text
    global get_map_ptr
    global set_map_idx
    global load_map

; -----------------------------------------------------------------------------
; get_map_ptr
; Propósito: Devuelve la dirección del buffer del mapa activo.
; Salidas: EAX = puntero a loaded_map.
; -----------------------------------------------------------------------------
get_map_ptr:
    mov eax, loaded_map
    ret

; -----------------------------------------------------------------------------
; set_map_idx
; Propósito: Cambia el índice del mapa actual.
; Entradas: EAX = nuevo índice (0-2).
; -----------------------------------------------------------------------------
set_map_idx:
    cmp eax, 2
    ja .end
    mov [current_map_idx], eax
.end:
    ret

; -----------------------------------------------------------------------------
; load_map
; Propósito: Carga el mapa actual desde su archivo externo en loaded_map.
;            Si el archivo no puede abrirse, copia el mapa hardcoded.
; Entradas: Ninguna (lee current_map_idx).
; Salidas: Ninguna (modifica loaded_map).
; -----------------------------------------------------------------------------
load_map:
    pusha

    ; Obtener ruta del archivo según el índice actual
    mov eax, [current_map_idx]
    mov ebx, [map_file_ptrs + eax * 4]

    ; sys_open(path, O_RDONLY, 0)
    mov eax, SYS_OPEN
    xor ecx, ecx                    ; O_RDONLY = 0
    xor edx, edx
    int 0x80

    ; Si fd < 0: error — usar fallback hardcoded
    test eax, eax
    js .fallback

    mov [file_fd], eax

    ; sys_read(fd, file_read_buf, MAP_FILE_BUFSIZE)
    mov eax, SYS_READ
    mov ebx, [file_fd]
    mov ecx, file_read_buf
    mov edx, MAP_FILE_BUFSIZE
    int 0x80

    ; sys_close(fd)
    mov eax, SYS_CLOSE
    mov ebx, [file_fd]
    int 0x80

    ; Copiar file_read_buf → loaded_map descartando '\n' y '\r'
    call strip_newlines
    jmp .done

.fallback:
    ; Copiar mapa hardcoded al buffer loaded_map
    mov eax, [current_map_idx]
    mov esi, [map_pointers + eax * 4]
    mov edi, loaded_map
    mov ecx, MAP_SIZE
    rep movsb

.done:
    popa
    ret

; -----------------------------------------------------------------------------
; strip_newlines (privada)
; Propósito: Copia file_read_buf a loaded_map descartando '\n' y '\r'.
; Entradas/Salidas: vía variables globales.
; -----------------------------------------------------------------------------
strip_newlines:
    push esi
    push edi
    push eax
    push ecx
    push edx

    mov esi, file_read_buf
    mov edi, loaded_map
    xor ecx, ecx               ; índice fuente
    xor edx, edx               ; índice destino

.loop:
    cmp ecx, MAP_FILE_BUFSIZE
    jge .done
    cmp edx, MAP_SIZE
    jge .done

    mov al, byte [esi + ecx]
    inc ecx

    cmp al, 0x0A               ; '\n'
    je .loop
    cmp al, 0x0D               ; '\r'
    je .loop

    mov byte [edi + edx], al
    inc edx
    jmp .loop

.done:
    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    ret
