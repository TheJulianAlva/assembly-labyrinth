; ── Syscalls (Linux x86_32) ───────────────────────────────────────────────────
SYS_READ          equ 3
SYS_WRITE         equ 4
SYS_IOCTL         equ 54
SYS_GETTIMEOFDAY  equ 78
SYS_EXIT          equ 1

; ── File descriptors ─────────────────────────────────────────────────────────
STDIN             equ 0
STDOUT            equ 1
STDERR            equ 2

; ── Map dimensions ────────────────────────────────────────────────────────────
MAP_WIDTH         equ 20
MAP_HEIGHT        equ 10
MAP_SIZE          equ MAP_WIDTH * MAP_HEIGHT   ; 200 bytes
MAP_COUNT         equ 3

; ── Tile characters (ASCII) ───────────────────────────────────────────────────
TILE_WALL         equ '#'
TILE_FLOOR        equ '_'
TILE_EXIT         equ 'M'
TILE_PLAYER_START equ 'P'
TILE_PLAYER       equ 'O'

; ── Key codes ─────────────────────────────────────────────────────────────────
KEY_W             equ 'W'
KEY_A             equ 'A'
KEY_S             equ 'S'
KEY_D             equ 'D'
KEY_w             equ 'w'
KEY_a             equ 'a'
KEY_s             equ 's'
KEY_d             equ 'd'
KEY_Q             equ 'Q'
KEY_q             equ 'q'
KEY_ESC           equ 0x1B

; ── check_move return values ──────────────────────────────────────────────────
MOVE_BLOCKED      equ 0
MOVE_VALID        equ 1
MOVE_VICTORY      equ 2

; ── Terminal ioctl constants ──────────────────────────────────────────────────
TCGETS            equ 0x5401
TCSETS            equ 0x5402
ICANON            equ 0x0002
ECHO              equ 0x0008
