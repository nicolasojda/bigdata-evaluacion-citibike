-- 03. Modelo base (iteración 1)
--
-- Primer modelo de regresión lineal, entrenado sobre la tabla pública con 100.000
-- registros sin filtrar valores extremos de duración. Su evaluación entregó un R²
-- negativo (-0,2432, incidencia INC-02), lo que motivó la iteración 2 (script 04).
-- Se conserva como registro del proceso; no es necesario volver a ejecutarlo.

CREATE OR REPLACE MODEL
  `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion`
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

-- Evaluación de la iteración 1 sobre la porción reservada automáticamente por
-- BigQuery ML durante el entrenamiento (métricas informadas en el informe)
SELECT *
FROM ML.EVALUATE(
  MODEL `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion`);

-- Evaluación original con 10.000 registros adicionales. Se conserva como registro,
-- pero no es una evaluación fuera de muestra: usa los mismos filtros que el
-- entrenamiento y un LIMIT sin orden, por lo que puede repetir registros vistos.
SELECT *
FROM ML.EVALUATE(
  MODEL `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion`, (
    SELECT
        tripduration,
        start_station_name,
        usertype
    FROM `bigquery-public-data.new_york_citibike.citibike_trips`
    WHERE tripduration IS NOT NULL
      AND start_station_name IS NOT NULL
    LIMIT 10000
));
