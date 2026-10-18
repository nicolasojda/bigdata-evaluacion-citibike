-- 05. Evaluación e inferencia del modelo de la iteración 2

-- 5.1 Métricas sobre el 20 % reservado para evaluación
-- (sin segundo argumento, ML.EVALUATE usa la partición de evaluación del entrenamiento)
SELECT
  mean_absolute_error,
  mean_squared_error,
  SQRT(mean_squared_error) AS root_mean_squared_error,
  median_absolute_error,
  r2_score,
  explained_variance
FROM ML.EVALUATE(
  MODEL `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion_v2`);

-- 5.2 Predicción para un viaje de ejemplo: abonado, estación 519 a 492, lunes a las 8:00
SELECT
  predicted_tripduration,
  tripduration AS duracion_real,
  ABS(predicted_tripduration - tripduration) AS diferencia_absoluta
FROM ML.PREDICT(
  MODEL `bigdata-evaluacion-2-511416.citibike_optimizada.modelo_prediccion_duracion_v2`,
  (SELECT
     1200         AS tripduration,
     '519'        AS start_station_id,
     '492'        AS end_station_id,
     'Subscriber' AS usertype,
     8            AS hora_inicio,
     2            AS dia_semana));
