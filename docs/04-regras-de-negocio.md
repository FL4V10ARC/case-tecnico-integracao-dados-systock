# 4. Regras de Negócio

## 4.1 Objetivo

Esta etapa documenta as regras de negócio identificadas a partir
do enunciado do case, da estrutura das tabelas e da análise da
base de dados.

As regras definidas nesta etapa serão utilizadas como referência
para:

- consultas SQL;
- transformações de dados;
- validações;
- criação de relacionamentos;
- tratamento das inconsistências;
- validação dos resultados da integração.

As regras não devem ser interpretadas como correções automáticas
dos dados de origem.

Quando uma informação não puder ser determinada com segurança,
o dado original deverá ser preservado e a ocorrência deverá ser
sinalizada para validação.

---

## 4.2 Entidades envolvidas

A solução utiliza cinco entidades principais:

| Entidade | Finalidade |
|---|---|
| `venda` | Registra as movimentações de venda |
| `pedido_compra` | Registra pedidos de compra |
| `entradas_mercadoria` | Registra entradas de mercadorias |
| `produtos_filial` | Mantém o cadastro de produtos por filial |
| `fornecedor` | Mantém o cadastro de fornecedores |

---

## 4.3 Regra de identificação de produto

O identificador utilizado para representar um produto nas
movimentações é `produto_id`.

Na fonte de dados original, o campo de produto da tabela
`produtos_filial` é apresentado como `idproduto`.

Para padronização do modelo relacional, o campo foi tratado como
`produto_id`.

### Regra

O mesmo identificador de produto deve ser utilizado nas
associações entre as tabelas que representam movimentações e
cadastros de produtos.

### Tratamento

A diferença de nomenclatura entre a fonte e o modelo SQL é tratada
como transformação de estrutura, sem alteração do valor original
do identificador.

---

## 4.4 Regra de produto por filial

A tabela `produtos_filial` representa o cadastro de produtos
associado a uma determinada filial.

A identificação do cadastro é composta por:

```text
filial_id + produto_id
```

### Regra

Uma venda deve ser associada ao cadastro do produto considerando
a respectiva filial.

### Exemplo

Uma venda:

```text
filial_id = 1
produto_id = P10
```

deve ser relacionada ao cadastro:

```text
filial_id = 1
produto_id = P10
```

### Impacto

A utilização apenas de `produto_id` pode gerar associação
incorreta quando o mesmo produto possuir cadastros diferentes
entre filiais.

Por esse motivo, as validações de integridade devem considerar
`filial_id` sempre que a análise envolver o cadastro
`produtos_filial`.

---

## 4.5 Regra de cálculo do valor da venda

A tabela `venda` possui:

- `qtde_vendida`;
- `valor_unitario`.

O valor total de uma movimentação de venda será calculado por:

```text
valor_total = qtde_vendida × valor_unitario
```

### Regra

O valor total deve ser calculado a partir dos valores armazenados
na própria movimentação.

### Exemplo

Se:

```text
qtde_vendida = 10
valor_unitario = 50,00
```

então:

```text
valor_total = 500,00
```

Essa regra será utilizada na consulta de consumo e movimentação
de vendas.

---

## 4.6 Regra de período para análise de consumo

Para a análise solicitada no case, o período considerado será
fevereiro de 2025.

### Regra

Serão consideradas as vendas cuja `data_emissao` esteja entre:

```text
01/02/2025
```

e

```text
28/02/2025
```

### Consulta conceitual

A filtragem deverá considerar o campo:

```text
venda.data_emissao
```

A quantidade consumida será representada pela soma de
`qtde_vendida`.

O valor movimentado será calculado a partir de:

```text
qtde_vendida × valor_unitario
```

---

## 4.7 Regra de identificação de pedidos de compra

A tabela `pedido_compra` representa os produtos solicitados por
meio de pedidos de compra.

Os principais campos utilizados para identificar uma solicitação
são:

- `pedido_id`;
- `ordem_compra`;
- `item`;
- `produto_id`.

### Regra

A análise de um pedido deve preservar a granularidade do item e
do produto.

Não devem ser agregados registros de produtos diferentes apenas
porque possuem a mesma ordem de compra.

---

## 4.8 Regra de recebimento de mercadoria

A tabela `entradas_mercadoria` representa os recebimentos
registrados na operação.

O relacionamento principal definido no case entre pedido e entrada
é realizado por:

```text
pedido_compra.ordem_compra
        ↓
entradas_mercadoria.ordem_compra
```

### Regra

Uma entrada de mercadoria deve ser relacionada ao pedido de compra
correspondente por meio de `ordem_compra`.

Quando a análise exigir maior granularidade, também devem ser
considerados:

- `item`;
- `produto_id`.

### Observação

A existência de uma entrada de mercadoria não significa,
isoladamente, que exista um pedido de compra correspondente.

Essa condição deve ser validada por meio do relacionamento entre as
tabelas.

---

## 4.9 Regra de quantidade recebida

A quantidade registrada no recebimento é representada pelo campo:

```text
entradas_mercadoria.qtde_recebida
```

