-- ============================================================
-- PARTE 3.1 - CONCATENAÇÃO DE PRODUTO
-- ============================================================

SELECT
    produto_id,
    descricao,
    CONCAT(produto_id, ' - ', descricao) AS produto_descricao
FROM produtos_filial
ORDER BY produto_id;

-- ============================================================
-- PARTE 3.2 - FORMATAÇÃO DE DATAS
-- Formato de apresentação: DD/MM/YYYY
-- ============================================================

SELECT
    pedido_id,
    produto_id,
    TO_CHAR(data_pedido, 'DD/MM/YYYY') AS data_pedido,
    TO_CHAR(data_entrega, 'DD/MM/YYYY') AS data_entrega
FROM pedido_compra
ORDER BY pedido_id;

-- ============================================================
-- PARTE 3.3 - PRODUTOS REQUISITADOS MAIS DE 10 VEZES
-- ============================================================

SELECT
    produto_id,
    COUNT(*) AS quantidade_requisicoes
FROM pedido_compra
GROUP BY produto_id
HAVING COUNT(*) > 10
ORDER BY quantidade_requisicoes DESC, produto_id;

-- ============================================================
-- 3.4 - Resultado combinado das transformações da Parte 3
--
-- O enunciado apresenta como resultado esperado uma tabela
-- combinando:
--   - produto (produto_id + descricao_produto);
--   - quantidade de requisições;
--   - data da solicitação formatada.
--
-- A consulta abaixo reproduz esse formato sobre pedido_compra.
-- Neste conjunto de dados, nenhum produto possui mais de 10
-- requisições, portanto a consulta retorna 0 linhas.
-- ============================================================

SELECT
    CONCAT(produto_id, ' - ', descricao_produto) AS produto,
    COUNT(*) AS qtde_requisitada,
    TO_CHAR(MIN(data_pedido), 'DD/MM/YYYY') AS data_solicitacao
FROM pedido_compra
GROUP BY produto_id, descricao_produto
HAVING COUNT(*) > 10
ORDER BY qtde_requisitada DESC;
