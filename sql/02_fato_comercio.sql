-- Fato: comércio exterior por via marítima (CO_VIA = '01').
-- Grão: mês x fluxo x NCM x país x UF x URF (unidade da Receita Federal de despacho).

CREATE OR REPLACE TABLE fato_comercio AS
SELECT
    CASE WHEN filename LIKE '%EXP_%' THEN 'Exportação' ELSE 'Importação' END AS fluxo,
    make_date(CO_ANO::INT, CO_MES::INT, 1) AS data,
    CO_NCM AS co_ncm,
    CO_PAIS AS co_pais,
    SG_UF_NCM AS sg_uf,
    CO_URF AS co_urf,
    KG_LIQUIDO::DOUBLE / 1000 AS toneladas,
    VL_FOB::DOUBLE AS valor_fob_usd
FROM read_csv(
    ['data/raw/comexstat/EXP_*.csv', 'data/raw/comexstat/IMP_*.csv'],
    all_varchar = true,
    union_by_name = true,
    filename = true
)
WHERE CO_VIA = '01';

-- Calendário mensal cobrindo anos completos do período com dados.
CREATE OR REPLACE TABLE dim_data AS
SELECT
    d::DATE AS data,
    year(d) AS ano,
    month(d) AS mes,
    quarter(d) AS trimestre,
    strftime(d, '%m/%Y') AS mes_ano
FROM range(
    (SELECT date_trunc('year', min(data)) FROM fato_comercio),
    (SELECT make_date(year(max(data)) + 1, 1, 1) FROM fato_comercio),
    INTERVAL 1 MONTH
) t(d);
