# Power BI: montagem do dashboard

## 1. Gerar os dados

```bash
python ingest/download.py
python ingest/build_db.py
python ingest/export_powerbi.py   # gera data/powerbi/*.parquet
```

## 2. Importar

No Power BI Desktop: **Obter dados > Parquet**, um arquivo por vez, a partir de `data/powerbi/`:
`fato_comercio`, `dim_data`, `dim_ncm`, `dim_pais`, `dim_porto`, `dim_uf`.

> Dica: crie um parâmetro `PastaDados` com o caminho da pasta e use-o nas consultas,
> para o arquivo `.pbix` funcionar em outra máquina trocando só o parâmetro.

## 3. Relacionamentos

Todos um-para-muitos, com filtro em direção única (dimensão → fato):

| Dimensão | Coluna | Fato |
|---|---|---|
| `dim_data` | `data` | `fato_comercio[data]` |
| `dim_ncm` | `co_ncm` | `fato_comercio[co_ncm]` |
| `dim_pais` | `co_pais` | `fato_comercio[co_pais]` |
| `dim_porto` | `co_urf` | `fato_comercio[co_urf]` |
| `dim_uf` | `sg_uf` | `fato_comercio[sg_uf]` |

Ajustes:
- Marcar `dim_data` como **tabela de datas** (coluna `data`).
- `dim_data[mes_ano]`: **Classificar por coluna** `data`.
- `dim_porto[lat]` / `[lon]`: categoria de dados **Latitude** / **Longitude**.
- Ocultar as colunas de código da fato (`co_ncm`, `co_pais`, `co_urf`, `sg_uf`).
- `dim_ncm[grupo_carga]` agrupa as principais cargas portuárias (minério, soja, celulose...). Use como filtro e legenda no lugar do SH4.
- `fato_comercio[sg_uf]` é o estado **produtor** (exportação) ou **consumidor** (importação) da mercadoria, não o estado do porto.

## 4. Medidas (DAX)

Crie uma tabela vazia `_Medidas` para agrupá-las.

```dax
Toneladas = SUM ( fato_comercio[toneladas] )

Valor FOB (US$) = SUM ( fato_comercio[valor_fob_usd] )

Toneladas Exportadas =
CALCULATE ( [Toneladas], fato_comercio[fluxo] = "Exportação" )

Toneladas Importadas =
CALCULATE ( [Toneladas], fato_comercio[fluxo] = "Importação" )

Valor por Tonelada (US$/t) = DIVIDE ( [Valor FOB (US$)], [Toneladas] )

-- Último mês com dados (o ano corrente é parcial)
Último Mês = CALCULATE ( MAX ( fato_comercio[data] ), ALL ( fato_comercio ) )

-- Ano anterior no MESMO período: evita comparar jan–ago/2026 com o ano inteiro de 2025
Toneladas AA =
VAR UltimoMes = [Último Mês]
RETURN
    CALCULATE (
        [Toneladas],
        SAMEPERIODLASTYEAR (
            FILTER ( VALUES ( dim_data[data] ), dim_data[data] <= UltimoMes )
        )
    )

Toneladas Período =
VAR UltimoMes = [Último Mês]
RETURN
    CALCULATE ( [Toneladas], KEEPFILTERS ( dim_data[data] <= UltimoMes ) )

Var % A/A = DIVIDE ( [Toneladas Período] - [Toneladas AA], [Toneladas AA] )

Toneladas Acumulado Ano = TOTALYTD ( [Toneladas], dim_data[data] )

-- Participação do porto no total do Brasil (respeita filtros de data, produto e fluxo)
Market Share Porto =
DIVIDE ( [Toneladas], CALCULATE ( [Toneladas], ALL ( dim_porto ) ) )

-- Peso do produto dentro do porto selecionado
Participação no Mix =
DIVIDE ( [Toneladas], CALCULATE ( [Toneladas], ALL ( dim_ncm ) ) )

-- Movimentação física: exclui petróleo bruto exportado das plataformas (ver docs/insights.md)
Toneladas sem Petróleo Bruto =
CALCULATE ( [Toneladas], dim_ncm[grupo_carga] <> "Petróleo bruto" )

-- Rank do porto por volume
Rank Porto =
IF (
    HASONEVALUE ( dim_porto[porto] ),
    RANKX ( ALL ( dim_porto[porto] ), [Toneladas], , DESC, DENSE )
)
```

Formatos sugeridos: toneladas em milhões (`#,0.0,, "Mt"`), FOB em bilhões (`$#,0.0,,, "bi"`), percentuais com 1 casa.

## 5. Páginas

| Página | Conteúdo |
|---|---|
| **Visão executiva** | Cartões: toneladas, FOB, US$/t e Var % A/A. Linha mensal com o ano anterior. Filtros de ano, fluxo e porto. |
| **Ranking de portos** | Barras por porto com market share. Mapa (bolhas por `lat`/`lon`, tamanho = toneladas). Matriz porto × ano. |
| **Porto de Santos** | Porto pré-filtrado: mix por SH4 (treemap), top destinos, sazonalidade (mês × ano) e estados de origem. |
| **Celulose** | SH4 4703: toneladas por porto, destinos (China, EUA, Europa), US$/t ao longo do tempo. |
| **Insights** | As conclusões de [insights.md](insights.md), cada uma com o visual que a sustenta. |

## Observações sobre os dados

- Fonte: Comex Stat (MDIC), **somente via marítima**.
- Porto = unidade da Receita Federal onde a carga foi despachada (ver `sql/seeds/portos_urf.csv`). Algumas unidades cobrem um complexo inteiro (ex.: São Luís = Itaqui + Ponta da Madeira + Alumar).
- Não há TEU, contêineres nem tempos de navio. Esses virão da ANTAQ.