Quando houver mais de uma entrada para o mesmo pedido, item e
produto, as quantidades recebidas deverão ser consolidadas por
soma.

### Regra

```text
quantidade_recebida =
SUM(qtde_recebida)
```

considerando a chave de análise:

```text
ordem_compra + item + produto_id
```

Essa regra evita considerar apenas uma entrada quando existirem
múltiplos documentos fiscais associados ao mesmo pedido.

---

## 4.10 Regra para pedidos solicitados e não recebidos

Para identificar produtos solicitados que não foram recebidos,
deverá ser considerada a quantidade solicitada no pedido em
conjunto com a quantidade registrada como entregue/recebida.

Os campos envolvidos são:

```text
pedido_compra.qtde_pedida
pedido_compra.qtde_entregue
entradas_mercadoria.qtde_recebida
```

### Regra inicial

Um pedido será considerado não recebido quando não houver
quantidade entregue registrada ou quando não existir entrada de
mercadoria correspondente, de acordo com a regra específica da
consulta.

### Observação

A definição final deverá considerar a granularidade de:

```text
ordem_compra + item + produto_id
```

para evitar associações incorretas.

---

## 4.11 Regra de produtos requisitados mais de 10 vezes

O case solicita a identificação dos produtos que foram
requisitados mais de 10 vezes no período analisado.

### Regra

A quantidade de ocorrências de um produto será obtida a partir dos
registros da tabela `pedido_compra`.

A contagem será agrupada por:

```text
produto_id
```

e deverão ser retornados somente os produtos cuja quantidade de
ocorrências seja maior que 10.

### Regra SQL

A condição de filtragem será equivalente a:

```sql
HAVING COUNT(*) > 10
```

### Observação

A contagem representa ocorrências de requisição/pedido na base,
não a soma da quantidade física solicitada.

---

## 4.12 Regra de concatenação de produto

O case solicita a criação de uma informação combinando o
identificador do produto com sua descrição.

### Regra

O resultado deverá combinar:

```text
produto_id + descricao_produto
```

### Exemplo

Entrada:

```text
produto_id = P10
descricao_produto = Produto 10
```

Resultado esperado:

```text
P10 - Produto 10
```

### Observação

A transformação será realizada por consulta ou campo derivado,
sem necessidade de alterar o valor original dos campos de origem.

---

## 4.13 Regra de formatação das datas

As datas apresentadas nos resultados destinados à visualização
deverão utilizar o formato:

```text
DD/MM/YYYY
```

### Exemplo

Uma data armazenada no banco como:

```text
2025-02-10
```

deverá ser apresentada como:

```text
10/02/2025
```

### Regra

A formatação deve ocorrer na camada de apresentação ou na consulta
quando o objetivo for gerar um resultado formatado para análise.

O tipo original `DATE` não deverá ser convertido para texto
permanentemente apenas para atender à apresentação.

---

## 4.14 Regra de identificação de fornecedor

A tabela `fornecedor` possui:

```text
idfornecedor
razao_social
```

O identificador do fornecedor na tabela de cadastro possui formato
textual, como:

```text
F1
F2
F3
...
F20
```

A tabela `produtos_filial` também utiliza `idfornecedor` para
relacionar o produto ao fornecedor.

### Regra

O fornecedor associado ao produto deve existir na tabela
`fornecedor`.

O relacionamento utilizado é:

```text
produtos_filial.idfornecedor
        ↓
fornecedor.idfornecedor
```

---

## 4.15 Regra para geração de identificador de fornecedor

O case solicita uma solução para geração automática de um novo
identificador numérico de fornecedor e relacionamento desse
identificador com a tabela de produtos.

### Regra funcional

Quando um novo fornecedor for inserido, o banco deverá gerar
automaticamente um identificador numérico sequencial.

O identificador gerado deverá ser único.

### Regra de integridade

O identificador não deve depender da aplicação para determinar o
próximo valor.

A geração deve ocorrer no banco de dados para reduzir o risco de:

- duplicidade;
- concorrência;
- geração manual incorreta;
- conflito entre processos de inserção.

### Observação sobre a estrutura atual

A base de origem apresenta identificadores de fornecedor em formato
textual (`F1`, `F2`, etc.).

A implementação da geração automática de identificador numérico
será tratada na etapa específica de banco de dados, considerando
a necessidade de preservar a rastreabilidade com os dados de
origem.

---

## 4.16 Regra de integridade entre produto e fornecedor

Um produto cadastrado em `produtos_filial` pode possuir um
fornecedor associado por meio de `idfornecedor`.

### Regra

Quando `idfornecedor` estiver preenchido, deve existir um registro
correspondente na tabela `fornecedor`.

### Tratamento

O relacionamento deve ser protegido por integridade referencial
quando a estrutura definitiva dos identificadores estiver
estabelecida.

Não será criada uma associação para fornecedor inexistente sem
evidência suficiente.

---

## 4.17 Regra para ordens de compra com valor zero

Durante a análise da base foram identificados registros com:

```text
ordem_compra = 0
```

### Regra de tratamento

