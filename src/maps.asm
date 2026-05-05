; ─────────────────────────────────────────────────────────────────────────────
; src/maps.asm
; Bancos de mapas para el juego. Cada mapa tiene exactamente MAP_WIDTH *
; MAP_HEIGHT bytes.
; ─────────────────────────────────────────────────────────────────────────────

%include "constants.inc"

global map_data

section .data
map_data:
    ; Map 0
    db "########################################"
    db "#P"
    times 37 db TILE_FLOOR
    db "#"
    %rep 16
        db "#"
        times 38 db TILE_FLOOR
        db "#"
    %endrep
    db "#"
    times 37 db TILE_FLOOR
    db TILE_EXIT
    db "#"
    db "########################################"

    ; Map 1 (copia simple del mapa 0)
    db "########################################"
    db "#P"
    times 37 db TILE_FLOOR
    db "#"
    %rep 16
        db "#"
        times 38 db TILE_FLOOR
        db "#"
    %endrep
    db "#"
    times 37 db TILE_FLOOR
    db TILE_EXIT
    db "#"
    db "########################################"

    ; Map 2 (copia simple del mapa 0)
    db "########################################"
    db "#P"
    times 37 db TILE_FLOOR
    db "#"
    %rep 16
        db "#"
        times 38 db TILE_FLOOR
        db "#"
    %endrep
    db "#"
    times 37 db TILE_FLOOR
    db TILE_EXIT
    db "#"
    db "########################################"
