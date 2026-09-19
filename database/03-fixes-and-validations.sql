-- ============================================================
-- CASE TÉCNICO - SYSTOCK
-- Analista de Integração de Dados (Implantação)
--
-- Arquivo: 03-fixes-and-validations.sql
-- Objetivo:
--     Executar validações estruturais e identificar
--     inconsistências presentes nos dados importados.
--
-- Observação:
--     Os dados de origem não são corrigidos automaticamente.
--     As inconsistências são identificadas, documentadas e
--     posteriormente avaliadas conforme as regras de negócio.
-- ============================================================


-- ============================================================
-- 1. QUANTIDADE DE REGISTROS
-- ============================================================
--
-- Validação do volume de dados após a importação.

SELECT
    'fornecedor' AS tabela,
    COUNT(*) AS quantidade_registros
FROM fornecedor

UNION ALL

SELECT
    'produtos_filial',
    COUNT(*)
FROM produtos_filial

UNION ALL

SELECT
    'venda',
    COUNT(*)
FROM venda

UNION ALL

SELECT
    'pedido_compra',
    COUNT(*)
FROM pedido_compra

UNION ALL

SELECT
    'entradas_mercadoria',
    COUNT(*)
FROM entradas_mercadoria;


-- Resultado esperado:
--
-- fornecedor          = 20
-- produtos_filial     = 20
-- venda               = 33
-- pedido_compra       = 29
-- entradas_mercadoria = 20


-- ============================================================
-- 2. VALORES NULOS
-- ============================================================
--
-- Identificação de registros sem produto nas tabelas
-- transacionais.

SELECT
    'venda' AS tabela,
    COUNT(*) AS registros_sem_produto
FROM venda
WHERE produto_id IS NULL

UNION ALL

SELECT
    'pedido_compra',
    COUNT(*)
FROM pedido_compra
WHERE produto_id IS NULL

UNION ALL

SELECT
    'entradas_mercadoria',
    COUNT(*)
FROM entradas_mercadoria
WHERE produto_id IS NULL;


-- Resultado encontrado:
--
-- venda               = 0
-- pedido_compra       = 0
-- entradas_mercadoria = 0


-- ============================================================
-- 3. VALORES NEGATIVOS
-- ============================================================
--
-- Verificação de quantidades, preços e valores negativos.

SELECT
    'venda' AS tabela,
    COUNT(*) AS registros_com_valor_negativo
FROM venda
WHERE qtde_vendida < 0
   OR valor_unitario < 0

UNION ALL

SELECT
    'pedido_compra',
    COUNT(*)
FROM pedido_compra
WHERE qtde_pedida < 0
   OR qtde_entregue < 0
   OR preco_compra < 0

UNION ALL

SELECT
    'entradas_mercadoria',
    COUNT(*)
FROM entradas_mercadoria
WHERE qtde_recebida < 0
   OR custo_unitario < 0

UNION ALL

SELECT
    'produtos_filial',
    COUNT(*)
FROM produtos_filial
WHERE estoque < 0
   OR preco_unitario < 0
   OR preco_compra < 0
   OR preco_venda < 0;


-- Resultado encontrado:
--
-- Não foram identificados valores negativos.


-- ============================================================
-- 4. PRODUTOS VENDIDOS SEM CADASTRO
-- ============================================================
--
-- Identificação de produtos presentes em vendas que não
-- possuem cadastro correspondente em produtos_filial.

SELECT DISTINCT
    v.produto_id
FROM venda v
LEFT JOIN produtos_filial p
    ON p.produto_id = v.produto_id
WHERE p.produto_id IS NULL
ORDER BY v.produto_id;


-- Resultado encontrado:
--
-- P21
-- P22
-- P23
-- P24
-- P25
-- P26
-- P27
-- P28
--
-- Observação:
-- A análise considera o produto_id. A tabela de cadastro também
-- possui filial_id, portanto esta inconsistência deve ser
-- considerada junto à análise de filial.


