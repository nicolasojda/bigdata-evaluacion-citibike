# bigdata-evaluacion-citibike


# Proyecto Big Data: Pipeline y Modelado Predictivo en GCP (NYC CitiBike)

Repositorio oficial para la evaluación del proyecto de Big Data utilizando Google Cloud Platform (GCP) y BigQuery ML.
## 👥 Integrantes
* **Nicolás Ojeda**
* **Benjamín Sotomayor**

## 🏗️ Descripción del Proyecto
Este proyecto implementa una arquitectura de Big Data de 4 capas (Ingesta, Almacenamiento, Procesamiento y ML/Analytics) utilizando el dataset público de NYC CitiBike en BigQuery (`bigquery-public-data.new_york_citibike.citibike_trips`). Incluye la optimización de datos mediante particionamiento y el entrenamiento/evaluación de un modelo de regresión lineal con BigQuery ML para predecir la duración de los viajes.

## ⚙️ Tecnologías Utilizadas
* **Google Cloud Platform (GCP)**
* **Google BigQuery & BigQuery ML**
* **SQL Estándar**

## 📂 Contenido del Repositorio
* `sql/`: Contiene los scripts SQL ejecutados en la consola de BigQuery para la preparación de datos, entrenamiento del modelo (`modelo_prediccion_duracion`) y evaluación de métricas (MAE, MSE, $R^2$).