O valor `0` será interpretado como indicador de ausência de uma
ordem de compra válida, e não como uma ordem real.

### Tratamento

Os registros serão preservados.

Não será realizada substituição automática do valor.

A correção dependerá de confirmação da origem dos dados.

---

## 4.18 Regra para entradas sem pedido correspondente

Uma entrada de mercadoria cuja `ordem_compra` não esteja presente
em `pedido_compra` deverá ser classificada como entrada sem pedido
correspondente.

### Regra

```text
entradas_mercadoria.ordem_compra
```

deve possuir correspondência em:

```text
pedido_compra.ordem_compra
```

### Tratamento

A entrada será preservada e sinalizada para validação.

Não será criado automaticamente um pedido de compra inexistente.

---

## 4.19 Regra para inconsistência temporal

A data de entrega não deve ser anterior à data do pedido.

### Regra

```text
data_entrega >= data_pedido
```

### Validação

Os registros que violarem essa condição deverão ser identificados
por consulta SQL.

### Tratamento

As datas originais serão preservadas.

Nenhuma data será corrigida automaticamente sem evidência que
permita determinar o valor correto.

---

## 4.20 Regra para divergência entre pedido e recebimento

A quantidade registrada como entregue no pedido deve ser
comparada com a quantidade registrada nas entradas de mercadoria.

### Regra de comparação

A análise deverá considerar:

```text
ordem_compra
item
produto_id
```

A quantidade recebida será obtida pela soma das entradas
correspondentes.

### Regra conceitual

```text
qtde_recebida =
SUM(entradas_mercadoria.qtde_recebida)
```

Uma divergência será identificada quando:

```text
qtde_entregue <> qtde_recebida
```

### Tratamento

A divergência não será corrigida automaticamente.

O registro será preservado para análise e validação da origem.

---

## 4.21 Regra de preservação dos dados de origem

Os dados originais recebidos não devem ser sobrescritos durante a
etapa de diagnóstico.

### Regra

As transformações deverão ser realizadas de forma controlada e
rastreável.

Sempre que possível, devem ser mantidos:

- arquivo original;
- dados importados;
- consultas utilizadas;
- regras aplicadas;
- resultado das validações;
- evidências;
- alterações realizadas.

### Objetivo

Garantir rastreabilidade entre o dado recebido e o resultado
final da integração.

---

## 4.22 Regra de tratamento das inconsistências

As inconsistências identificadas devem seguir o princípio:

```text
identificar
    ↓
classificar
    ↓
definir regra
    ↓
tratar
    ↓
validar
    ↓
registrar resultado
```

### Regra

Nenhum dado será alterado somente para eliminar uma inconsistência
visual ou fazer uma consulta apresentar o resultado esperado.

Quando não houver informação suficiente para determinar o valor
correto:

1. o valor original será preservado;
2. a inconsistência será documentada;
3. o registro será sinalizado para validação;
4. a correção dependerá da confirmação da origem.

---

## 4.23 Matriz resumida de regras

| Código | Regra | Tabelas envolvidas |
|---|---|---|
| RN-001 | Produto deve possuir cadastro por filial | `venda`, `produtos_filial` |
| RN-002 | Valor da venda = quantidade × valor unitário | `venda` |
| RN-003 | Consumo deve considerar fevereiro/2025 | `venda` |
| RN-004 | Pedido deve preservar item e produto | `pedido_compra` |
| RN-005 | Entrada deve ser relacionada ao pedido por `ordem_compra` | `pedido_compra`, `entradas_mercadoria` |
| RN-006 | Quantidades recebidas devem ser consolidadas | `entradas_mercadoria` |
| RN-007 | Produtos requisitados > 10 ocorrências | `pedido_compra` |
| RN-008 | Produto + descrição devem formar informação derivada | `pedido_compra`, `produtos_filial` |
| RN-009 | Datas apresentadas em `DD/MM/YYYY` | Todas as tabelas com datas |
| RN-010 | Fornecedor do produto deve existir no cadastro | `produtos_filial`, `fornecedor` |
| RN-011 | Novo fornecedor deve receber identificador automático | `fornecedor` |
| RN-012 | `ordem_compra = 0` indica ausência de ordem válida | `pedido_compra` |
| RN-013 | Entrada sem pedido deve ser sinalizada | `entradas_mercadoria`, `pedido_compra` |
| RN-014 | Data de entrega não deve anteceder data do pedido | `pedido_compra` |
| RN-015 | Divergência entre pedido e recebimento deve ser identificada | `pedido_compra`, `entradas_mercadoria` |
| RN-016 | Dados de origem devem ser preservados | Todas as tabelas |

---

## 4.24 Critério geral para implementação

As regras documentadas nesta seção serão utilizadas como base para
a implementação das consultas SQL, transformações e mecanismos de
banco de dados solicitados no case.

A implementação deverá priorizar:

- consistência;
- rastreabilidade;
- integridade referencial;
- preservação dos dados de origem;
- validação dos resultados;
- possibilidade de reprodução do processo.

Qualquer regra que dependa de uma informação não disponível na
base deverá ser explicitamente sinalizada em vez de ser definida
por suposição.