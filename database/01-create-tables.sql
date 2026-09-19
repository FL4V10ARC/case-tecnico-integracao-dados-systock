-- ============================================================
-- CASE TÉCNICO - SYSTOCK
-- Analista de Integração de Dados (Implantação)
--
-- Arquivo: 01-create-tables.sql
-- Objetivo:
--     Criação das tabelas PostgreSQL utilizadas no case.
--
-- Fonte da modelagem:
--     DDL fornecido pela Systock + análise da base Excel.
--
-- Observação:
--     O DDL fornecido no case apresenta algumas inconsistências
--     estruturais. Os pontos identificados serão documentados e
--     tratados nas etapas posteriores.
-- ============================================================


-- ============================================================
-- TABELA: FORNECEDOR
-- ============================================================

CREATE TABLE public.fornecedor (
    idfornecedor VARCHAR(25) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,

    CONSTRAINT fornecedor_pkey
        PRIMARY KEY (idfornecedor)
);


-- ============================================================
-- TABELA: PRODUTOS_FILIAL
-- ============================================================

CREATE TABLE public.produtos_filial (
    filial_id INT4 NOT NULL,
    produto_id VARCHAR(25) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    estoque FLOAT8 NOT NULL DEFAULT 0,
    preco_unitario FLOAT8 NOT NULL DEFAULT 0,
    preco_compra FLOAT8 NOT NULL DEFAULT 0,
    preco_venda FLOAT8 NOT NULL DEFAULT 0,
    idfornecedor VARCHAR(25),

    CONSTRAINT produtos_filial_pkey
        PRIMARY KEY (filial_id, produto_id),

    CONSTRAINT produtos_filial_fornecedor_fkey
        FOREIGN KEY (idfornecedor)
        REFERENCES public.fornecedor (idfornecedor)
);


-- ============================================================
-- TABELA: VENDA
-- ============================================================

CREATE TABLE public.venda (
    venda_id INT8 NOT NULL,
    data_emissao DATE NOT NULL,
    horariomov VARCHAR(8),
    produto_id VARCHAR(25) NOT NULL,
    qtde_vendida FLOAT8,
    valor_unitario NUMERIC(12,4) NOT NULL,
    filial_id INT8 NOT NULL,
    item INT4 NOT NULL DEFAULT 0,
    unidade_medida VARCHAR(3),

    CONSTRAINT venda_pkey
        PRIMARY KEY (
            filial_id,
            venda_id,
            data_emissao,
            produto_id,
            item
        )
);


-- ============================================================
-- TABELA: PEDIDO_COMPRA
-- ============================================================

CREATE TABLE public.pedido_compra (
    pedido_id FLOAT8 NOT NULL,
    data_pedido DATE,
    item FLOAT8 NOT NULL DEFAULT 0,
    produto_id VARCHAR(25) NOT NULL DEFAULT '0',
    descricao_produto VARCHAR(255),
    ordem_compra FLOAT8 NOT NULL DEFAULT 0,
    qtde_pedida FLOAT8,
    filial_id INT4,
    data_entrega DATE,
    qtde_entregue FLOAT8 NOT NULL DEFAULT 0,
    preco_compra FLOAT8 NOT NULL DEFAULT 0,
    fornecedor_id INT4 DEFAULT 0,

    CONSTRAINT pedido_compra_pkey
        PRIMARY KEY (
            pedido_id,
            produto_id,
            item
        )
);


-- ============================================================
-- TABELA: ENTRADAS_MERCADORIA
-- ============================================================

CREATE TABLE public.entradas_mercadoria (
    data_entrada DATE,
    nro_nfe VARCHAR(25) NOT NULL,
    item FLOAT8 NOT NULL DEFAULT 0,
    produto_id VARCHAR(25) NOT NULL DEFAULT '0',
    descricao_produto VARCHAR(255),
    ordem_compra FLOAT8 NOT NULL DEFAULT 0,
    qtde_recebida FLOAT8,
    filial_id INT4,
    custo_unitario NUMERIC(12,4) NOT NULL DEFAULT 0,

    CONSTRAINT entradas_mercadoria_pkey
        PRIMARY KEY (
            ordem_compra,
            item,
            produto_id,
            nro_nfe
        )
);