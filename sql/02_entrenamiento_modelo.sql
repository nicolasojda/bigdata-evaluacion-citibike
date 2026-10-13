-- Entrenamiento del modelo predictivo de duración de viajes (Regresión Lineal)
CREATE OR REPLACE MODEL `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion`
OPTIONS(
    model_type='linear_reg',
    input_label_cols=['tripduration']
) AS
SELECT 
    tripduration,
    start_station_name,
    usertype
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE tripduration IS NOT NULL 
  AND start_station_name IS NOT NULL
LIMIT 100000;