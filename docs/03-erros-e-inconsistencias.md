# 3. Erros e Inconsistências Identificados

## 3.1 Objetivo

Esta etapa tem como objetivo identificar problemas de qualidade, integridade e consistência presentes na base de dados antes da aplicação de qualquer tratamento.

A análise foi realizada sobre as cinco entidades disponibilizadas no arquivo `base_teste_systock.xlsx`.

Nesta etapa, os dados originais não são alterados. Os problemas são apenas identificados, classificados e documentados.

---

## 3.2 Resultado da análise de qualidade

### Valores nulos

Não foram identificados valores nulos nos campos de negócio analisados das cinco tabelas.

### Duplicidades

Não foram identificados registros completamente duplicados.

Também não foram identificadas duplicidades nos principais identificadores analisados.

### Valores negativos

Não foram identificadas quantidades ou valores financeiros negativos nos campos analisados.

---

## 3.3 Produtos vendidos sem cadastro correspondente

Foram identificados produtos presentes na tabela `venda` que não possuem correspondência na tabela `produtos_filial`.

Produtos identificados:

* P21
* P22
* P23
* P24
* P25
* P26
* P27
* P28

### Impacto

A ausência desses produtos no cadastro impede a validação direta da integridade referencial entre vendas e produtos por filial.

### Tratamento

Os registros não devem ser excluídos automaticamente.

A inconsistência deverá ser mantida como ocorrência de qualidade de dados e documentada durante o processo de validação.

---

## 3.4 Filiais presentes nas vendas sem cadastro correspondente

A tabela `venda` possui registros associados às filiais 1, 2 e 3.

Entretanto, a tabela `produtos_filial` possui registros somente para a filial 1.

### Impacto

As vendas associadas às filiais 2 e 3 não conseguem estabelecer correspondência com o cadastro de produtos por filial.

### Tratamento

Os registros serão preservados e classificados como inconsistência de integridade referencial.

Não será criado automaticamente um cadastro de produto ou filial inexistente sem evidência que justifique essa criação.

---

## 3.5 Ordens de compra com valor zero

Foram identificados registros na tabela `pedido_compra` com `ordem_compra = 0`.

Esses registros apresentam também `qtde_entregue = 0`.

### Análise

O valor zero não possui correspondência com as ordens de compra registradas em `entradas_mercadoria`.

Por esse motivo, o valor será tratado inicialmente como indicador de ausência de ordem vinculada, e não substituído arbitrariamente por outro identificador.

### Tratamento

Os registros serão preservados.

A regra definitiva será utilizada nas consultas de produtos requisitados e não recebidos.

---

## 3.6 Entradas de mercadoria sem pedido correspondente

Foram identificadas entradas de mercadoria associadas às ordens de compra 19 e 20, enquanto essas ordens não possuem correspondência válida na tabela `pedido_compra`.

### Impacto

Não é possível estabelecer a rastreabilidade completa da entrada até o pedido de compra utilizando apenas o relacionamento atual.

### Tratamento

As entradas serão preservadas e classificadas como registros sem pedido de compra correspondente.

A ocorrência será considerada nas validações de integridade da integração.

---

## 3.7 Inconsistência temporal

Foram identificados registros de `pedido_compra` em que `data_entrega` é anterior a `data_pedido`.

Essa situação representa uma inconsistência temporal, pois a entrega está registrada antes da realização do pedido.

### Tratamento

As datas não serão alteradas automaticamente.

Como não existe informação suficiente para determinar qual seria a data correta, os registros serão apenas sinalizados para validação.

A correção deverá ser realizada somente mediante confirmação da origem dos dados ou do responsável pelo processo.

---

## 3.8 Divergências entre pedido e recebimento

Foi observada diferença entre as quantidades registradas em `pedido_compra.qtde_entregue` e `entradas_mercadoria.qtde_recebida`.

A comparação não deve ser realizada apenas por `ordem_compra`, pois a análise precisa considerar a granularidade dos itens, produtos e documentos fiscais.

### Tratamento

Antes de qualquer correção, será definido o relacionamento entre pedido, item, produto, ordem de compra e entrada de mercadoria.

A regra de comparação será documentada posteriormente para evitar alterações baseadas em uma associação incorreta.

---

## 3.9 Divergência entre estrutura SQL e fonte de dados

Também foram identificadas diferenças entre os nomes e definições apresentados na estrutura SQL de referência e os campos efetivamente presentes na planilha.

Exemplos incluem diferenças de nomenclatura de campos e referências a campos utilizados em chaves que não aparecem na definição apresentada.

### Tratamento

A estrutura SQL fornecida será utilizada como referência, mas o modelo definitivo será construído com base na estrutura efetivamente recebida, após análise das relações e regras de negócio.

As divergências serão documentadas antes da criação definitiva das tabelas.

---

## 3.10 Princípio de tratamento

As inconsistências não serão corrigidas de maneira arbitrária.

Para cada ocorrência serão considerados:

1. identificação do problema;
2. impacto no processo;
3. possibilidade de determinar a informação correta;
4. regra de tratamento;
5. execução do tratamento;
6. validação do resultado;
7. registro da decisão.

Quando não houver informação suficiente para determinar o valor correto, o dado original será preservado e a inconsistência será sinalizada para validação.
