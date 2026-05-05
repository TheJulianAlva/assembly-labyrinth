# Documento de Arquitectura: "assembly-Labyrinth"

Este documento define la estructura del repositorio y la arquitectura técnica general de un proyecto modular en Assembly x86_32.

---

## 1. Estructura del Repositorio

Esta es la estructura recomendada para el repositorio:

```text
assembly-Labyrinth/
├── src/
│   ├── main.asm         # Punto de entrada (_start). Lógica del Game Loop.
│   ├── render.asm       # Subrutinas de dibujo (clear_screen, draw_map, draw_player).
│   ├── input.asm        # Manejo de termios y lectura de teclado.
│   ├── physics.asm      # Lógica de colisiones y búsqueda del punto de inicio.
│   ├── maps.asm         # Sección .data exclusiva con los bancos de mapas.
│   └── utils.asm        # Utilidades (generador random, impresión de strings).
├── include/
│   └── constants.inc    # Archivo de macros y constantes globales (MAP_WIDTH, SYS_READ).
├── build/               # Carpeta para archivos objeto (.o) y el ejecutable.
├── docs/                # Documentación.
├── Makefile             # Automatización de la compilación y enlazado.
└── README.md
```

---

## 2. División del Trabajo

Para evitar bloquearse mutuamente, el equipo debe dividir el desarrollo 
basado en los módulos definidos arriba.

### Integrante 1: "El Arquitecto" (Módulos: `main.asm`, `Makefile`)
* **Rol:** Es responsable de unir todas las piezas.
* **Tareas:**
  * Crear el `Makefile` para compilar y enlazar todos los archivos en un solo ejecutable.
  * Diseñar el flujo principal en `main.asm`.
  * Llamar a las subrutinas creadas por el resto del equipo en el orden correcto 
    (Inicializar -> Dibujar -> Leer -> Actualizar).
  * Definir las macros del sistema en `constants.inc`.

### Integrante 2: "El Diseñador Gráfico" (Módulos: `render.asm`, `maps.asm`)
* **Rol:** Controla todo lo que el usuario ve en la pantalla.
* **Tareas:**
  * Diseñar al menos 3 mapas diferentes asegurando dimensiones consistentes.
  * Programar las rutinas para limpiar la pantalla (ANSI codes).
  * Programar la subrutina que itera sobre la memoria del mapa activo y la 
    imprime en pantalla usando `sys_write`.
  * Dibujar al jugador encima del mapa usando posicionamiento del cursor ANSI.

### Integrante 3: "El Físico" (Módulos: `physics.asm`)
* **Rol:** Controla el estado y las matemáticas del juego.
* **Tareas:**
  * Implementar `physics.asm` como la capa que decide si un paso es posible.
  * Programar la subrutina de inicialización `find_player_start` que recorra el mapa en memoria al inicio de la partida: buscar el carácter de inicio (`P`), guardar su posición en variables globales `player_x` y `player_y`, y reemplazar `P` por el carácter de piso (`.`) o espacio libre.
  * Definir una función auxiliar `coord_to_offset` que calcule el índice en el buffer del mapa con la fórmula `Y * MAP_WIDTH + X` usando la constante `MAP_WIDTH` de `constants.inc`.
  * Crear una subrutina `check_move` que reciba coordenadas tentativas en registros acordados (por ejemplo, `EBX = X`, `ECX = Y`) y lea el carácter del mapa en esa posición.
    - Si el destino es pared (`#`), retornar `0` en `EAX`.
    - Si el destino es piso (`.`) o espacio libre, retornar `1`.
    - Si el destino es salida/puerta (`E`), retornar `2`.
  * Implementar una rutina `apply_move` o `try_move` que combine la lógica de colisión con el avance de `player_x`/`player_y` cuando `check_move` devuelve válido.
  * Manejar la conversión entre coordenadas de juego y offset lineal siempre dentro de `physics.asm`, manteniendo a los demás módulos ajenos al detalle de la memoria del mapa.
  * Preservar registros en cada subrutina: usar `push`/`pop` para `EBX`, `ECX`, `EDX` si son modificados, y devolver resultados en `EAX`.
  * Documentar en el código las convenciones de entrada/salida de las subrutinas para que `main.asm` y `render.asm` puedan integrarlas sin confusión.

### Integrante 4: "El Ingeniero de Sistemas" (Módulos: `input.asm`, `utils.asm`)
* **Rol:** Se encarga de la interfaz de bajo nivel con el Sistema Operativo.
* **Tareas:**
  * Investigar e implementar las complejas llamadas al sistema (`ioctl`) 
    necesarias para desactivar el modo canónico (buffer) del teclado en la terminal de Linux.
  * Crear la rutina `read_key` que espere limpiamente una pulsación `WASD`.
  * Implementar una rutina básica (o semi-aleatoria basada en el reloj del sistema 
    `sys_gettimeofday`) para devolver un número entre 0 y 2 que decida qué mapa cargar.

---

## 3. Flujo de Comunicación (Archivos `.inc` y registros)

El mayor reto de programar en equipo en Assembly es saber qué registro está usando 
tu compañero. Si el Integrante 3 usa `EAX` para una suma y el Integrante 2 llama a 
`sys_write` (que destruye `EAX`), el programa fallará catastróficamente.

**Reglas de Oro del Equipo:**
1. **Preservación del Contexto:** Toda subrutina desarrollada debe empujar 
   (`push`) a la pila todos los registros que modifique, y sacarlos (`pop`) 
   al final, excepto el registro usado para retornar el resultado.
   ```assembly
   ; Ejemplo de buena práctica
   mi_subrutina:
       push ebx
       push ecx
       ; ... código que usa ebx y ecx ...
       pop ecx
       pop ebx
       ret
   ```
2. **Convención C (cdecl):** Acordar qué registros se usarán para pasar parámetros 
   a las subrutinas. Se recomienda usar el estándar de Linux x86-32:
   `EBX` (Param 1), `ECX` (Param 2), `EDX` (Param 3).
3. **Uso de `.inc`:** Las constantes globales (como `SYS_WRITE equ 4`) deben 
   estar definidas en `constants.inc` e incluidas (`%include`) en los archivos 
   necesarios para evitar "números mágicos" regados por el código.

---
