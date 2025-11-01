#!/bin/bash
# -----------------------------------------------------------------
# Pasos 2 (Limpieza) y 3 (Análisis y Visualización)
# Este script depende de 'sample_earthquakes.csv'
# -----------------------------------------------------------------

# Paso 2.1: Tratar valores faltantes
echo "Paso 2.1: Eliminando registros incompletos"
cat sample_earthquakes.csv | csvgrep -c mag -i -r "^$" | csvgrep -c magType -i -r "^$" | csvgrep -c nst -i -r "^$" | csvgrep -c gap -i -r "^$" | csvgrep -c dmin -i -r "^$" | csvgrep -c horizontalError -i -r "^$" | csvgrep -c magError -i -r "^$" | csvgrep -c magNst -i -r "^$" > sample_no_missing.csv

# Paso 2.2: Estandarizar y limpiar
echo "Paso 2.2: Creando earthquakes_clean.csv"
cat sample_no_missing.csv | tr '[:upper:]' '[:lower:]' | csvcut -C id,place,net,locationSource,magSource,updated > earthquakes_clean.csv

# Paso 2.3: Estadísticas por magType
echo "Paso 2.3: Generando estadísticas por magType (stats_by_magtype.txt)"
rush run --tidyverse "
    group_by(df, magtype) %>%
    summarise(
        media_mag = mean(mag),
        mediana_mag = median(mag),
        min_mag = min(mag),
        max_mag = max(mag),
        rango_mag = max_mag - min_mag,
        desv_est_mag = sd(mag),
        varianza_mag = var(mag)
    )" earthquakes_clean.csv | csvlook > stats_by_magtype.txt

# Paso 3.1: Crear archivo para 'year'
echo "Paso 3.1: Creando earthquakes_anio.csv"
rush run --tidyverse "mutate(df, year = as.numeric(substr(time, 1, 4)))" earthquakes_clean.csv > earthquakes_anio.csv

# Paso 3: Generar todos los gráficos
echo "Paso 3: Generando gráficos..."
rush plot --x mag --geom histogram --title "Distribucion de Magnitudes Sismicas" earthquakes_anio.csv > hist_magnitud.png
rush plot --x mag --color magtype --geom density --title "Distribucion de Magnitud por Tipo (magType)" earthquakes_anio.csv > dens_mag_por_magtype.png
rush plot --x type --y mag --geom boxplot --title "Magnitud por Tipo de Evento" earthquakes_anio.csv > boxplot_mag_por_type.png
rush plot --x status --y mag --geom boxplot --title "Magnitud por Estado del Evento" earthquakes_anio.csv > boxplot_mag_por_status.png
rush plot --x depth --geom histogram --title "Distribucion de Profundidades Sismicas" earthquakes_anio.csv > hist_profundidad.png
rush plot --x type --y depth --geom boxplot --title "Profundidad por Tipo de Evento" earthquakes_anio.csv > boxplot_prof_por_type.png
rush plot --x depth --color magtype --geom density --title "Distribucion de Profundidad por Tipo (magType)" earthquakes_anio.csv > dens_prof_por_magtype.png
rush plot --x status --y depth --geom boxplot --title "Profundidad por Estado del Evento" earthquakes_anio.csv > boxplot_prof_por_status.png
rush plot --x longitude --y latitude --color mag --geom point --title "Mapa de Sismos por Magnitud" earthquakes_anio.csv > scatter_mapa_mag.png
rush plot --x longitude --y latitude --color type --geom point --title "Mapa de Sismos por Tipo de Evento" earthquakes_anio.csv > scatter_mapa_type.png
rush plot --x longitude --y latitude --color status --geom point --title "Mapa de Sismos por Estado" earthquakes_anio.csv > scatter_mapa_status.png

echo "Pasos 2 y 3 completados."
