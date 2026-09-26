# Berth ⚓

Dashboard de KPIs portuários construído com dados públicos da **ANTAQ** (Estatístico Aquaviário), com foco no Porto de Santos e na comparação entre terminais.

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

- **Python + DuckDB**: download e tratamento dos dados da ANTAQ
- **SQL**: modelagem em esquema estrela (fatos e dimensões)
- **Power BI**: dashboard

## Estrutura

```
ingest/      scripts de download e carga dos dados
sql/         transformações e modelo analítico
data/        dados brutos e tratados (não versionados)
dashboard/   arquivo do Power BI e capturas de tela
docs/        dicionário de KPIs e notas sobre os dados
```

## Fonte dos dados

[ANTAQ — Estatístico Aquaviário](https://web3.antaq.gov.br/ea/sense/download.html) (dados abertos).
