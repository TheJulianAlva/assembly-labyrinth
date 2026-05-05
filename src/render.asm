section .data
    ; Secuencias de escape ANSI
    clear_seq   db 27, "[2J", 27, "[H"  ; \033[2J (limpiar) y \033[H (reset cursor)
    clear_len   equ $ - clear_seq

    newline     db 10                   ; Salto de línea (\n)
    
    entity_char db "@"                  ; Carácter del jugador

section .bss
    ; Buffer temporal para construir la secuencia ANSI de posición
    ; Tamaño suficiente para \033[YYY;XXXH
    ansibuf resb 16

section .text
    global clear_terminal
    global print_map
    global render_entity

; -----------------------------------------------------------------------------
; clear_terminal
; Propósito: Limpia la pantalla y coloca el cursor en (0,0).
; -----------------------------------------------------------------------------
clear_terminal:
    pusha
    
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, clear_seq  ; secuencia ANSI
    mov edx, clear_len
    int 0x80
    
    popa
    ret

; -----------------------------------------------------------------------------
; print_map
; Propósito: Imprime el mapa de 20x10.
; Entradas: EAX = Puntero al mapa.
; -----------------------------------------------------------------------------
print_map:
    pusha
    mov esi, eax        ; ESI apunta a los datos del mapa
    mov ecx, 10         ; 10 filas (MAP_HEIGHT)

.row_loop:
    push ecx            ; Guardamos el contador de filas

    ; Imprimir 20 caracteres (1 fila)
    mov eax, 4
    mov ebx, 1
    mov ecx, esi        ; Puntero a la fila actual
    mov edx, 20         ; 20 columnas (MAP_WIDTH)
    int 0x80

    ; Imprimir salto de línea
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Avanzar el puntero del mapa a la siguiente fila
    add esi, 20

    pop ecx             ; Restaurar el contador
    loop .row_loop      ; Repetir para las 10 filas

    popa
    ret

; -----------------------------------------------------------------------------
; render_entity
; Propósito: Posiciona el cursor en (X, Y) y dibuja el jugador.
; Entradas: EAX = Coordenada X, EBX = Coordenada Y.
; Nota: Las coordenadas de la terminal empiezan en 1, no en 0.
; -----------------------------------------------------------------------------
render_entity:
    pusha
    
    mov ecx, eax        ; Guardar X en ECX
    
    ; Iniciar secuencia ANSI en ansibuf
    mov edi, ansibuf
    mov byte [edi], 27  ; \033
    inc edi
    mov byte [edi], '['
    inc edi
    
    ; Convertir coordenada Y a texto (EBX)
    mov eax, ebx
    inc eax             ; Convertir 0-indexed a 1-indexed para la terminal
    call int_to_ascii
    
    ; Agregar separador ';'
    mov byte [edi], ';'
    inc edi
    
    ; Convertir coordenada X a texto (estaba en ECX)
    mov eax, ecx
    inc eax             ; Convertir 0-indexed a 1-indexed para la terminal
    call int_to_ascii
    
    ; Finalizar secuencia ANSI con 'H'
    mov byte [edi], 'H'
    inc edi
    
    ; Calcular longitud de la secuencia construida
    mov edx, edi
    sub edx, ansibuf    ; EDX = longitud
    
    ; Imprimir secuencia ANSI
    mov eax, 4
    mov ebx, 1
    mov ecx, ansibuf
    int 0x80
    
    ; Imprimir el carácter del jugador ('@')
    mov eax, 4
    mov ebx, 1
    mov ecx, entity_char
    mov edx, 1
    int 0x80
    
    popa
    ret

; -----------------------------------------------------------------------------
; Rutina Interna: int_to_ascii
; Propósito: Convierte un entero en EAX a string ASCII y lo guarda en [EDI].
; Entradas: EAX = Número entero. EDI = Puntero al buffer.
; Salidas: Modifica [EDI] y avanza el puntero EDI.
; -----------------------------------------------------------------------------
int_to_ascii:
    push ebx
    push ecx
    push edx
    
    mov ecx, 10         ; Base 10
    xor ebx, ebx        ; Contador de dígitos (EBX = 0)
    
.div_loop:
    xor edx, edx        ; Limpiar EDX antes de dividir
    div ecx             ; EAX = EDX:EAX / 10, EDX = resto (dígito)
    push edx            ; Guardar el dígito en la pila
    inc ebx             ; Incrementar contador
    test eax, eax       ; ¿Quedan más dígitos?
    jnz .div_loop
    
.pop_loop:
    pop eax             ; Sacar el dígito más significativo
    add al, '0'         ; Convertir a ASCII ('0' = 48)
    mov [edi], al       ; Guardar en el buffer
    inc edi             ; Avanzar el puntero
    dec ebx             ; Decrementar contador
    jnz .pop_loop       ; Continuar hasta vaciar la pila
    
    pop edx
    pop ecx
    pop ebx
    ret
