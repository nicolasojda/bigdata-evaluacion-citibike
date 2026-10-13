-- Creación de la tabla optimizada y particionada por fecha de inicio
CREATE OR REPLACE TABLE `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`
PARTITION BY DATE(starttime)
AS
SELECT 
    tripduration,
    starttime,
    stoptime,
    start_station_id,
    start_station_name,
    end_station_id,
    end_station_name,
    bikeid,
    usertype,
    birth_year,
    gender
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE starttime IS NOT NULL;