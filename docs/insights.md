# Insights

Comércio exterior por via marítima, com dados do Comex Stat até ago/2026. Cada número pode ser reproduzido pelas consultas de [`analises/insights.sql`](../analises/insights.sql).

## 1. Ranking por tonelada esconde onde está o valor

Em 2025, **Santos** movimentou 16,3% das toneladas do comércio marítimo brasileiro, mas **37,1% do valor FOB** (US$ 187 bi). A carga que passa por Santos vale em média **US$ 1.130/t**. Em São Luís, o maior porto em volume (20,5% das toneladas), a média é **US$ 144/t**, porque a pauta é dominada por minério de ferro.

| Porto | Mt | US$ bi FOB | US$/t |
|---|---:|---:|---:|
| São Luís | 207,1 | 29,8 | 144 |
| Itaguaí | 165,4 | 31,1 | 188 |
| Santos | 165,3 | 186,8 | 1.130 |
| Vitória | 128,7 | 26,9 | 209 |
| Paranaguá | 63,2 | 48,0 | 760 |

**Leitura:** comparar portos só por tonelada favorece quem exporta granel de baixo valor. O dashboard mostra as duas métricas lado a lado.

## 2. Parte do "porto" é petróleo que nunca encostou no cais

O petróleo bruto exportado é registrado na unidade da Receita que faz o despacho, mas boa parte sai direto das plataformas do pré-sal por navios aliviadores. Em 2025 o petróleo bruto foi **100%** das exportações atribuídas a Niterói, **52%** das do Açu, **20%** das de Itaguaí e **13%** das de Santos.

**Leitura:** para analisar a movimentação física de um porto, o dashboard permite filtrar o grupo *Petróleo bruto*.

## 3. Santos cresce, mas menos do que parece

De janeiro a agosto de 2026, Santos movimentou **113,8 Mt**, 5,5% acima do mesmo período de 2025. **Sem o petróleo bruto**, o crescimento cai para **2,2%** (96,7 → 98,7 Mt). O petróleo sozinho respondeu por 3,8 dos 5,9 Mt a mais.

Entre as cargas físicas, soja (+2,4 Mt) e farelo (+0,9 Mt) cresceram, enquanto milho (−0,7 Mt) e celulose (−0,6 Mt) recuaram.

## 4. Soja e milho se revezam nos berços de granel de Santos

Média mensal exportada por Santos entre 2023 e 2025:

- **Soja:** concentrada de **março a junho** (4,5 a 5,7 Mt/mês) e quase zero em janeiro.
- **Milho:** ocupa o espaço de **agosto a janeiro** (1,9 a 3,1 Mt/mês) e quase zero de março a junho.
- **Açúcar:** mais estável ao longo do ano, com pico de julho a outubro (~2,5 a 2,8 Mt/mês).

**Leitura:** os terminais de grãos trocam de produto ao longo do ano sem ficar ociosos. Para planejar berço e armazém, o pico de soja do 1º semestre é o gargalo.

## 5. Santos é o porto da celulose brasileira

Em 2025, **47%** da celulose exportada pelo Brasil (SH4 4703) saiu por Santos, com 9,7 Mt, seguido de Vitória (27%) e Rio Grande (10%). A **China** comprou **46%** do total, os EUA 14% e Itália e Holanda juntas 16%.

O preço médio oscilou bastante: de **US$ 380/t** (2º sem/2023) a **US$ 567/t** (2º sem/2024), caiu para **US$ 425/t** (2º sem/2025) e voltou a subir em 2026. Em volume, jan–ago/2026 ficou 8% abaixo do mesmo período de 2025 em Santos.

**Leitura:** para um exportador de celulose, a receita depende mais do preço internacional do que do volume embarcado, e a dependência da China é um risco de concentração.

---

*Limitações: o porto corresponde à unidade da Receita Federal de despacho (ver [`sql/seeds/portos_urf.csv`](../sql/seeds/portos_urf.csv)). 2026 é parcial (até agosto). Não há dados de TEU nem de tempos de navio, que dependem da ANTAQ.*
