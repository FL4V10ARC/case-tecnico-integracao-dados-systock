# 1. Entendimento do Case

## 1.1 Objetivo

O objetivo deste projeto é analisar, importar, tratar, validar e consultar uma base de dados fornecida para o case técnico de Analista de Integração de Dados (Implantação).

A solução utiliza PostgreSQL como banco de dados e SQL como principal ferramenta para construção das consultas, transformações e validações solicitadas.

O processo considera a identificação de inconsistências presentes tanto na estrutura fornecida quanto nos dados recebidos, documentando os tratamentos e decisões adotadas.

## 1.2 Fontes de dados

A fonte de dados disponibilizada para o projeto é o arquivo:

`base_teste_systock.xlsx`

A planilha contém cinco abas:

| Aba                 | Registros | Finalidade                                               |
| ------------------- | --------: | -------------------------------------------------------- |
| venda               |        33 | Registros de vendas                                      |
| pedido_compra       |        29 | Pedidos de compra realizados                             |
| entradas_mercadoria |        20 | Registros de mercadorias recebidas                       |
| produtos_filial     |        20 | Cadastro de produtos e informações de estoque por filial |
| fornecedor          |        20 | Cadastro de fornecedores                                 |

## 1.3 Relacionamentos identificados

O relacionamento principal entre pedidos de compra e entradas de mercadoria ocorre por meio do campo `ordem_compra`.

A estrutura conceitual identificada é:

`fornecedor → produtos_filial → venda`

e:

`produtos_filial → pedido_compra → entradas_mercadoria`

O relacionamento entre `pedido_compra` e `entradas_mercadoria` utiliza `ordem_compra` como elemento de ligação.

## 1.4 Estrutura dos dados

### Venda

Campos identificados:

* `venda_id`
* `data_emissao`
* `horariomov`
* `produto_id`
* `qtde_vendida`
* `valor_unitario`
* `filial_id`
* `item`
* `unidade_medida`

### Pedido de compra

Campos identificados:

* `pedido_id`
* `data_pedido`
* `item`
* `produto_id`
* `descricao_produto`
* `ordem_compra`
* `qtde_pedida`
* `filial_id`
* `data_entrega`
* `qtde_entregue`
* `preco_compra`
* `fornecedor_id`

### Entradas de mercadoria

Campos identificados:

* `data_entrada`
* `nro_nfe`
* `item`
* `produto_id`
* `descricao_produto`
* `ordem_compra`
* `qtde_recebida`
* `filial_id`
* `custo_unitario`

### Produtos por filial

Campos identificados:

* `filial_id`
* `idproduto`
* `descricao`
* `estoque`
* `preco_unitario`
* `preco_compra`
* `preco_venda`
* `idfornecedor`

### Fornecedor

Campos identificados:

* `idfornecedor`
* `razao_social`

## 1.5 Primeiras inconsistências identificadas

Durante a análise inicial foram identificadas inconsistências que deverão ser tratadas e documentadas antes da execução definitiva das consultas.

Entre elas:

* divergências entre os nomes de campos definidos no SQL de referência e os nomes efetivamente presentes na planilha;
* utilização de campos em chaves primárias que não aparecem na definição apresentada;
* produtos presentes na tabela de vendas que não possuem correspondência em `produtos_filial`;
* registros de pedidos de compra cuja `data_entrega` é anterior à `data_pedido`;
* diferença de representação dos identificadores de fornecedor entre as tabelas, com fornecedores representados no formato `F1`, `F2`, etc., enquanto os pedidos de compra utilizam identificadores numéricos.

Essas inconsistências não serão corrigidas diretamente na fonte original. Elas serão analisadas, terão regras de tratamento definidas e serão aplicadas no banco de dados durante o processo de importação e validação.

## 1.6 Estratégia de tratamento

A base original será preservada sem alterações.

O processo seguirá, de forma geral, as seguintes etapas:

1. Preservação da base original.
2. Análise da estrutura e dos tipos de dados.
3. Comparação entre a estrutura fornecida no case e os dados efetivamente recebidos.
4. Criação da estrutura corrigida no PostgreSQL.
5. Importação dos dados.
6. Execução das validações de integridade.
7. Identificação e tratamento das inconsistências.
8. Execução das consultas solicitadas no case.
9. Validação dos resultados.
10. Geração do backup final do banco analisado.

As regras específicas para cada inconsistência serão documentadas antes da aplicação dos tratamentos.
