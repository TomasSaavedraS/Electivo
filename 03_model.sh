#!/bin/bash
# -----------------------------------------------------------------
# Paso 4 (Modelamiento) usando Vowpal Wabbit
# Depende de 'sample_no_missing.csv' (creado por 02_analisis.sh)
# -----------------------------------------------------------------

# Paso 4.1: Preparar datos para VW
echo "Paso 4.1: Preparando datos para VW..."
cat sample_no_missing.csv | tr '[:upper:]' '[:lower:]' | csvcut -C place,net,locationSource,magSource,updated > earthquakes_model.csv
cat earthquakes_model.csv | sed 's/earthquake/1/' | sed 's/explosion/2/' | sed 's/quarry blast/3/' > earthquakes_numeric.csv
csv2vw earthquakes_numeric.csv --label type > earthquakes.vw

# Dividir en Train/Test (Sección 8.3.1)
shuf earthquakes.vw > earthquakes.shuffled.vw
split -d -n r/5 earthquakes.shuffled.vw vw-part-
mv vw-part-00 vw-test.vw
cat vw-part-01 vw-part-02 vw-part-03 vw-part-04 > vw-train.vw
rm vw-part-* earthquakes.shuffled.vw

# Crear archivo para guardar resultados de precisión
echo "Resultados de Modelos VW:" > model_accuracy.txt
echo "--------------------------" >> model_accuracy.txt

# --- Modelo 1: Simple ---
echo "Ejecutando Modelo 1..."
vw -d vw-train.vw -f modelo1.vw --quiet
vw -d vw-test.vw -i modelo1.vw -t -p predictions1.txt --quiet
paste predictions1.txt <(cut -d ' ' -f 1 vw-test.vw) | awk '{ if (int($1 + 0.5) == $2) correct++ } END { print "Modelo 1 (Simple) - Precision: " (correct/NR)*100 "%" }' >> model_accuracy.txt

# --- Modelo 2: Passes=10 ---
echo "Ejecutando Modelo 2..."
vw -d vw-train.vw -f modelo2.vw --passes 10 --cache_file modelo.cache --quiet
vw -d vw-test.vw -i modelo2.vw -t -p predictions2.txt --quiet
paste predictions2.txt <(cut -d ' ' -f 1 vw-test.vw) | awk '{ if (int($1 + 0.5) == $2) correct++ } END { print "Modelo 2 (Passes=10) - Precision: " (correct/NR)*100 "%" }' >> model_accuracy.txt

# --- Modelo 3: Quadratic ---
echo "Ejecutando Modelo 3..."
vw -d vw-train.vw -f modelo3.vw --passes 10 --cache_file modelo.cache --quadratic :: --quiet
vw -d vw-test.vw -i modelo3.vw -t -p predictions3.txt --quiet
paste predictions3.txt <(cut -d ' ' -f 1 vw-test.vw) | awk '{ if (int($1 + 0.5) == $2) correct++ } END { print "Modelo 3 (Passes=10, Quadratic) - Precision: " (correct/NR)*100 "%" }' >> model_accuracy.txt

# --- Modelo 4: Red Neuronal ---
echo "Ejecutando Modelo 4..."
vw -d vw-train.vw -f modelo4.vw --passes 10 --cache_file modelo.cache --nn 3 --quiet
vw -d vw-test.vw -i modelo4.vw -t -p predictions4.txt --quiet
paste predictions4.txt <(cut -d ' ' -f 1 vw-test.vw) | awk '{ if (int($1 + 0.5) == $2) correct++ } END { print "Modelo 4 (Passes=10, NN=3) - Precision: " (correct/NR)*100 "%" }' >> model_accuracy.txt

# --- Modelo 5: L2 ---
echo "Ejecutando Modelo 5..."
vw -d vw-train.vw -f modelo5.vw --passes 10 --cache_file modelo.cache --l2 0.000005 --quiet
vw -d vw-test.vw -i modelo5.vw -t -p predictions5.txt --quiet
paste predictions5.txt <(cut -d ' ' -f 1 vw-test.vw) | awk '{ if (int($1 + 0.5) == $2) correct++ } END { print "Modelo 5 (Passes=10, L2) - Precision: " (correct/NR)*100 "%" }' >> model_accuracy.txt

echo "Paso 4 completado. Resultados en model_accuracy.txt"
