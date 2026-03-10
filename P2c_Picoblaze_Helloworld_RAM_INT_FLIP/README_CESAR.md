# Cifrador César con Verificación CRC para PicoBlaze

## Descripción del Proyecto

Este proyecto implementa un sistema de cifrado César con verificación de integridad mediante CRC-8 en el microcontrolador PicoBlaze. El sistema permite:

1. Recibir un carácter por puerto serie RS-232
2. Calcular el CRC-8 del carácter original
3. Cifrar el carácter usando el cifrado César (desplazamiento de 3 posiciones)
4. Mostrar el carácter cifrado
5. Descifrar el carácter con César inverso
6. Calcular el CRC-8 del carácter descifrado
7. Verificar que ambos CRC coinciden (validación de integridad)

## Modificaciones Realizadas

### 1. Nuevas Instrucciones en la ALU del PicoBlaze

Se han añadido dos nuevas instrucciones al juego de instrucciones:

- **CESAR sX, kk**: Cifra el contenido del registro sX sumando el valor kk (módulo 256)
- **CESARINV sX, kk**: Descifra el contenido del registro sX restando el valor kk (módulo 256)

**Código de operación:**
- CESAR: `10011` (0x13)
- CESARINV: `10101` (0x15)

### 2. Periférico CRC-8

Se ha añadido un periférico de hardware que calcula el CRC-8 con polinomio 0x07 (x^8 + x^2 + x + 1).

**Puertos:**
- `0x40` (CRC_DATA): Escribe un byte para actualizar el CRC, lee el valor actual del CRC
- `0x41` (CRC_RESET): Escribe cualquier valor para resetear el CRC a 0x00

### 3. Archivos Modificados/Creados

#### Archivos VHDL:
- `cesar.vhd` - Componente para cifrado/descifrado César (NUEVO)
- `crc.vhd` - Periférico CRC-8 (NUEVO)
- `picoblaze.vhd` - Añadidas instrucciones CESAR y CESARINV
- `register_and_flag_enable.vhd` - Soporte para nueva instrucción
- `toplevel_helloworld_RAM_Int.vhd` - Integración del periférico CRC

#### Compilador:
- `asm(con_comentarios).cpp` - Soporte para instrucciones CESAR y CESARINV

#### Programa:
- `programa_helloworld_int_FLIP.asm` - Rutina de cifrado César con verificación CRC

## Flujo de Ejecución

1. Al arrancar, el sistema muestra un mensaje de bienvenida
2. Habilita las interrupciones y espera entrada del usuario
3. Cuando se recibe un carácter:
   - Muestra: `Orig: X (XX)` - Carácter original y su código hex
   - Muestra: `CRC1: XX` - CRC del carácter original
   - Muestra: `Cifr: Y (YY)` - Carácter cifrado y su código hex
   - Muestra: `Desc: X (XX)` - Carácter descifrado (debe coincidir con original)
   - Muestra: `CRC2: XX` - CRC del carácter descifrado
   - Muestra: `OK!` si los CRC coinciden, `FAIL` si no coinciden

## Ejemplo de Salida

```
* HELLO I'M ALIVE! :-D *
* PRESS ANY KEY TO CONTINUE *

Orig: A (41)
CRC1: 52
Cifr: D (44)
Desc: A (41)
CRC2: 52
OK!
-----
```

## Cómo Ejecutar la Simulación

1. Abrir el proyecto en ISE/Vivado
2. Añadir los archivos cesar.vhd y crc.vhd al proyecto
3. Compilar el programa ASM:
   ```bash
   cd Codigo_fuente
   ./mi_asm_new programa_helloworld_int_FLIP.asm
   ```
4. Copiar el archivo .vhd generado al directorio del proyecto
5. Ejecutar la simulación con el testbench
6. En otra terminal, ejecutar el script de Python:
   ```bash
   cd P2c_Proyecto_Helloworld_RAM_INT_FLIP
   python3 keyboard_input.py
   ```
7. Presionar teclas para enviarlas al simulador

## Estructura de Directorios

```
P2c_Picoblaze_Helloworld_RAM_INT_FLIP/
├── Codigo_fuente/
│   ├── asm(con_comentarios).cpp    # Ensamblador modificado
│   ├── cesar.vhd                   # Componente César
│   ├── crc.vhd                     # Periférico CRC
│   ├── programa_helloworld_int_FLIP.asm
│   └── programa_helloworld_int_FLIP.vhd
├── P2c_Proyecto_Helloworld_RAM_INT_FLIP/
│   ├── cesar.vhd
│   ├── crc.vhd
│   ├── picoblaze.vhd               # Modificado
│   ├── register_and_flag_enable.vhd # Modificado
│   ├── toplevel_helloworld_RAM_Int.vhd # Modificado
│   ├── keyboard_input.py
│   ├── teclas.txt
│   └── ...
└── README_CESAR.md
```

## Autor

Proyecto de prácticas - Arquitecturas de Computadores

