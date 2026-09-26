# Berth ⚓

Dashboard de KPIs portuários construído com dados públicos do **Comex Stat** (MDIC) e da **ANTAQ**, com foco no Porto de Santos e na comparação entre portos e terminais.

> 🚧 Em desenvolvimento

## Objetivo

Reproduzir o tipo de acompanhamento que terminais portuários e exportadores fazem no dia a dia (desempenho de berço, tempos de navio, volumes e participação de mercado) a partir de dados abertos.

## KPIs planejados

| Área | Indicadores |
|---|---|
| Navio / berço | Tempo de espera para atracação, tempo atracado, tempo de operação, taxa de ocupação de berço, prancha média |
| Volume | Toneladas e TEUs por mês, variação anual, mix de carga, longo curso vs. cabotagem |
| Mercado | Market share por terminal, ranking de portos, principais origens e destinos |
| Granel / celulose | Toneladas embarcadas, sazonalidade, produtividade por navio |

## Stack

- **Python + DuckDB**: download e tratamento dos dados
- **SQL**: modelagem em esquema estrela (fatos e dimensões)
- **Power BI**: dashboard

## Estrutura

```
ingest/      scripts de download e carga dos dados
sql/         transformações e modelo analítico (seeds/ = tabelas de apoio)
data/        dados brutos e tratados (não versionados)
dashboard/   arquivo do Power BI e capturas de tela
analises/    consultas SQL que sustentam os insights
docs/        guia do Power BI e insights
```

## Como rodar

```bash
python -m venv .venv
.venv\Scripts\activate          # Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt

python ingest/download.py       # baixa ~1 GB do Comex Stat (2023 até o ano atual)
python ingest/build_db.py       # monta data/berth.duckdb
python ingest/export_powerbi.py  # gera data/powerbi/*.parquet para o Power BI
```

Passo a passo do dashboard (relacionamentos, medidas DAX e páginas): [docs/powerbi.md](docs/powerbi.md).

## Principais achados

- **Santos** movimenta 16% das toneladas do comércio marítimo, mas 37% do valor FOB (US$ 1.130/t, contra US$ 144/t em São Luís).
- Parte do volume atribuído a alguns portos é **petróleo bruto** exportado direto das plataformas (100% em Niterói, 52% no Açu).
- Santos cresceu 5,5% em jan–ago/2026, mas **só 2,2% sem o petróleo bruto**.
- **Soja** (mar–jun) e **milho** (ago–jan) se revezam nos terminais de granel de Santos.
- Santos embarca **47% da celulose** exportada pelo Brasil; a China compra 46%.

Detalhes e números em [docs/insights.md](docs/insights.md).

## Modelo de dados

Esquema estrela em `data/berth.duckdb`:

| Tabela | Conteúdo |
|---|---|
| `fato_comercio` | Exportação e importação **por via marítima**, por mês, NCM, país, UF e unidade da Receita Federal (toneladas e valor FOB em US$) |
| `dim_ncm` | Mercadoria com hierarquia SH2 / SH4 / seção e grupo de carga (`sql/seeds/grupos_carga.csv`) |
| `dim_porto` | Porto/complexo portuário, UF, região e coordenadas, a partir da unidade da Receita Federal de despacho (mapeamento em `sql/seeds/portos_urf.csv`) |
| `dim_pais`, `dim_uf`, `dim_data` | País parceiro, estado de origem/destino e calendário |

## Fontes dos dados

- **[Comex Stat (MDIC)](https://comexstat.mdic.gov.br/)**: base atual, com volumes e valores de comércio exterior por porto.
- **[ANTAQ – Estatístico Aquaviário](https://estatistica.antaq.gov.br/ea/sense/download.html)**: planejado, para tempos de navio, ocupação de berço e comparação entre terminais. O download exige um navegador, então os arquivos precisam ser baixados manualmente.

### Limitações

- O Comex Stat registra a **unidade aduaneira** de despacho, não o terminal. Algumas unidades cobrem um complexo inteiro (ex.: *IRF São Luís* inclui Itaqui e Ponta da Madeira).
- Não há dados de contêineres/TEU nem de tempos de operação. Esses KPIs virão da ANTAQ.
- O ano corrente é parcial, e o MDIC atualiza os dados mensalmente.
