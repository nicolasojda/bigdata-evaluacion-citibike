# Pipeline de Big Data en GCP: NYC Citi Bike

Proyecto de la Evaluación Sumativa 2 de la asignatura Big Data (TI3025), Ingeniería en Informática, INACAP sede Punta Arenas.

Integrantes: Nicolás Ojeda y Benjamín Sotomayor.

## Descripción

El proyecto implementa en Google Cloud Platform un pipeline por lotes sobre el conjunto público de viajes de Citi Bike (`bigquery-public-data.new_york_citibike.citibike_trips`), con más de 50 millones de registros entre 2013 y 2018. El pipeline copia los datos a una tabla propia particionada y agrupada en clústeres, realiza un análisis exploratorio con SQL distribuido y entrena en BigQuery ML un modelo de regresión lineal para estimar la duración de un viaje a partir de las estaciones de origen y destino, el tipo de usuario, la hora y el día de la semana.

La arquitectura completa, la justificación de las decisiones y la interpretación de los resultados se encuentran en el informe técnico entregado junto con este repositorio.

## Estructura del repositorio

```
config/config.yaml                          Parámetros del proyecto, del modelo y orden del pipeline
sql/01_creacion_tabla_optimizada.sql        Ingesta por lotes; tabla particionada por año y clusterizada
sql/02_analisis_exploratorio.sql            Consultas agregadas del análisis descriptivo
sql/03_modelo_base.sql                      Iteración 1 del modelo (sin limpieza de valores extremos)
sql/04_modelo_filtrado.sql                  Iteración 2 del modelo (limpieza y nuevas variables)
sql/05_evaluacion_prediccion.sql            ML.EVALUATE y ejemplo de ML.PREDICT
sql/06_exportacion_parquet.sql              Exportación opcional a Parquet en Cloud Storage
src/pipeline.py                             Ejecuta los scripts en orden con el cliente de BigQuery
notebooks/analisis_exploratorio_y_modelo.ipynb   Análisis exploratorio, gráficos y comparación de modelos
docs/planificacion.md                       Roles, carta Gantt, hitos y bitácora de incidencias
requirements.txt                            Dependencias de Python
```

## Ejecución

Los scripts SQL pueden ejecutarse directamente en la consola de BigQuery, en el orden de su numeración. Para ejecutarlos desde Python:

```
pip install -r requirements.txt
gcloud auth application-default login
python src/pipeline.py --dry-run     # estima los bytes que procesará cada paso
python src/pipeline.py
```

El notebook está pensado para Google Colab: se abre desde GitHub, se autentica con la cuenta del proyecto y se ejecutan las celdas en orden.

## Decisiones técnicas

La tabla `viajes_particionados` se particiona por rango entero del año (`RANGE_BUCKET`) y se agrupa en clústeres por `start_station_id` y `usertype`. Una primera versión se particionó por `DATE(starttime)`, pero el proyecto funciona en el modo sandbox de BigQuery, que hace vencer cada partición de tiempo a los 60 días según su fecha; como los datos son de 2013 a 2018, la tabla quedó vacía. El particionamiento por rango entero no está sujeto a ese vencimiento. Las consultas deben filtrar por la columna `anio` para aprovechar la partición.

El dataset `citibike_optimizada` está en la ubicación multirregional US, la misma del conjunto público, porque BigQuery no permite leer de una ubicación y escribir en otra dentro de la misma consulta.

La iteración 2 del modelo se entrena sobre una muestra determinística del 10 % de los viajes desde 2016, seleccionada con `FARM_FINGERPRINT`. El entrenamiento sobre el total superó la cuota de 10 GB de almacenamiento del sandbox, porque BigQuery ML materializa temporalmente los datos de entrenamiento.

La exportación a Parquet requiere un bucket de Cloud Storage y, por lo tanto, un proyecto con facturación habilitada. En modo sandbox ese paso no se ejecuta y queda marcado como opcional en `config/config.yaml`.

## Resultados del modelo

| Métrica | Iteración 1 | Iteración 2 |
|---|---|---|
| Error absoluto medio (s) | 640.09 | 417.26 |
| Mediana del error absoluto (s) | 354.69 | 317.22 |
| Error cuadrático medio | 41,072,654.35 | 364,728.29 |
| Raíz del error cuadrático medio (s) | 6,408.80 | 603.93 |
| R² | -0.2432 | 0.1640 |

Las métricas corresponden a `ML.EVALUATE` sobre la porción de evaluación reservada por BigQuery ML en cada entrenamiento. La iteración 2 también excluye los valores extremos de su conjunto de evaluación, por lo que la caída del error cuadrático refleja en buena parte esa limpieza; la mediana del error absoluto es la métrica más comparable entre ambas.

La tabla `viajes_particionados` contiene 53,108,721 viajes (julio de 2013 a mayo de 2018, 4.04 GB). El conjunto público no tiene registros entre octubre de 2016 y marzo de 2017.