-- ============================================================
-- 5. PRODUTOS E FILIAIS
-- ============================================================
--
-- Identificação das filiais existentes nas vendas e comparação
-- com as filiais cadastradas em produtos_filial.

SELECT DISTINCT
    filial_id
FROM venda
ORDER BY filial_id;


SELECT DISTINCT
    filial_id
FROM produtos_filial
ORDER BY filial_id;


-- Resultado observado:
--
-- venda:
-- filiais 1, 2 e 3
--
-- produtos_filial:
-- filial 1
--
-- Portanto, existem movimentações de venda em filiais para as
-- quais não há cadastro correspondente de produto na base
-- analisada.


-- ============================================================
-- 6. ENTRADAS SEM PEDIDO DE COMPRA
-- ============================================================
--
-- Identificação de entradas de mercadoria que não possuem
-- pedido de compra correspondente.
--
-- O relacionamento utiliza ordem_compra.

SELECT
    e.ordem_compra,
    e.nro_nfe,
    e.item,
    e.produto_id,
    e.qtde_recebida
FROM entradas_mercadoria e
LEFT JOIN pedido_compra p
    ON p.ordem_compra = e.ordem_compra
WHERE p.ordem_compra IS NULL
ORDER BY
    e.ordem_compra,
    e.item;


-- Resultado encontrado:
--
-- ordem_compra = 19
-- ordem_compra = 20
--
-- Essas entradas não possuem pedido de compra correspondente
-- na base importada.


-- ============================================================
-- 7. PEDIDOS COM ORDEM DE COMPRA IGUAL A ZERO
-- ============================================================
--
-- Identificação dos pedidos sem ordem de compra válida.

SELECT
    pedido_id,
    item,
    produto_id,
    ordem_compra,
    qtde_pedida,
    qtde_entregue
FROM pedido_compra
WHERE ordem_compra = 0
ORDER BY
    pedido_id,
    item;


-- Resultado encontrado:
--
-- Foram identificados 11 registros com ordem_compra = 0.
--
-- Esses registros também estão associados a qtde_entregue = 0.


-- ============================================================
-- 8. DIVERGÊNCIA ENTRE PEDIDO E RECEBIMENTO
-- ============================================================
--
-- Comparação entre a quantidade entregue registrada no pedido
-- e a quantidade efetivamente registrada nas entradas de
-- mercadoria.
--
-- A relação utiliza:
-- ordem_compra
-- item
-- produto_id

SELECT
    p.ordem_compra,
    p.item,
    p.produto_id,
    p.qtde_pedida,
    p.qtde_entregue,
    COALESCE(SUM(e.qtde_recebida), 0) AS qtde_recebida
FROM pedido_compra p
LEFT JOIN entradas_mercadoria e
    ON e.ordem_compra = p.ordem_compra
   AND e.item = p.item
   AND e.produto_id = p.produto_id
GROUP BY
    p.ordem_compra,
    p.item,
    p.produto_id,
    p.qtde_pedida,
    p.qtde_entregue
HAVING p.qtde_entregue <> COALESCE(SUM(e.qtde_recebida), 0)
ORDER BY
    p.ordem_compra,
    p.item,
    p.produto_id;


-- Resultado encontrado:
--
-- Foram identificadas 18 divergências entre qtde_entregue
-- e a quantidade recebida registrada nas entradas.


-- ============================================================
-- 9. INCONSISTÊNCIA TEMPORAL
-- ============================================================
--
-- Identificação de pedidos cuja data de entrega é anterior
-- à data do pedido.

SELECT
    pedido_id,
    produto_id,
    data_pedido,
    data_entrega
FROM pedido_compra
WHERE data_entrega < data_pedido
ORDER BY
    data_pedido,
    pedido_id;


