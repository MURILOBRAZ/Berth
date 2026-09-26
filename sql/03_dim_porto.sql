-- Porto: traduz a unidade da Receita Federal (URF) para o porto/complexo portuário.
-- O mapeamento fica em sql/seeds/portos_urf.csv e cobre as unidades com volume
-- marítimo relevante; as demais (aduanas do interior, aeroportos) viram "Outras".

CREATE OR REPLACE TABLE dim_porto AS
SELECT
    u.co_urf,
    u.no_urf,
    coalesce(p.porto, 'Outras unidades') AS porto,
    p.complexo,
    p.sg_uf,
    uf.no_regiao,
    p.lat::DOUBLE AS lat,
    p.lon::DOUBLE AS lon
FROM dim_urf u
LEFT JOIN read_csv('sql/seeds/portos_urf.csv', delim = ';', header = true, all_varchar = true) p
    ON p.co_urf = u.co_urf
LEFT JOIN dim_uf uf
    ON uf.sg_uf = p.sg_uf;
