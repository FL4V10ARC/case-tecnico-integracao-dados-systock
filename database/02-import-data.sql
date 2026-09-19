-- ============================================================
-- CASE TÉCNICO - SYSTOCK
-- Analista de Integração de Dados (Implantação)
--
-- Arquivo: 02-import-data.sql
-- Objetivo:
--     Documentar o processo de importação dos dados da planilha
--     base_teste_systock.xlsx para o PostgreSQL.
-- ============================================================


-- ============================================================
-- 1. ORIGEM DOS DADOS
-- ============================================================
--
-- Arquivo de origem:
--
-- data/original/base_teste_systock.xlsx
--
-- Abas utilizadas:
--
-- 1. fornecedor
-- 2. produtos_filial
-- 3. venda
-- 4. pedido_compra
-- 5. entradas_mercadoria
--
-- O DBeaver Community utilizado no projeto não realizou a leitura
-- direta do arquivo XLSX para o PostgreSQL.
--
-- Por isso, as abas foram convertidas para arquivos CSV antes da
-- importação.
--
-- Arquivos intermediários:
--
-- data/processed/fornecedor.csv
-- data/processed/produtos_filial.csv
-- data/processed/venda.csv
-- data/processed/pedido_compra.csv
-- data/processed/entradas_mercadoria.csv
--
-- Os arquivos CSV foram utilizados como fonte de carga no DBeaver.


-- ============================================================
-- 2. PREPARAÇÃO DOS DADOS
-- ============================================================
--
-- Durante a preparação foram observados os seguintes pontos:
--
-- - remoção das colunas auxiliares "Unnamed:" provenientes do Excel;
-- - conversão das colunas de data para o tipo DATE;
-- - preservação dos identificadores dos produtos;
-- - preservação dos identificadores dos fornecedores;
-- - adequação dos nomes das colunas ao modelo PostgreSQL;
-- - preservação dos valores numéricos da origem;
-- - manutenção dos registros inconsistentes para posterior
--   identificação e validação.
--
-- As correções de dados não foram realizadas durante a carga.
-- As inconsistências foram documentadas e tratadas posteriormente
-- nas etapas de validação.


-- ============================================================
-- 3. ORDEM DE IMPORTAÇÃO
-- ============================================================
--
-- A carga foi realizada nas seguintes tabelas:
--
-- 1. fornecedor
-- 2. produtos_filial
-- 3. venda
-- 4. pedido_compra
-- 5. entradas_mercadoria
--
-- A ordem permite que os dados sejam carregados inicialmente
-- sem aplicar correções sobre os registros de origem.


-- ============================================================
-- 4. MAPEAMENTO DOS ARQUIVOS
-- ============================================================

-- fornecedor.csv
--
-- Colunas de origem:
-- idfornecedor
-- razao_social
--
-- Destino:
-- fornecedor.idfornecedor
-- fornecedor.razao_social


-- produtos_filial.csv
--
-- Colunas de origem:
-- filial_id
-- idproduto
-- descricao
-- estoque
-- preco_unitario
-- preco_compra
-- preco_venda
-- idfornecedor
--
-- Destino:
-- filial_id
-- produto_id
-- descricao
-- estoque
-- preco_unitario
-- preco_compra
-- preco_venda
-- idfornecedor


-- venda.csv
--
-- Colunas:
-- venda_id
-- data_emissao
-- horariomov
-- produto_id
-- qtde_vendida
-- valor_unitario
-- filial_id
-- item
-- unidade_medida


-- pedido_compra.csv
--
-- Colunas:
-- pedido_id
-- data_pedido
-- item
-- produto_id
-- descricao_produto
-- ordem_compra
-- qtde_pedida
-- filial_id
-- data_entrega
-- qtde_entregue
-- preco_compra
-- fornecedor_id
--
-- As colunas auxiliares provenientes do Excel não foram importadas.


-- entradas_mercadoria.csv
--
-- Colunas:
-- data_entrada
-- nro_nfe
-- item
-- produto_id
-- descricao_produto
-- ordem_compra
-- qtde_recebida
-- filial_id
-- custo_unitario


-- ============================================================
-- 5. CARGA DOS DADOS
-- ============================================================
--
-- A importação dos CSVs foi realizada pelo recurso "Import Data"
-- do DBeaver.
--
-- Configurações utilizadas:
--
-- Formato: CSV
-- Separador: ,
-- Primeira linha contém cabeçalho: Sim
-- Codificação: UTF-8
-- Tabela de destino: correspondente à origem
--
-- O mapeamento das colunas foi conferido antes da execução de
-- cada carga.


-- ============================================================
-- 6. EXEMPLO DE CARGA VIA PostgreSQL
-- ============================================================
--
-- Caso a carga seja realizada por uma ferramenta compatível com
-- o comando \copy do PostgreSQL, os arquivos podem ser carregados
-- utilizando comandos equivalentes aos exemplos abaixo.
--
-- Os caminhos devem ser ajustados de acordo com o ambiente.


-- \copy fornecedor(idfornecedor, razao_social)
-- FROM 'data/processed/fornecedor.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- \copy produtos_filial(
--     filial_id,
--     produto_id,
--     descricao,
--     estoque,
--     preco_unitario,
--     preco_compra,
--     preco_venda,
--     idfornecedor
-- )
-- FROM 'data/processed/produtos_filial.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- \copy venda(
--     venda_id,
--     data_emissao,
--     horariomov,
--     produto_id,
--     qtde_vendida,
--     valor_unitario,
--     filial_id,
--     item,
--     unidade_medida
-- )
-- FROM 'data/processed/venda.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- \copy pedido_compra(
--     pedido_id,
--     data_pedido,
--     item,
--     produto_id,
--     descricao_produto,
--     ordem_compra,
--     qtde_pedida,
--     filial_id,
--     data_entrega,
--     qtde_entregue,
--     preco_compra,
--     fornecedor_id
-- )
-- FROM 'data/processed/pedido_compra.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- \copy entradas_mercadoria(
--     data_entrada,
--     nro_nfe,
--     item,
--     produto_id,
--     descricao_produto,
--     ordem_compra,
--     qtde_recebida,
--     filial_id,
--     custo_unitario
-- )
-- FROM 'data/processed/entradas_mercadoria.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');


-- ============================================================
-- 7. VALIDAÇÃO PÓS-IMPORTAÇÃO
-- ============================================================
--
-- Após a importação, a quantidade de registros foi conferida
-- para garantir que os dados carregados correspondessem às
-- quantidades existentes na origem.


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


-- ============================================================
-- 8. RESULTADO ESPERADO
-- ============================================================
--
-- fornecedor          = 20 registros
-- produtos_filial     = 20 registros
-- venda               = 33 registros
-- pedido_compra       = 29 registros
-- entradas_mercadoria = 20 registros
--
-- Total: 122 registros


-- ============================================================
-- 9. CRITÉRIO DE CONCLUSÃO DA IMPORTAÇÃO
-- ============================================================
--
-- A etapa de importação é considerada concluída quando:
--
-- [x] Todas as cinco fontes foram carregadas.
-- [x] As quantidades de registros foram conferidas.
-- [x] Os nomes e tipos das colunas foram adequados ao modelo.
-- [x] As colunas auxiliares do Excel foram descartadas.
-- [x] Os dados de origem foram preservados.
-- [x] As inconsistências foram mantidas para análise posterior.
--
-- As validações de qualidade e regras de negócio estão
-- documentadas nos arquivos:
--
-- database/03-fixes-and-validations.sql
-- database/04-basic-queries.sql
-- database/05-transformations.sql
-- database/06-trigger.sql
-- database/07-client-validation.sql