#!/bin/bash
# -----------------------------------------------------------------
# Paso 1: Obtención de Datos (Tareas 1.2 y 1.3)
# Este script asume que 'data.csv' ya existe en el directorio.
# -----------------------------------------------------------------

# Paso 1.2: Guardar resumen de columnas
echo "Paso 1.2: Creando columns.txt"
csvcut -n data.csv > columns.txt

# Paso 1.3: Extraer muestra aleatoria
echo "Paso 1.3: Creando muestra aleatoria (sample_earthquakes.csv)"
cat data.csv | body shuf | head -n 1001 > sample_earthquakes.csv

echo "Paso 1 completado."