-- Resultado encontrado:
--
-- Foram identificados 20 registros nessa condição.
--
-- Exemplo:
--
-- pedido_id   = 6
-- data_pedido = 22/02/2025
-- data_entrega = 05/01/2025
--
-- A inconsistência é mantida para validação com o responsável
-- pelo processo de negócio.


-- ============================================================
-- 10. RELACIONAMENTO PRODUTO/FORNECEDOR
-- ============================================================
--
-- Validação dos fornecedores associados aos produtos.

SELECT
    p.produto_id,
    p.descricao,
    p.idfornecedor,
    f.razao_social
FROM produtos_filial p
LEFT JOIN fornecedor f
    ON f.idfornecedor = p.idfornecedor
ORDER BY
    p.produto_id;


-- Resultado:
--
-- Os 20 produtos cadastrados possuem fornecedor correspondente.


-- ============================================================
-- 11. VALIDAÇÃO DO IDENTIFICADOR NUMÉRICO
-- ============================================================
--
-- Verificação dos identificadores numéricos utilizados no
-- relacionamento entre produtos e fornecedores.

SELECT
    p.produto_id,
    p.idfornecedor,
    p.idfornecedor_numerico,
    f.idfornecedor_numerico AS fornecedor_id_numerico
FROM produtos_filial p
LEFT JOIN fornecedor f
    ON f.idfornecedor = p.idfornecedor
WHERE p.idfornecedor_numerico IS NULL
   OR f.idfornecedor_numerico IS NULL
ORDER BY
    p.produto_id;


-- Resultado esperado:
--
-- 0 registros.
--
-- A ausência de registros indica que os produtos possuem
-- identificador numérico correspondente ao fornecedor cadastrado.


-- ============================================================
-- 12. DUPLICIDADE DE IDENTIFICADOR NUMÉRICO
-- ============================================================
--
-- Verificação da unicidade dos identificadores numéricos
-- dos fornecedores.

SELECT
    idfornecedor_numerico,
    COUNT(*) AS quantidade
FROM fornecedor
GROUP BY
    idfornecedor_numerico
HAVING COUNT(*) > 1
ORDER BY
    idfornecedor_numerico;


-- Resultado esperado:
--
-- 0 registros.


-- ============================================================
-- 13. CONSISTÊNCIA DO MAPEAMENTO DOS FORNECEDORES
-- ============================================================
--
-- Validação do relacionamento entre identificador textual
-- e identificador numérico.

SELECT
    idfornecedor,
    idfornecedor_numerico,
    razao_social
FROM fornecedor
ORDER BY
    idfornecedor_numerico;


-- Resultado esperado:
--
-- F1  -> 1
-- F2  -> 2
-- ...
-- F20 -> 20


-- ============================================================
-- 14. VERIFICAÇÃO DA TRIGGER
-- ============================================================
--
-- A trigger é responsável por preencher automaticamente
-- idfornecedor_numerico em produtos_filial durante INSERT
-- ou UPDATE de idfornecedor.
--
-- O teste funcional da trigger está documentado em:
--
-- database/06-trigger.sql
--
-- Evidências:
--
-- evidence/15-3.4-teste-trigger.png
-- evidence/16-3.4-rollback-teste-trigger.png
--
-- O teste utiliza uma transação temporária e ROLLBACK para
-- evitar a permanência do registro de teste.


-- ============================================================
-- 15. PRINCÍPIO DE TRATAMENTO
-- ============================================================
--
-- As inconsistências identificadas neste arquivo não são
-- corrigidas automaticamente.
--
-- O procedimento adotado é:
--
-- 1. Identificar a inconsistência;
-- 2. Registrar o resultado;
-- 3. Avaliar a regra de negócio aplicável;
-- 4. Validar com o responsável pelo processo;
-- 5. Corrigir somente após aprovação;
-- 6. Registrar a alteração para garantir rastreabilidade.
--
-- Dessa forma, os dados de origem permanecem preservados.
