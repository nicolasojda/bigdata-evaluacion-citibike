-- 01. Ingesta por lotes y creación de la tabla optimizada
--
-- Copia los viajes desde el conjunto público hacia el dataset del proyecto.
-- La tabla se particiona por rango entero del año y se agrupa en clústeres por
-- estación de origen y tipo de usuario.
--
-- Historial: la primera versión de esta tabla se particionaba por DATE(starttime).
-- En el modo sandbox de BigQuery cada partición de tiempo vence a los 60 días según
-- su fecha, y como los viajes son de 2013 a 2018, todas las particiones vencieron y
-- la tabla quedó vacía (incidencia INC-04). El particionamiento por rango entero no
-- está sujeto a ese vencimiento.
--
-- Para que las consultas aprovechen la partición deben filtrar por la columna anio.
--
-- BigQuery no permite reemplazar una tabla cambiando su tipo de partición, por eso
-- se elimina primero la versión anterior.

DROP TABLE IF EXISTS `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`;

CREATE OR REPLACE TABLE `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`
PARTITION BY RANGE_BUCKET(anio, GENERATE_ARRAY(2013, 2019, 1))
CLUSTER BY start_station_id, usertype
AS
SELECT
  EXTRACT(YEAR FROM starttime) AS anio,
  tripduration,
  starttime,
  stoptime,
  start_station_id,
  end_station_id,
  bikeid,
  usertype,
  birth_year,
  gender
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime IS NOT NULL;

-- Verificación de la carga
SELECT
  anio,
  COUNT(*)          AS viajes,
  MIN(starttime)    AS desde,
  MAX(starttime)    AS hasta
FROM `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`
GROUP BY anio
ORDER BY anio;
