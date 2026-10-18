"""Ejecuta en orden los scripts SQL del pipeline sobre BigQuery.

Uso:
    python src/pipeline.py                 # ejecuta los pasos obligatorios
    python src/pipeline.py --dry-run       # solo estima los bytes que procesaría cada paso
    python src/pipeline.py --incluir-opcionales

Requiere credenciales de Google Cloud, por ejemplo con:
    gcloud auth application-default login
"""

import argparse
import sys
import time
from pathlib import Path

import yaml
from google.cloud import bigquery

RAIZ = Path(__file__).resolve().parent.parent


def cargar_config(ruta):
    with open(ruta, encoding="utf-8") as f:
        return yaml.safe_load(f)


def formato_bytes(n):
    for unidad in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024:
            return f"{n:.1f} {unidad}"
        n /= 1024
    return f"{n:.1f} PB"


def ejecutar_paso(cliente, paso, location, dry_run):
    sql = (RAIZ / paso["archivo"]).read_text(encoding="utf-8")
    config = bigquery.QueryJobConfig(dry_run=dry_run, use_query_cache=False)
    inicio = time.time()
    trabajo = cliente.query(sql, job_config=config, location=location)
    if dry_run:
        print(f"  estimación: {formato_bytes(trabajo.total_bytes_processed or 0)}")
        return
    filas = list(trabajo.result())
    print(f"  procesado: {formato_bytes(trabajo.total_bytes_processed or 0)}"
          f" en {time.time() - inicio:.0f} s")
    # En scripts con varias sentencias, result() devuelve la última consulta
    for fila in filas[:10]:
        print("   ", dict(fila))


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--config", default=str(RAIZ / "config" / "config.yaml"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--incluir-opcionales", action="store_true")
    args = parser.parse_args()

    cfg = cargar_config(args.config)
    cliente = bigquery.Client(project=cfg["gcp"]["project_id"])
    location = cfg["gcp"]["location"]

    for i, paso in enumerate(cfg["pipeline"], start=1):
        if paso.get("opcional") and not args.incluir_opcionales:
            print(f"[{i}] {paso['descripcion']}: omitido (opcional)")
            continue
        print(f"[{i}] {paso['descripcion']} ({paso['archivo']})")
        try:
            ejecutar_paso(cliente, paso, location, args.dry_run)
        except Exception as error:  # se detiene para no ejecutar pasos dependientes
            print(f"  error: {error}")
            sys.exit(1)


if __name__ == "__main__":
    main()
