-- ============================================================
-- PARTE 2.1 - CONSUMO POR PRODUTO
-- Período: Fevereiro de 2025
-- ============================================================

SELECT
    produto_id,
    SUM(qtde_vendida) AS quantidade_consumida,
    SUM(qtde_vendida * valor_unitario) AS valor_total_consumido
FROM venda
WHERE data_emissao BETWEEN '2025-02-01' AND '2025-02-28'
GROUP BY produto_id
ORDER BY produto_id;

-- ============================================================
-- PARTE 2.2 - PRODUTOS SOLICITADOS, MAS NÃO RECEBIDOS
-- ============================================================

SELECT
    p.pedido_id,
    p.ordem_compra,
    p.item,
    p.produto_id,
    p.qtde_pedida,
    COALESCE(SUM(e.qtde_recebida), 0) AS qtde_recebida
FROM pedido_compra p
LEFT JOIN entradas_mercadoria e
    ON e.ordem_compra = p.ordem_compra
   AND e.item = p.item
   AND e.produto_id = p.produto_id
GROUP BY
    p.pedido_id,
    p.ordem_compra,
    p.item,
    p.produto_id,
    p.qtde_pedida
HAVING COALESCE(SUM(e.qtde_recebida), 0) = 0
ORDER BY
    p.pedido_id,
    p.item,
    p.produto_id;