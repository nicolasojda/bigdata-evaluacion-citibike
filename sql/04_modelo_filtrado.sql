-- 04. Modelo con limpieza de valores extremos (iteración 2)
--
-- Cambios respecto de la iteración 1:
--   - Se entrena sobre la tabla optimizada, filtrando por la columna de partición.
--   - Se conservan solo viajes de 60 a 7.200 segundos (1 minuto a 2 horas).
--   - Se agregan la estación de destino, la hora y el día de la semana.
--   - Las estaciones se convierten a STRING para que BigQuery ML las codifique en
--     one-hot; las variables numéricas se estandarizan automáticamente.
--   - Se reserva un 20 % aleatorio de los datos para la evaluación, de modo que
--     ML.EVALUATE mida el desempeño sobre registros no vistos en el entrenamiento.
--   - Se usa una muestra determinística del 10 % de los viajes (FARM_FINGERPRINT).
--     El entrenamiento sobre todos los viajes desde 2016 superó la cuota de 10 GB de
--     almacenamiento del modo sandbox, porque BigQuery ML materializa temporalmente
--     los datos de entrenamiento. La muestra es reproducible: siempre selecciona los
--     mismos viajes.

CREATE OR REPLACE MODEL
  `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion_v2`
OPTIONS (
  model_type = 'linear_reg',
  input_label_cols = ['tripduration'],
  optimize_strategy = 'auto_strategy',
  max_iterations = 20,
  data_split_method = 'random',
  data_split_eval_fraction = 0.2
) AS
SELECT
  tripduration,
  CAST(start_station_id AS STRING)  AS start_station_id,
  CAST(end_station_id AS STRING)    AS end_station_id,
  usertype,
  EXTRACT(HOUR FROM starttime)      AS hora_inicio,
  EXTRACT(DAYOFWEEK FROM starttime) AS dia_semana
FROM `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`
WHERE anio >= 2016
  AND tripduration BETWEEN 60 AND 7200
  AND start_station_id IS NOT NULL
  AND end_station_id IS NOT NULL
  AND usertype IS NOT NULL
  AND MOD(ABS(FARM_FINGERPRINT(
        CONCAT(CAST(starttime AS STRING), '-', CAST(bikeid AS STRING)))), 10) = 0;
