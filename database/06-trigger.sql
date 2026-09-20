-- ============================================================
-- CASE TÉCNICO - SYSTOCK
-- Analista de Integração de Dados (Implantação)
--
-- Arquivo: 06-trigger.sql
-- Objetivo:
--     Gerar automaticamente um identificador numérico para
--     fornecedores e relacioná-lo aos produtos.
-- ============================================================


-- ============================================================
-- 1. SEQUENCE PARA GERAÇÃO DOS IDENTIFICADORES
-- ============================================================

CREATE SEQUENCE IF NOT EXISTS seq_idfornecedor_numerico
    START WITH 1
    INCREMENT BY 1;


-- ============================================================
-- 2. IDENTIFICADOR NUMÉRICO NO CADASTRO DE FORNECEDORES
-- ============================================================

ALTER TABLE fornecedor
ADD COLUMN IF NOT EXISTS idfornecedor_numerico BIGINT;


-- ============================================================
-- 3. FUNÇÃO PARA GERAR AUTOMATICAMENTE O ID DO FORNECEDOR
-- ============================================================

CREATE OR REPLACE FUNCTION fn_gerar_idfornecedor_numerico()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.idfornecedor_numerico IS NULL THEN
        NEW.idfornecedor_numerico :=
            nextval('seq_idfornecedor_numerico');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 4. TRIGGER DE GERAÇÃO DO ID DO FORNECEDOR
-- ============================================================

DROP TRIGGER IF EXISTS trg_gerar_idfornecedor_numerico
ON fornecedor;

CREATE OR REPLACE TRIGGER trg_gerar_idfornecedor_numerico
BEFORE INSERT ON fornecedor
FOR EACH ROW
EXECUTE FUNCTION fn_gerar_idfornecedor_numerico();


-- ============================================================
-- 5. AJUSTE DOS DADOS EXISTENTES
-- ============================================================

UPDATE fornecedor
SET idfornecedor_numerico =
    CAST(SUBSTRING(idfornecedor FROM 2) AS BIGINT)
WHERE idfornecedor_numerico IS NULL;


-- Garante que a próxima sequência não gere um ID já utilizado.
SELECT setval(
    'seq_idfornecedor_numerico',
    COALESCE((SELECT MAX(idfornecedor_numerico) FROM fornecedor), 0)
);


-- ============================================================
-- 6. RESTRIÇÃO DE UNICIDADE
-- ============================================================

ALTER TABLE fornecedor
DROP CONSTRAINT IF EXISTS fornecedor_idfornecedor_numerico_unique;

ALTER TABLE fornecedor
ADD CONSTRAINT fornecedor_idfornecedor_numerico_unique
UNIQUE (idfornecedor_numerico);


-- ============================================================
-- 7. IDENTIFICADOR NUMÉRICO NA TABELA DE PRODUTOS
-- ============================================================

ALTER TABLE produtos_filial
ADD COLUMN IF NOT EXISTS idfornecedor_numerico BIGINT;


-- Preenchimento dos produtos já existentes.
UPDATE produtos_filial p
SET idfornecedor_numerico = f.idfornecedor_numerico
FROM fornecedor f
WHERE p.idfornecedor = f.idfornecedor
  AND p.idfornecedor_numerico IS NULL;


-- ============================================================
-- 8. RELACIONAMENTO ENTRE PRODUTO E FORNECEDOR
-- ============================================================

ALTER TABLE produtos_filial
DROP CONSTRAINT IF EXISTS produtos_filial_fornecedor_numerico_fkey;

ALTER TABLE produtos_filial
ADD CONSTRAINT produtos_filial_fornecedor_numerico_fkey
FOREIGN KEY (idfornecedor_numerico)
REFERENCES fornecedor (idfornecedor_numerico);


-- ============================================================
-- 9. TRIGGER PARA RELACIONAR O PRODUTO AO FORNECEDOR
-- ============================================================

CREATE OR REPLACE FUNCTION fn_preencher_idfornecedor_numerico()
RETURNS TRIGGER AS $$
BEGIN

    IF NEW.idfornecedor IS NULL THEN
        NEW.idfornecedor_numerico := NULL;
        RETURN NEW;
    END IF;

    SELECT f.idfornecedor_numerico
    INTO NEW.idfornecedor_numerico
    FROM fornecedor f
    WHERE f.idfornecedor = NEW.idfornecedor;

    IF NEW.idfornecedor_numerico IS NULL THEN
        RAISE EXCEPTION
            'Fornecedor % não encontrado no cadastro.',
            NEW.idfornecedor;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_preencher_idfornecedor_numerico
ON produtos_filial;

CREATE OR REPLACE TRIGGER trg_preencher_idfornecedor_numerico
BEFORE INSERT OR UPDATE OF idfornecedor
ON produtos_filial
FOR EACH ROW
EXECUTE FUNCTION fn_preencher_idfornecedor_numerico();


-- ============================================================
-- 10. CONSULTA DE VALIDAÇÃO DOS FORNECEDORES
-- ============================================================

SELECT
    idfornecedor,
    idfornecedor_numerico,
    razao_social
FROM fornecedor
ORDER BY idfornecedor_numerico;


-- ============================================================
-- 11. CONSULTA DE VALIDAÇÃO DOS PRODUTOS
-- ============================================================

SELECT
    produto_id,
    idfornecedor,
    idfornecedor_numerico
FROM produtos_filial
ORDER BY produto_id;