# Assembly Labyrinth

Videojuego de laberinto en consola escrito íntegramente en **NASM x86-32** para Linux. El jugador navega a través de uno de varios laberintos ASCII seleccionado aleatoriamente, usando WASD para moverse en tiempo real sin presionar Enter. Proyecto académico desarrollado en equipo para la materia de Lenguajes de Interfaz.

---

## Tabla de Contenidos

- [Demostración](#demostración)
- [Requisitos](#requisitos)
- [Compilación y Ejecución](#compilación-y-ejecución)
- [Controles](#controles)
- [Arquitectura del Proyecto](#arquitectura-del-proyecto)
- [Conceptos Técnicos Clave](#conceptos-técnicos-clave)
- [Equipo](#equipo)

---

## Demostración

```
########################################
#O    #          #     #               #
#  #  #  ######  #  #  #####  #######  #
#  #     #       #  #          #       #
#  #######  ######  ###########  #######
#                                      S
########################################
```

El jugador `O` debe alcanzar la salida `S` sin atravesar paredes `#`.

---

## Requisitos

El proyecto compila y ejecuta dentro de un contenedor Docker, por lo que el único requisito en el host es:

| Herramienta | Propósito |
|---|---|
| [Docker](https://www.docker.com/) | Entorno Linux con NASM y GNU Make |

El contenedor `codeneomatrix/nasm` incluye NASM, GNU Binutils y Make preinstalados.

---

## Compilación y Ejecución

### Desde Windows

Ejecuta el script incluido en la raíz del proyecto:

```bat
docker-run.bat
```

Esto monta el proyecto en el contenedor, lo compila y lo ejecuta automáticamente.

### Desde Linux / WSL / dentro del contenedor

```bash
# Compilar
make

# Compilar y ejecutar
make run

# Limpiar artefactos de build
make clean
```

El ejecutable queda en `build/assembly-labyrinth`.

### Iniciar el contenedor manualmente

Si prefieres entrar al contenedor para explorar o depurar:

```bat
docker run --rm -it -v "<RUTA_PROYECTO>\assembly-labyrinth:/code" -w /code codeneomatrix/nasm sh
```

---

## Controles

| Tecla | Acción |
|---|---|
| `W` / `w` | Mover arriba |
| `A` / `a` | Mover izquierda |
| `S` / `s` | Mover abajo |
| `D` / `d` | Mover derecha |
| `Q` / `q` / `ESC` | Salir del juego |

---

## Arquitectura del Proyecto

El código está dividido en módulos independientes. Cada integrante del equipo es responsable de uno o más archivos.

```
assembly-labyrinth/
├── src/
│   ├── main.asm       # _start, game loop principal
│   ├── render.asm     # clear_screen, draw_map, draw_player
│   ├── input.asm      # termios (modo raw), read_key
│   ├── physics.asm    # check_move, escaneo del mapa, colisiones
│   ├── maps.asm       # banco de 3 mapas en .data
│   └── utils.asm      # generador pseudo-random, print_string
├── include/
│   └── constants.inc  # constantes globales y números de syscall
├── build/             # objetos .o y ejecutable (generado por make)
├── docs/              # documentación técnica
└── Makefile
```

### Flujo de Ejecución

```
_start
  │
  ├─► init_random()        → selecciona mapa con sys_gettimeofday
  ├─► set_raw_mode()       → desactiva buffer de teclado vía ioctl
  ├─► scan_player_start()  → encuentra 'P' en el mapa, guarda X/Y
  │
  └─► [Game Loop]
        │
        ├─► draw_map() + draw_player()   → renderiza estado actual
        ├─► read_key()                   → espera una tecla WASD/Q
        ├─► check_move(x, y)             → valida colisión
        │     ├─ MOVE_BLOCKED (0) → no actualiza posición
        │     ├─ MOVE_VALID   (1) → actualiza player_x / player_y
        │     └─ MOVE_VICTORY (2) → rompe el loop
        │
        └─► [si victoria] → restore_terminal() → mensaje → sys_exit
```

---

## Conceptos Técnicos Clave

### Syscalls en x86-32 (Linux)

Toda la E/S se realiza directamente con el kernel mediante la interrupción `int 0x80`. No se usa ninguna librería de C.

```asm
; Ejemplo: sys_write (stdout)
mov eax, 4          ; número de syscall: SYS_WRITE
mov ebx, 1          ; fd: STDOUT
mov ecx, mensaje    ; puntero al buffer
mov edx, longitud   ; bytes a escribir
int 0x80
```

| Syscall | Número | Uso en el proyecto |
|---|---|---|
| `sys_read` | 3 | Leer tecla del jugador |
| `sys_write` | 4 | Dibujar el mapa en pantalla |
| `sys_ioctl` | 54 | Cambiar modo de terminal (termios) |
| `sys_gettimeofday` | 78 | Semilla para selección aleatoria de mapa |
| `sys_exit` | 1 | Terminar el proceso |

### Matemática de Posición en el Mapa

El mapa se almacena como un arreglo lineal de bytes en `.data`. Para acceder a la celda `(X, Y)`:

```
dirección = base_mapa + (Y * MAP_WIDTH) + X
```

Implementado en `physics.asm` como multiplicación entera con `imul`.

### Convención de Llamada Interna

Los módulos se comunican siguiendo cdecl de 32-bit:

| Registro | Rol |
|---|---|
| `eax` | Valor de retorno / número de syscall |
| `ebx` | Argumento 1 |
| `ecx` | Argumento 2 |
| `edx` | Argumento 3 |

Toda subrutina preserva los registros que modifica con `push`/`pop`, salvo el registro de retorno.

---

## Equipo

| Rol | Módulos |
|---|---|
| Arquitectura | `main.asm`, `Makefile`, `constants.inc` |
| Diseño Gráfico | `render.asm`, `maps.asm` |
| Físicas | `physics.asm` |
| Sistema | `input.asm`, `utils.asm` |
