-- Dimensões a partir das tabelas auxiliares do Comex Stat.
-- Os arquivos são latin-1 e alguns têm descrições com aspas sem escape
-- (ex.: 45", "oriented strand board"), então o dialeto é fixado e o modo
-- estrito desligado. Contagens conferidas contra os códigos do arquivo bruto.

CREATE OR REPLACE TABLE dim_urf AS
SELECT
    CO_URF AS co_urf,
    regexp_replace(NO_URF, '^\d+ - ', '') AS no_urf
FROM read_csv('data/raw/comexstat/tabelas/URF.csv',
    encoding = 'latin-1', all_varchar = true, delim = ';', quote = '"', header = true, strict_mode = false);

CREATE OR REPLACE TABLE dim_pais AS
SELECT
    CO_PAIS AS co_pais,
    CO_PAIS_ISOA3 AS iso3,
    NO_PAIS AS no_pais
FROM read_csv('data/raw/comexstat/tabelas/PAIS.csv',
    encoding = 'latin-1', all_varchar = true, delim = ';', quote = '"', header = true, strict_mode = false);

CREATE OR REPLACE TABLE dim_uf AS
SELECT
    SG_UF AS sg_uf,
    NO_UF AS no_uf,
    CASE NO_REGIAO
        WHEN 'REGIAO NORTE' THEN 'Norte'
        WHEN 'REGIAO NORDESTE' THEN 'Nordeste'
        WHEN 'REGIAO CENTRO OESTE' THEN 'Centro-Oeste'
        WHEN 'REGIAO SUDESTE' THEN 'Sudeste'
        WHEN 'REGIAO SUL' THEN 'Sul'
        ELSE 'Não declarada'
    END AS no_regiao
FROM read_csv('data/raw/comexstat/tabelas/UF.csv',
    encoding = 'latin-1', all_varchar = true, delim = ';', quote = '"', header = true, strict_mode = false);

CREATE OR REPLACE TABLE dim_ncm AS
SELECT
    n.CO_NCM AS co_ncm,
    n.NO_NCM_POR AS no_ncm,
    sh.CO_SH4 AS co_sh4,
    sh.NO_SH4_POR AS no_sh4,
    sh.CO_SH2 AS co_sh2,
    sh.NO_SH2_POR AS no_sh2,
    sh.NO_SEC_POR AS no_secao,
    -- grupos das principais cargas portuárias (sql/seeds/grupos_carga.csv)
    coalesce(g.grupo_carga, 'Outras cargas') AS grupo_carga
FROM read_csv('data/raw/comexstat/tabelas/NCM.csv',
    encoding = 'latin-1', all_varchar = true, delim = ';', quote = '"', header = true, strict_mode = false) n
LEFT JOIN read_csv('data/raw/comexstat/tabelas/NCM_SH.csv',
    encoding = 'latin-1', all_varchar = true, delim = ';', quote = '"', header = true, strict_mode = false) sh
    ON sh.CO_SH6 = n.CO_SH6
LEFT JOIN read_csv('sql/seeds/grupos_carga.csv', delim = ';', header = true, all_varchar = true) g
    ON g.co_sh4 = sh.CO_SH4;
