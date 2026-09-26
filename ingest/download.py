"""Baixa os arquivos do Comex Stat (MDIC) para data/raw/comexstat.

Uso:
    python ingest/download.py              # 2023 até o ano atual
    python ingest/download.py 2021 2022    # anos específicos

Arquivos já baixados são mantidos, exceto os do ano corrente,
que o MDIC atualiza todo mês.
"""

import sys
from datetime import date
from pathlib import Path

import requests
import truststore

# o servidor do MDIC não envia a cadeia completa de certificados;
# o repositório do sistema operacional consegue completá-la
truststore.inject_into_ssl()

BASE_URL = "https://balanca.economia.gov.br/balanca/bd"
RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw" / "comexstat"
TABELAS = ["NCM.csv", "NCM_SH.csv", "PAIS.csv", "URF.csv", "VIA.csv", "UF.csv"]


def baixar(url: str, destino: Path, forcar: bool = False) -> None:
    if destino.exists() and not forcar:
        print(f"  já existe: {destino.name}")
        return
    print(f"  baixando {destino.name}...", flush=True)
    tmp = destino.with_suffix(".part")
    with requests.get(url, stream=True, timeout=120) as resp:
        resp.raise_for_status()
        with open(tmp, "wb") as f:
            for bloco in resp.iter_content(chunk_size=1 << 20):
                f.write(bloco)
    tmp.replace(destino)


def main() -> None:
    ano_atual = date.today().year
    anos = [int(a) for a in sys.argv[1:]] or list(range(2023, ano_atual + 1))

    (RAW_DIR / "tabelas").mkdir(parents=True, exist_ok=True)

    print("Tabelas auxiliares:")
    for nome in TABELAS:
        baixar(f"{BASE_URL}/tabelas/{nome}", RAW_DIR / "tabelas" / nome)

    for ano in anos:
        print(f"Ano {ano}:")
        for fluxo in ("EXP", "IMP"):
            nome = f"{fluxo}_{ano}.csv"
            baixar(f"{BASE_URL}/comexstat-bd/ncm/{nome}", RAW_DIR / nome, forcar=ano == ano_atual)


if __name__ == "__main__":
    main()
