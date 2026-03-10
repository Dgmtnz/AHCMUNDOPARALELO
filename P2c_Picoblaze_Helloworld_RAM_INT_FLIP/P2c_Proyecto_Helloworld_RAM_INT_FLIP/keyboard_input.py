#!/usr/bin/env python3
"""
Script de entrada de teclado para el simulador de terminal RS-232
Cifrador César con verificación CRC

Permite enviar caracteres al testbench de Verilog a través del archivo teclas.txt

Uso:
    python keyboard_input.py

Funcionamiento:
    1. El usuario presiona una tecla
    2. El script escribe "1 XX" en teclas.txt (donde XX es el código hex)
    3. Espera 3 segundos
    4. Escribe "0 00" para volver al estado idle
    5. Repite

Comandos especiales:
    q o Ctrl+C: Salir del programa
"""

import sys
import time
import os

# Path del archivo de teclas (relativo al directorio del script)
TECLAS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "teclas.txt")

def write_key(char_hex):
    """Escribe el comando de tecla en el archivo"""
    with open(TECLAS_FILE, 'w') as f:
        f.write(f"1 {char_hex:02X}\n")
    print(f"  Enviado: '{chr(char_hex) if 32 <= char_hex <= 126 else '?'}' (0x{char_hex:02X})")

def write_idle():
    """Escribe el estado idle en el archivo"""
    with open(TECLAS_FILE, 'w') as f:
        f.write("0 00\n")

def get_single_char():
    """Lee un solo carácter del teclado sin esperar Enter"""
    try:
        # Para sistemas Unix/Linux
        import tty
        import termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch
    except ImportError:
        # Para Windows
        import msvcrt
        return msvcrt.getch().decode('utf-8', errors='ignore')

def main():
    print("=" * 60)
    print(" SIMULADOR DE TECLADO RS-232")
    print(" Cifrador César con verificación CRC")
    print("=" * 60)
    print()
    print("Presiona cualquier tecla para enviarla al FPGA.")
    print("Presiona 'q' o Ctrl+C para salir.")
    print()
    print(f"Archivo de teclas: {TECLAS_FILE}")
    print()
    
    # Inicializar archivo en estado idle
    write_idle()
    print("Listo. Esperando entrada...")
    print("-" * 60)
    
    try:
        while True:
            # Leer una tecla
            char = get_single_char()
            
            # Verificar si es comando de salida
            if char == 'q' or char == '\x03':  # 'q' o Ctrl+C
                print("\nSaliendo...")
                break
            
            # Obtener código ASCII
            char_code = ord(char)
            
            # Escribir la tecla
            write_key(char_code)
            
            # Esperar 3 segundos
            print("  Esperando 3 segundos...")
            time.sleep(3)
            
            # Volver a idle
            write_idle()
            print("  Vuelto a idle. Listo para siguiente tecla.")
            print("-" * 40)
            
    except KeyboardInterrupt:
        print("\nInterrumpido por el usuario.")
    finally:
        # Asegurar que el archivo queda en estado idle
        write_idle()
        print("Archivo de teclas restaurado a idle.")

if __name__ == "__main__":
    main()

