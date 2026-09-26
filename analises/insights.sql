-- Consultas que sustentam docs/insights.md.
-- Rodar em data/berth.duckdb (ex.: duckdb data/berth.duckdb < analises/insights.sql).
-- Comparações de 2026 usam jan–ago, o último mês disponível.

-- 1. Volume x valor por porto (2025)
SELECT
    porto,
    round(sum(toneladas) / 1e6, 1) AS mt,
    round(sum(valor_fob_usd) / 1e9, 1) AS fob_bi_usd,
    round(sum(valor_fob_usd) / sum(toneladas), 0) AS usd_por_t,
    round(100 * sum(toneladas) / sum(sum(toneladas)) OVER (), 1) AS share_t_pct,
    round(100 * sum(valor_fob_usd) / sum(sum(valor_fob_usd)) OVER (), 1) AS share_fob_pct
FROM fato_comercio
JOIN dim_porto USING (co_urf)
WHERE year(data) = 2025
GROUP BY porto
ORDER BY mt DESC
LIMIT 10;

-- 2. Petróleo bruto exportado e seu peso em cada porto (2025)
SELECT
    porto,
    round(sum(toneladas) FILTER (WHERE grupo_carga = 'Petróleo bruto') / 1e6, 1) AS petroleo_mt,
    round(100 * sum(toneladas) FILTER (WHERE grupo_carga = 'Petróleo bruto') / sum(toneladas), 1) AS pct_do_porto
FROM fato_comercio
JOIN dim_porto USING (co_urf)
JOIN dim_ncm USING (co_ncm)
WHERE fluxo = 'Exportação' AND year(data) = 2025
GROUP BY porto
HAVING petroleo_mt > 1
ORDER BY petroleo_mt DESC;

-- 3. Variação jan–ago 2026 x 2025 por porto (exportação + importação)
SELECT
    porto,
    round(sum(toneladas) FILTER (WHERE year(data) = 2025) / 1e6, 1) AS mt_2025,
    round(sum(toneladas) FILTER (WHERE year(data) = 2026) / 1e6, 1) AS mt_2026,
    round(100 * (sum(toneladas) FILTER (WHERE year(data) = 2026)
               / sum(toneladas) FILTER (WHERE year(data) = 2025) - 1), 1) AS var_pct
FROM fato_comercio
JOIN dim_porto USING (co_urf)
WHERE month(data) <= 8 AND year(data) IN (2025, 2026)
GROUP BY porto
HAVING mt_2025 > 10
ORDER BY mt_2026 DESC;

-- 4. Santos: grupos de carga que explicam a variação das exportações (jan–ago 2026 x 2025)
SELECT
    grupo_carga,
    round(sum(toneladas) FILTER (WHERE year(data) = 2025) / 1e6, 2) AS mt_2025,
    round(sum(toneladas) FILTER (WHERE year(data) = 2026) / 1e6, 2) AS mt_2026,
    round((coalesce(sum(toneladas) FILTER (WHERE year(data) = 2026), 0)
         - coalesce(sum(toneladas) FILTER (WHERE year(data) = 2025), 0)) / 1e6, 2) AS delta_mt
FROM fato_comercio
JOIN dim_porto USING (co_urf)
JOIN dim_ncm USING (co_ncm)
WHERE porto = 'Santos' AND fluxo = 'Exportação' AND month(data) <= 8 AND year(data) IN (2025, 2026)
GROUP BY grupo_carga
ORDER BY abs(delta_mt) DESC
LIMIT 8;

-- 5. Santos: sazonalidade de soja, milho e açúcar (média mensal 2023–2025)
SELECT
    month(data) AS mes,
    round(sum(toneladas) FILTER (WHERE grupo_carga = 'Soja') / 3e6, 2) AS soja_mt,
    round(sum(toneladas) FILTER (WHERE grupo_carga = 'Milho') / 3e6, 2) AS milho_mt,
    round(sum(toneladas) FILTER (WHERE grupo_carga = 'Açúcar') / 3e6, 2) AS acucar_mt
FROM fato_comercio
JOIN dim_porto USING (co_urf)
JOIN dim_ncm USING (co_ncm)
WHERE porto = 'Santos' AND fluxo = 'Exportação' AND year(data) BETWEEN 2023 AND 2025
GROUP BY mes
ORDER BY mes;

-- 6. Celulose: portos, destinos e preço médio (US$/t) por semestre
SELECT
    porto,
    round(sum(toneladas) FILTER (WHERE year(data) = 2025) / 1e6, 2) AS mt_2025,
    round(100 * sum(toneladas) FILTER (WHERE year(data) = 2025)
        / sum(sum(toneladas) FILTER (WHERE year(data) = 2025)) OVER (), 1) AS share_pct
FROM fato_comercio
JOIN dim_porto USING (co_urf)
JOIN dim_ncm USING (co_ncm)
WHERE co_sh4 = '4703' AND fluxo = 'Exportação'
GROUP BY porto
ORDER BY mt_2025 DESC NULLS LAST
LIMIT 5;

SELECT
    no_pais,
    round(sum(toneladas) / 1e6, 2) AS mt,
    round(100 * sum(toneladas) / sum(sum(toneladas)) OVER (), 1) AS share_pct
FROM fato_comercio
JOIN dim_ncm USING (co_ncm)
JOIN dim_pais USING (co_pais)
WHERE co_sh4 = '4703' AND fluxo = 'Exportação' AND year(data) = 2025
GROUP BY no_pais
ORDER BY mt DESC
LIMIT 5;

SELECT
    year(data) AS ano,
    CASE WHEN month(data) <= 6 THEN 1 ELSE 2 END AS semestre,
    round(sum(valor_fob_usd) / sum(toneladas), 0) AS usd_por_t,
    round(sum(toneladas) / 1e6, 2) AS mt
FROM fato_comercio
JOIN dim_ncm USING (co_ncm)
WHERE co_sh4 = '4703' AND fluxo = 'Exportação'
GROUP BY ALL
ORDER BY ALL;
