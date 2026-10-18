-- 02. Análisis exploratorio distribuido
--
-- Cada consulta se puede ejecutar por separado en la consola de BigQuery.

-- 2.1 Estadísticos generales de la duración de los viajes
SELECT
  COUNT(*)                                        AS total_viajes,
  ROUND(AVG(tripduration), 1)                     AS promedio_seg,
  APPROX_QUANTILES(tripduration, 100)[OFFSET(50)] AS mediana_seg,
  MAX(tripduration)                               AS maximo_seg,
  COUNTIF(tripduration > 86400)                   AS viajes_sobre_24h
FROM `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`;

-- 2.2 Viajes por hora de inicio y tipo de usuario (datos de la Figura 2 del informe).
-- La figura del informe se generó con esta consulta sobre la tabla pública, mientras
-- la tabla optimizada estaba vacía por la incidencia INC-04; ambas fuentes entregan el
-- mismo resultado para este rango.
SELECT
  EXTRACT(HOUR FROM starttime)     AS hora_inicio,
  COUNTIF(usertype = 'Subscriber') AS viajes_abonados,
  COUNTIF(usertype = 'Customer')   AS viajes_ocasionales
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime BETWEEN '2016-01-01' AND '2018-05-31'
  AND tripduration BETWEEN 60 AND 7200
GROUP BY hora_inicio
ORDER BY hora_inicio;

-- 2.3 Viajes y duración promedio por día de la semana (1 = domingo, 7 = sábado)
SELECT
  EXTRACT(DAYOFWEEK FROM starttime) AS dia_semana,
  COUNT(*)                          AS viajes,
  ROUND(AVG(tripduration), 1)       AS promedio_seg
FROM `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`
WHERE anio >= 2016
  AND tripduration BETWEEN 60 AND 7200
GROUP BY dia_semana
ORDER BY dia_semana;

-- 2.4 Duración mediana por tipo de usuario
SELECT
  usertype,
  COUNT(*)                                        AS viajes,
  APPROX_QUANTILES(tripduration, 100)[OFFSET(50)] AS mediana_seg
FROM `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`
WHERE anio >= 2016
  AND tripduration BETWEEN 60 AND 7200
GROUP BY usertype;
