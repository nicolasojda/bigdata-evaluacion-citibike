-- 06. Exportación de la tabla optimizada a Parquet en Cloud Storage (opcional)
--
-- Requiere un bucket de Cloud Storage, y crear un bucket exige un proyecto con
-- facturación habilitada (por ejemplo, la prueba gratuita de GCP). En el modo
-- sandbox este paso no puede ejecutarse; el script queda preparado para cuando el
-- proyecto salga de ese modo.
--
-- Antes de ejecutarlo, crear el bucket en la ubicación US y ajustar el nombre en uri.

EXPORT DATA OPTIONS (
  uri = 'gs://bigdata-citibike-511416/citibike/parquet/*.parquet',
  format = 'PARQUET',
  compression = 'SNAPPY',
  overwrite = true
) AS
SELECT *
FROM `bigdata-evaluacion-2-511416.citibike_optimizada.viajes_particionados`;
