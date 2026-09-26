"""Monta data/berth.duckdb executando os arquivos de sql/ em ordem.

Uso:
    python ingest/build_db.py
"""

import os
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
DB_PATH = RAIZ / "data" / "berth.duckdb"


def main() -> None:
    # os caminhos nos .sql são relativos à raiz do projeto
    os.chdir(RAIZ)
    con = duckdb.connect(str(DB_PATH))
    for arquivo in sorted((RAIZ / "sql").glob("*.sql")):
        print(f"executando {arquivo.name}...", flush=True)
        con.execute(arquivo.read_text(encoding="utf-8"))

    print("\nTabelas:")
    for (nome,) in con.execute("SELECT table_name FROM information_schema.tables ORDER BY 1").fetchall():
        linhas = con.execute(f'SELECT count(*) FROM "{nome}"').fetchone()[0]
        print(f"  {nome:<24} {linhas:>12,}")
    con.close()


if __name__ == "__main__":
    main()
