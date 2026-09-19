-- ============================================================
-- CASE TÉCNICO - SYSTOCK
-- Analista de Integração de Dados (Implantação)
--
-- Arquivo: 07-client-validation.sql
-- Objetivo:
--     Consultas utilizadas na validação final da implantação.
--
-- As consultas deste arquivo representam verificações que podem
-- ser executadas em uma reunião de validação com o cliente.
-- ============================================================


-- ============================================================
-- 1. QUANTIDADE DE REGISTROS POR TABELA
-- ============================================================
--
-- Objetivo:
-- Confirmar se o volume de dados carregado corresponde ao
-- volume esperado após a importação.

SELECT
    'fornecedor' AS tabela,
    COUNT(*) AS quantidade
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
-- 2. VALIDAÇÃO DE VALORES NULOS
-- ============================================================
--
-- Objetivo:
-- Identificar registros sem produto nas tabelas transacionais.

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


-- Resultado esperado:
--
-- venda               = 0
-- pedido_compra       = 0
-- entradas_mercadoria = 0


-- ============================================================
-- 3. VALIDAÇÃO DE VALORES NEGATIVOS
-- ============================================================
--
-- Objetivo:
-- Identificar quantidades ou valores financeiros negativos.

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


-- Resultado esperado:
--
-- Todas as tabelas = 0


-- ============================================================
-- 4. PRODUTOS VENDIDOS SEM CADASTRO CORRESPONDENTE
-- ============================================================
--
-- Objetivo:
-- Identificar produtos presentes em vendas que não possuem
-- cadastro correspondente em produtos_filial.

SELECT DISTINCT
    v.produto_id
FROM venda v
LEFT JOIN produtos_filial p
    ON p.produto_id = v.produto_id
WHERE p.produto_id IS NULL
ORDER BY
    v.produto_id;


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


-- ============================================================
-- 5. FILIAIS PRESENTES NAS MOVIMENTAÇÕES
-- ============================================================
--
-- Objetivo:
-- Comparar as filiais existentes nas vendas com as filiais
-- presentes no cadastro de produtos.

SELECT DISTINCT
    filial_id
FROM venda
ORDER BY filial_id;


SELECT DISTINCT
    filial_id
FROM produtos_filial
ORDER BY filial_id;


-- Resultado:
--
-- Vendas:
-- 1, 2 e 3
--
-- Cadastro de produtos:
-- 1
--
-- A diferença deve ser avaliada durante a validação do cliente.


-- ============================================================
-- 6. ENTRADAS DE MERCADORIA SEM PEDIDO DE COMPRA
-- ============================================================
--
-- Objetivo:
-- Identificar entradas que não possuem pedido correspondente.
--
-- Regra de relacionamento:
-- entradas_mercadoria.ordem_compra
--       =
-- pedido_compra.ordem_compra

SELECT
    e.ordem_compra,
    e.nro_nfe,
    e.produto_id,
    e.qtde_recebida
FROM entradas_mercadoria e
LEFT JOIN pedido_compra p
    ON p.ordem_compra = e.ordem_compra
WHERE p.ordem_compra IS NULL
ORDER BY
    e.ordem_compra;


-- Resultado encontrado:
--
-- ordem_compra 19
-- ordem_compra 20


-- ============================================================
-- 7. DIVERGÊNCIA ENTRE PEDIDO E RECEBIMENTO
-- ============================================================
--
-- Objetivo:
-- Comparar a quantidade entregue registrada no pedido com a
-- quantidade recebida registrada nas entradas de mercadoria.

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
-- 18 registros com divergência.


-- ============================================================
-- 8. INCONSISTÊNCIA TEMPORAL
-- ============================================================
--
-- Objetivo:
-- Identificar pedidos cuja data de entrega é anterior à data
-- do pedido.

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
-- 20 registros.


-- ============================================================
-- 9. RELACIONAMENTO PRODUTO/FORNECEDOR
-- ============================================================
--
-- Objetivo:
-- Confirmar o fornecedor associado a cada produto.

SELECT
    p.produto_id,
    p.descricao,
    p.idfornecedor,
    p.idfornecedor_numerico,
    f.razao_social
FROM produtos_filial p
LEFT JOIN fornecedor f
    ON f.idfornecedor = p.idfornecedor
ORDER BY
    p.produto_id;


-- Resultado esperado:
--
-- 20 produtos relacionados aos respectivos fornecedores.


-- ============================================================
-- 10. INTEGRIDADE DO IDENTIFICADOR NUMÉRICO
-- ============================================================
--
-- Objetivo:
-- Identificar produtos cujo identificador numérico não possui
-- fornecedor correspondente.

SELECT
    p.produto_id,
    p.idfornecedor,
    p.idfornecedor_numerico,
    f.idfornecedor AS fornecedor_cadastrado
FROM produtos_filial p
LEFT JOIN fornecedor f
    ON f.idfornecedor = p.idfornecedor
WHERE p.idfornecedor_numerico IS NULL
   OR f.idfornecedor IS NULL
ORDER BY
    p.produto_id;


-- Resultado esperado:
--
-- 0 registros.


-- ============================================================
-- 11. IDENTIFICADORES DOS FORNECEDORES
-- ============================================================
--
-- Objetivo:
-- Apresentar o relacionamento entre o identificador textual
-- e o identificador numérico.

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
-- 12. INTEGRIDADE DO ID NUMÉRICO
-- ============================================================
--
-- Objetivo:
-- Verificar se existem identificadores numéricos duplicados.

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
-- 13. VALIDAÇÃO DA TRIGGER
-- ============================================================
--
-- A validação funcional da trigger foi realizada separadamente
-- utilizando uma transação temporária.
--
-- Cenário testado:
--
-- idfornecedor = F8
-- resultado esperado:
-- idfornecedor_numerico = 8
--
-- Após o teste foi executado ROLLBACK.
--
-- A implementação está disponível em:
--
-- database/06-trigger.sql
--
-- Evidências:
--
-- evidence/15-3.4-teste-trigger.png
-- evidence/16-3.4-rollback-teste-trigger.png
--
-- A consulta abaixo apresenta os identificadores atualmente
-- armazenados na tabela de produtos.

SELECT
    produto_id,
    idfornecedor,
    idfornecedor_numerico
FROM produtos_filial
ORDER BY
    produto_id;


-- ============================================================
-- 14. CRITÉRIOS DE APROVAÇÃO
-- ============================================================
--
-- A validação final deve considerar:
--
-- [x] Volume de registros conferido;
-- [x] Valores nulos críticos verificados;
-- [x] Valores negativos verificados;
-- [x] Produtos sem cadastro identificados;
-- [x] Entradas sem pedido identificadas;
-- [x] Divergências entre pedido e recebimento identificadas;
-- [x] Inconsistências temporais identificadas;
-- [x] Relacionamento produto/fornecedor validado;
-- [x] Identificadores numéricos validados;
-- [x] Trigger testada;
-- [x] Dados de origem preservados.


-- ============================================================
-- 15. RASTREABILIDADE
-- ============================================================
--
-- Os resultados das validações devem ser registrados nas
-- evidências correspondentes do diretório:
--
-- evidence/
--
-- A documentação complementar encontra-se em:
--
-- docs/03-erros-e-inconsistencias.md
-- docs/04-regras-de-negocio.md
-- docs/05-estrategia-de-validacao.md
-- docs/06-resultados.md
--
-- As consultas de negócio encontram-se em:
--
-- database/04-basic-queries.sql
-- database/05-transformations.sql
-- database/06-trigger.sql