"""Exporta as tabelas do data/berth.duckdb para Parquet em data/powerbi/,
que o Power BI Desktop lê direto (Obter dados > Parquet).

Uso:
    python ingest/export_powerbi.py
"""

from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
DB_PATH = RAIZ / "data" / "berth.duckdb"
SAIDA = RAIZ / "data" / "powerbi"

TABELAS = ["fato_comercio", "dim_data", "dim_ncm", "dim_pais", "dim_porto", "dim_uf"]


def main() -> None:
    SAIDA.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB_PATH), read_only=True)
    for tabela in TABELAS:
        destino = SAIDA / f"{tabela}.parquet"
        con.execute(f"COPY {tabela} TO '{destino.as_posix()}' (FORMAT parquet, COMPRESSION zstd)")
        print(f"  {destino.name:<24} {destino.stat().st_size / 1e6:>8.1f} MB")
    con.close()


if __name__ == "__main__":
    main()
