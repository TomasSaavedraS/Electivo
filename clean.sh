#!/bin/bash
# -----------------------------------------------------------------
# Borra todos los archivos generados por los scripts de análisis.
# -----------------------------------------------------------------

# Borrar archivos CSV generados
rm sample_earthquakes.csv
rm sample_no_missing.csv
rm earthquakes_clean.csv
rm earthquakes_anio.csv
rm earthquakes_model.csv
rm earthquakes_numeric.csv

#Borra archivos de texto (txt)
rm columns.txt
rm stats_by_magtype.txt
rm model_accuracy.txt

# Borra todos los gráficos
rm *.png

# Borra todos los archivos de VW
rm *.vw
rm *.cache
rm predictions*.txt

echo "Directorio limpiado."
