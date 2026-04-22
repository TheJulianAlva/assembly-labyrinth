# Documento de Requisitos: "assembly-labyrinth"
Lenguaje: NASM x86
## 1. Descripción General del Proyecto
Un videojuego de consola en 2D basado en texto (arte ASCII). El jugador controla un personaje (representado por una letra) que debe navegar a través de un laberinto estático desde una posición de inicio predefinida hasta alcanzar una meta (salida). Para garantizar la rejugabilidad, el juego seleccionará aleatoriamente un diseño de laberinto diferente en cada partida desde un banco de mapas predefinidos. El juego se ejecuta directamente en la terminal de Linux, utilizando el teclado para la entrada de comandos en tiempo real.

## 2. Mecánicas de Juego
* **Perspectiva:** Vista superior (Top-down) en 2D.
* **Controles:** El jugador utilizará las teclas `W` (Arriba), `A` (Izquierda), `S` (Abajo) y `D` (Derecha) para mover al personaje una celda a la vez.
* **Respuesta Inmediata:** El juego debe responder a la pulsación de la tecla de forma instantánea, sin requerir que el jugador presione la tecla "Enter".
* **Obstáculos:** El mapa está delimitado por paredes. El jugador no puede atravesar ni destruir estas paredes.

## 3. Entidades del Juego
* **El Jugador:** Representado por el carácter `O` (u otro símbolo distintivo).
* **Paredes:** Representadas por el carácter `#`. Bloquean el movimiento.
* **Caminos (Suelo):** Representados por espacios en blanco ` `.
* **La Salida (Meta):** Representada por el carácter `S`.

## 4. Condiciones de Victoria y Fin del Juego
* **Victoria:** El juego termina exitosamente cuando la coordenada del Jugador coincide exactamente con la coordenada de la Salida (`S`). En este punto, la pantalla debe limpiarse y mostrar un mensaje de felicitaciones.
* **Derrota:** No hay condición de derrota, enemigos ni límite de tiempo. El jugador puede intentar salir indefinidamente.
* **Salida Manual:** El jugador puede presionar la tecla `Q` (Quit) o `ESC` para cerrar el juego en cualquier momento.

## 5. Requisitos Funcionales
* **RF1 - Banco de Mapas:** El sistema debe contener, codificados en memoria, al menos tres diseños de laberintos diferentes, pero con las mismas dimensiones (Ancho y Alto).
* **RF2 - Renderizado:** El sistema debe limpiar la consola y dibujar el estado actual del mapa y del jugador cada vez que haya un movimiento válido.
* **RF3 - Lectura de Teclado:** El sistema debe capturar la entrada del teclado sin bloquear la terminal permanentemente, procesando un solo carácter por ciclo.
* **RF4 - Detección de Colisiones:** Antes de actualizar la posición del jugador, el sistema debe calcular matemáticamente si la celda de destino contiene una pared (`#`).
    * Si hay pared: El movimiento se anula.
    * Si está vacío: El jugador se mueve a la nueva celda.
* **RF5 - Detección de Meta:** El sistema debe verificar en cada movimiento si el jugador ha pisado la casilla de salida.

## 6. Requisitos No Funcionales
* **RNF1 - Dependencias:** Toda la interacción de E/S (Entrada/Salida) debe hacerse mediante llamadas directas al sistema operativo Linux (`syscalls` como `sys_read` 
    y `sys_write`).
* **RNF2 - Interfaz:** El juego corre exclusivamente en una terminal/consola de texto estándar.

## 7. Flujo de Ejecución Esperado
1.  **Inicialización y Semilla:** Leer el reloj del sistema.
2.  **Selección de Mapa:** Usar el valor del reloj para seleccionar el puntero al mapa correspondiente.
    Establecer la posición inicial de `O` (definida para cada mapa).
3.  **Configuración de Terminal:** Cambiar a modo no canónico y limpiar pantalla.
4.  **Bucle Principal (Game Loop):**
    a. Esperar input del usuario.
    b. Calcular nueva coordenada teórica.
    c. Evaluar regla de colisión con el mapa activo en memoria.
    d. Si es válido, actualizar coordenadas de `O`.
    e. Si es `S`, romper el bucle (Ir a 5).
    f. Limpiar terminal y redibujar. Volver a (a).
5.  **Finalización:** Restaurar modo canónico, imprimir mensaje de victoria y salir.