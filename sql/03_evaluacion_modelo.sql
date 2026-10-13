-- Evaluación del modelo de Machine Learning y extracción de métricas
SELECT *
FROM ML.EVALUATE(MODEL `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion`, (
    SELECT 
        tripduration,
        start_station_name,
        usertype
    FROM `bigquery-public-data.new_york_citibike.citibike_trips`
    WHERE tripduration IS NOT NULL 
      AND start_station_name IS NOT NULL
    LIMIT 10000
));