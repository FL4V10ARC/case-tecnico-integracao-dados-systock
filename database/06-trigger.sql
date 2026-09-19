-- ============================================================
-- CASE TÉCNICO - SYSTOCK
-- Analista de Integração de Dados (Implantação)
--
-- Arquivo: 06-trigger.sql
-- Objetivo:
--     Criar e configurar o identificador numérico do fornecedor
--     e automatizar seu preenchimento na tabela de produtos.
-- ============================================================

-- ============================================================
-- 1. ADICIONAR IDENTIFICADOR NUMÉRICO AO FORNECEDOR
-- ============================================================

ALTER TABLE fornecedor
ADD COLUMN IF NOT EXISTS idfornecedor_numerico BIGINT;


-- ============================================================
-- 2. PREENCHER O IDENTIFICADOR NUMÉRICO DOS FORNECEDORES
-- ============================================================

UPDATE fornecedor
SET idfornecedor_numerico =
    CAST(SUBSTRING(idfornecedor FROM 2) AS BIGINT)
WHERE idfornecedor_numerico IS NULL;


-- ============================================================
-- 3. GARANTIR UNICIDADE DO IDENTIFICADOR NUMÉRICO
-- ============================================================

ALTER TABLE fornecedor
DROP CONSTRAINT IF EXISTS fornecedor_idfornecedor_numerico_unique;

ALTER TABLE fornecedor
ADD CONSTRAINT fornecedor_idfornecedor_numerico_unique
UNIQUE (idfornecedor_numerico);


-- ============================================================
-- 4. ADICIONAR IDENTIFICADOR NUMÉRICO À TABELA DE PRODUTOS
-- ============================================================

ALTER TABLE produtos_filial
ADD COLUMN IF NOT EXISTS idfornecedor_numerico BIGINT;


-- ============================================================
-- 5. PREENCHER O IDENTIFICADOR NUMÉRICO DOS PRODUTOS
-- ============================================================

UPDATE produtos_filial p
SET idfornecedor_numerico = f.idfornecedor_numerico
FROM fornecedor f
WHERE p.idfornecedor = f.idfornecedor
  AND p.idfornecedor_numerico IS NULL;


-- ============================================================
-- 6. GARANTIR O RELACIONAMENTO COM O FORNECEDOR
-- ============================================================

ALTER TABLE produtos_filial
DROP CONSTRAINT IF EXISTS produtos_filial_fornecedor_numerico_fkey;

ALTER TABLE produtos_filial
ADD CONSTRAINT produtos_filial_fornecedor_numerico_fkey
FOREIGN KEY (idfornecedor_numerico)
REFERENCES fornecedor (idfornecedor_numerico);


-- ============================================================
-- 7. FUNÇÃO DA TRIGGER
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


-- ============================================================
-- 8. TRIGGER
-- ============================================================

DROP TRIGGER IF EXISTS trg_preencher_idfornecedor_numerico
ON produtos_filial;

CREATE OR REPLACE TRIGGER trg_preencher_idfornecedor_numerico
BEFORE INSERT OR UPDATE OF idfornecedor
ON produtos_filial
FOR EACH ROW
EXECUTE FUNCTION fn_preencher_idfornecedor_numerico();


-- ============================================================
-- 9. VALIDAÇÃO DO MAPEAMENTO
-- ============================================================

SELECT
    idfornecedor,
    idfornecedor_numerico,
    razao_social
FROM fornecedor
ORDER BY idfornecedor_numerico;


-- ============================================================
-- 10. VALIDAÇÃO DOS PRODUTOS
-- ============================================================

SELECT
    produto_id,
    idfornecedor,
    idfornecedor_numerico
FROM produtos_filial
ORDER BY produto_id;