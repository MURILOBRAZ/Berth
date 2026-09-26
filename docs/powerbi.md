# Power BI

O dashboard é um **Power BI Project** (`dashboard/Projeto_Power_BI.pbip`): o modelo semântico fica versionado em texto (TMDL) em `dashboard/Projeto_Power_BI.SemanticModel/definition/`.

## Como abrir

1. Gere os dados:

   ```bash
   python ingest/download.py
   python ingest/build_db.py
   python ingest/export_powerbi.py   # gera data/powerbi/*.parquet
   ```

2. Abra `dashboard/Projeto_Power_BI.pbip` no Power BI Desktop.
3. Se o repositório estiver em outra pasta, ajuste o parâmetro **PastaDados** (Transformar dados > Editar parâmetros) para o caminho de `data\powerbi\`, terminando com `\`.
4. Clique em **Atualizar**.

## Modelo

Esquema estrela, todos os relacionamentos um-para-muitos com filtro dimensão → fato:

| Dimensão | Chave | Colunas principais |
|---|---|---|
| `dim_data` (tabela de datas) | `Data` | Ano, Mês, Trimestre, Mês/Ano |
| `dim_porto` | `co_urf` | Porto, Complexo Portuário, UF/Região do Porto, Latitude, Longitude |
| `dim_ncm` | `co_ncm` | Grupo de Carga, SH2, SH4, NCM, Seção |
| `dim_pais` | `co_pais` | País, ISO3 |
| `dim_uf` | `UF` | Estado, Região (estado produtor/consumidor da mercadoria, **não** o estado do porto) |

A tabela de datas automática do Power BI está desligada. As colunas de código ficam ocultas.

## Medidas

Ficam na tabela `_Medidas`, organizadas em pastas e com descrição (definições em [`_Medidas.tmdl`](../dashboard/Projeto_Power_BI.SemanticModel/definition/tables/_Medidas.tmdl)):

| Pasta | Medidas |
|---|---|
| Volume | Toneladas, Toneladas Exportadas, Toneladas Importadas, Toneladas sem Petróleo Bruto |
| Valor | Valor FOB (US$), US$ por Tonelada |
| Comparação | Último Mês, Toneladas Período, Toneladas AA, Var % A/A, Toneladas Acumulado Ano |
| Participação | Market Share Porto, Participação no Mix, Rank Porto |

Pontos de atenção:

- **Toneladas AA** compara o mesmo período: com dados até ago/2026, o ano de 2026 é comparado com jan–ago/2025, e não com 2025 inteiro.
- **Rank Porto** arredonda as toneladas antes de ranquear. Somas feitas em ordens diferentes geram diferenças de ponto flutuante que, sem isso, colocavam Santos um lugar abaixo de onde está.
- As medidas foram validadas por consulta DAX contra os números do DuckDB (ex.: Santos 2025 = 165,3 Mt, US$ 1.130/t, 3º no ranking; Var % A/A 2026 = +5,5%).

## Páginas

| Página | Conteúdo |
|---|---|
| **Visão executiva** | Cartões: toneladas, FOB, US$/t e Var % A/A. Linha mensal com o ano anterior. Filtros de ano, fluxo e porto. |
| **Ranking de portos** | Barras por porto com market share. Mapa (bolhas por latitude/longitude, tamanho = toneladas). Matriz porto × ano. |
| **Porto de Santos** | Porto pré-filtrado: mix por grupo de carga (treemap), top destinos, sazonalidade (mês × ano) e estados de origem. |
| **Celulose** | Grupo Celulose: toneladas por porto, destinos (China, EUA, Europa), US$/t ao longo do tempo. |
| **Insights** | As conclusões de [insights.md](insights.md), cada uma com o visual que a sustenta. |

## Observações sobre os dados

- Fonte: Comex Stat (MDIC), **somente via marítima**.
- Porto = unidade da Receita Federal onde a carga foi despachada (ver `sql/seeds/portos_urf.csv`). Algumas unidades cobrem um complexo inteiro (ex.: São Luís = Itaqui + Ponta da Madeira + Alumar).
- Não há TEU, contêineres nem tempos de navio. Esses virão da ANTAQ.
