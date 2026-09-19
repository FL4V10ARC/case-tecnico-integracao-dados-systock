# Case Técnico — Analista de Integração de Dados (Implantação)

Projeto desenvolvido como solução para o case técnico de **Analista de Integração de Dados (Implantação)** da Systock.

O objetivo é demonstrar o processo de análise, importação, tratamento, validação e consulta de dados utilizando **PostgreSQL e SQL**, com foco em qualidade de dados, integridade, rastreabilidade e validação dos resultados.

---

## Sobre o projeto

O projeto utiliza uma base de dados fornecida em formato Excel contendo informações relacionadas a:

- vendas;
- pedidos de compra;
- entradas de mercadoria;
- produtos por filial;
- fornecedores.

A solução foi estruturada para reproduzir um cenário de integração de dados, considerando tanto a estrutura esperada quanto as inconsistências identificadas na fonte recebida.

A base original é preservada sem alterações, enquanto os tratamentos, consultas, validações e evidências são organizados separadamente no projeto.

---

## Objetivos

- Analisar a estrutura e a qualidade dos dados recebidos;
- Identificar inconsistências e problemas de integridade;
- Modelar os dados em um banco PostgreSQL;
- Importar os dados para o banco;
- Aplicar tratamentos e validações utilizando SQL;
- Desenvolver as consultas solicitadas no case;
- Implementar as transformações e automações necessárias;
- Documentar as decisões tomadas durante o processo;
- Validar os resultados obtidos;
- Manter evidências das principais etapas;
- Gerar um backup do banco ao final do processo.

---

## Tecnologias

- DBeaver
- PostgreSQL
- SQL
- Git
- GitHub
- Microsoft Excel

---

## Estrutura do projeto

```text
case-tecnico-integracao-dados-systock/

├── README.md
├── .gitignore
│
├── docs/
│   ├── 01-entendimento-do-case.md
│   ├── 02-processo-de-importacao.md
│   ├── 03-erros-e-inconsistencias.md
│   ├── 04-regras-de-negocio.md
│   ├── 05-estrategia-de-validacao.md
│   └── 06-resultados.md
│
├── database/
│   ├── 01-create-tables.sql
│   ├── 02-import-data.sql
│   ├── 03-fixes-and-validations.sql
│   ├── 04-basic-queries.sql
│   ├── 05-transformations.sql
│   ├── 06-trigger.sql
│   └── 07-client-validation.sql
│
├── data/
│   ├── original/
│   │   └── base_teste_systock.xlsx
│   └── processed/
│       ├── fornecedor.csv
│       ├── produtos_filial.csv
│       ├── venda.csv
│       ├── pedido_compra.csv
│       └── entradas_mercadoria.csv
│
├── backup/
│
└── evidence/
```

---

## Processo da solução

O desenvolvimento segue um fluxo de implantação dividido em etapas:

```text
Base recebida
      ↓
Análise da estrutura
      ↓
Análise da qualidade dos dados
      ↓
Identificação das inconsistências
      ↓
Definição das regras de tratamento
      ↓
Modelagem PostgreSQL
      ↓
Importação dos dados
      ↓
Validações e identificação de inconsistências
      ↓
Consultas SQL
      ↓
Transformações
      ↓
Automação com Trigger
      ↓
Validação dos resultados
      ↓
Backup
```

---

## Análise da qualidade dos dados

Durante a análise da base foram realizadas verificações relacionadas a:

- quantidade de registros;
- valores nulos;
- valores negativos;
- registros duplicados;
- produtos sem cadastro correspondente;
- cobertura de produtos por filial;
- ordens de compra sem identificação;
- entradas de mercadoria sem pedido correspondente;
- inconsistências entre datas;
- divergências entre quantidades solicitadas e recebidas;
- identificação e relacionamento de fornecedores.

As inconsistências encontradas foram documentadas antes da aplicação de qualquer tratamento.

---

## Principais inconsistências identificadas

Entre as inconsistências encontradas na base estão:

- produtos presentes nas vendas sem cadastro correspondente em `produtos_filial`;
- vendas associadas a filiais sem cobertura correspondente no cadastro de produtos;
- pedidos de compra com `ordem_compra = 0`;
- entradas de mercadoria sem pedido de compra correspondente;
- datas de entrega anteriores às respectivas datas do pedido;
- divergências entre quantidades registradas no pedido e quantidades recebidas;
- diferenças entre a identificação do fornecedor na fonte e a estrutura utilizada no banco.

As evidências dessas ocorrências estão armazenadas na pasta `evidence/`.

A documentação detalhada está disponível em:

`docs/03-erros-e-inconsistencias.md`

---

## Regras de negócio

As principais regras utilizadas durante a implementação incluem:

- identificação de produtos por `produto_id`;
- relacionamento entre produto e filial;
- cálculo do consumo por produto;
- análise do período de fevereiro de 2025;
- identificação de produtos solicitados e não recebidos;
- concatenação de código e descrição do produto;
- apresentação de datas no formato `DD/MM/YYYY`;
- identificação de produtos requisitados mais de 10 vezes;
- relacionamento entre produtos e fornecedores;
- preenchimento automático do identificador numérico do fornecedor no cadastro de produtos;
- validação das quantidades solicitadas e recebidas;
- preservação dos dados originais quando não existe regra suficiente para determinar uma correção.

As regras estão documentadas em:

`docs/04-regras-de-negocio.md`

---

## Consultas e resultados

As consultas SQL foram organizadas em arquivos específicos para facilitar a reprodução do processo.

Entre os resultados obtidos estão:

### Consumo por produto em fevereiro de 2025

Foi realizada a consolidação da quantidade consumida e do valor total por produto para o período solicitado no case.

### Produtos solicitados, mas não recebidos

Foi realizada a identificação dos pedidos que não apresentaram quantidade recebida.

### Transformações

Foram implementadas transformações para:

- concatenar `produto_id` e descrição;
- formatar datas para `DD/MM/YYYY`;
- identificar produtos requisitados mais de 10 vezes.

### Automação

Foi implementada uma trigger para preenchimento automático do identificador numérico do fornecedor na tabela de produtos.

A trigger foi testada utilizando uma operação controlada com `ROLLBACK`, garantindo que o registro utilizado no teste não permanecesse na base.

Os resultados detalhados estão disponíveis em:

`docs/06-resultados.md`

---

## Validação da implantação

A validação final é realizada por meio de consultas SQL no PostgreSQL, permitindo verificar a integridade dos dados importados, os relacionamentos entre as tabelas, as inconsistências identificadas e as transformações aplicadas durante o processo.

### Validação da quantidade de registros

A primeira etapa da validação consistiu em comparar a quantidade de registros carregados no banco com a quantidade esperada para cada tabela.

| Tabela              | Registros |
| ------------------- | --------: |
| fornecedor          |        20 |
| produtos_filial     |        20 |
| venda               |        33 |
| pedido_compra       |        29 |
| entradas_mercadoria |        20 |

Os resultados obtidos correspondem às quantidades esperadas para as tabelas analisadas.

**Evidência:**

![Validação da quantidade de registros](evidence/17-4.1-validacao-quantidade-registros.png)

---

### Validação de valores nulos

Foi realizada uma verificação das tabelas `venda`, `pedido_compra` e `entradas_mercadoria` para identificar registros sem `produto_id`.

A consulta não identificou registros com valor nulo no campo analisado.

| Tabela              | Registros sem produto |
| ------------------- | --------------------: |
| venda               |                     0 |
| pedido_compra       |                     0 |
| entradas_mercadoria |                     0 |

**Evidência:**

![Validação de valores nulos](evidence/18-4.2-validacao-valores-nulos.png)

---

### Validação de valores negativos

Foi realizada uma verificação das tabelas `venda`, `pedido_compra`, `entradas_mercadoria` e `produtos_filial` para identificar quantidades, preços e valores financeiros negativos.

A consulta não identificou registros com valores negativos nos campos analisados.

| Tabela              | Registros com valor negativo |
| ------------------- | ---------------------------: |
| venda               |                            0 |
| pedido_compra       |                            0 |
| entradas_mercadoria |                            0 |
| produtos_filial     |                            0 |

**Evidência:**

![Validação de valores negativos](evidence/19-4.3-validacao-valores-negativos.png)

---

### Validação de produtos vendidos sem cadastro

Foi realizada uma validação para identificar produtos presentes na tabela `venda` que não possuem cadastro correspondente na tabela `produtos_filial`.

Foram identificados 8 produtos sem cadastro correspondente:

| Produto |
| ------- |
| P21     |
| P22     |
| P23     |
| P24     |
| P25     |
| P26     |
| P27     |
| P28     |

Essa ocorrência já havia sido identificada durante a análise inicial da qualidade dos dados e foi mantida como inconsistência documentada, sem criação de cadastros fictícios.

**Evidência:**

![Produtos vendidos sem cadastro](evidence/20-4.4-produtos-vendidos-sem-cadastro.png)

---

### Validação de entradas de mercadoria sem pedido de compra

Foi realizada uma validação para identificar entradas de mercadoria que não possuem um pedido de compra correspondente.

Foram identificadas duas ocorrências:

| Ordem de compra | NF-e  | Produto | Quantidade recebida |
| --------------: | ----- | ------- | ------------------: |
|              19 | NFE19 | P19     |                  64 |
|              20 | NFE20 | P20     |                   6 |

Essas ocorrências foram identificadas durante a análise inicial da qualidade dos dados e permanecem documentadas como inconsistências da fonte.

**Evidência:**

![Entradas de mercadoria sem pedido](evidence/21-4.5-entradas-sem-pedido.png)

---

### Validação de divergência entre pedido e recebimento

Foi realizada uma comparação entre as quantidades registradas nos pedidos de compra e as quantidades encontradas nas entradas de mercadoria.

A validação identificou 18 registros com divergência entre `qtde_entregue` registrada no pedido e a soma de `qtde_recebida` nas entradas de mercadoria.

A consulta também permite comparar a quantidade originalmente solicitada (`qtde_pedida`) com os valores registrados durante o processo de recebimento.

As divergências foram mantidas como evidências da qualidade da fonte e não foram corrigidas sem uma regra de negócio ou validação do responsável pelo processo.

**Evidência:**

![Divergência entre pedido e recebimento](evidence/22-4.6-divergencia-pedido-recebimento.png)

---

### Validação de inconsistências temporais

Foi realizada uma validação para identificar pedidos em que a `data_entrega` é anterior à `data_pedido`.

Foram identificados 20 registros com essa inconsistência temporal.

A ocorrência foi mantida como evidência da qualidade da fonte, sem alteração das datas originais, uma vez que não existe informação suficiente para determinar qual seria a data correta.

**Evidência:**

![Inconsistências temporais](evidence/23-4.7-inconsistencia-temporal.png)

---

### Validação do relacionamento entre produto e fornecedor

Foi realizada uma validação do relacionamento entre os produtos cadastrados e seus respectivos fornecedores.

A consulta apresentou os 20 produtos cadastrados, permitindo verificar o `idfornecedor`, o identificador numérico associado e a razão social correspondente.

A validação demonstrou a correspondência entre os registros de produtos e fornecedores cadastrados.

**Evidência:**

![Relacionamento entre produto e fornecedor](evidence/24-4.8-relacionamento-produto-fornecedor.png)

---

### Validação da integridade do identificador numérico do fornecedor

Foi realizada uma validação para identificar produtos sem `idfornecedor_numerico` ou com fornecedor não localizado no cadastro.

A consulta não retornou registros, indicando que todos os produtos analisados possuem um identificador numérico de fornecedor válido e relacionado ao cadastro correspondente.

**Resultado:** 0 inconsistências encontradas.

**Evidência:**

![Integridade do ID numérico do fornecedor](evidence/25-4.9-integridade-idfornecedor-numerico.png)

---

### Validação dos identificadores de fornecedor

Foi realizada uma validação do cadastro de fornecedores para verificar a correspondência entre o identificador original (`idfornecedor`) e o identificador numérico (`idfornecedor_numerico`).

Os 20 fornecedores apresentaram correspondência entre os identificadores e suas respectivas razões sociais.

| Identificador | ID numérico | Razão social       |
| ------------- | ----------: | ------------------ |
| F1            |           1 | Fornecedor 1 LTDA  |
| F2            |           2 | Fornecedor 2 LTDA  |
| F3            |           3 | Fornecedor 3 LTDA  |
| ...           |         ... | ...                |
| F20           |          20 | Fornecedor 20 LTDA |

**Evidência:**

![Identificadores de fornecedor](evidence/26-4.10-identificadores-fornecedor.png)

---

### Validação dos identificadores dos produtos

Foi realizada uma validação final da tabela `produtos_filial` para verificar o preenchimento dos identificadores de fornecedor.

Os 20 produtos analisados apresentam `idfornecedor` e `idfornecedor_numerico` preenchidos, mantendo a correspondência entre o identificador original e o identificador numérico.

**Evidência:**

![Validação dos identificadores dos produtos](evidence/27-4.11-validacao-identificadores-produtos.png)

---

## Evidências

As evidências das principais etapas do projeto estão armazenadas na pasta:

```text
evidence/
```

As evidências incluem:

- auditoria inicial da base;
- identificação de inconsistências;
- resultados das consultas SQL;
- transformações realizadas;
- testes da trigger;
- validações da implantação.

A numeração das evidências segue a ordem cronológica de execução das etapas.

---

## Documentação

A documentação do projeto está organizada em etapas:

| Documento                       | Conteúdo                                              |
| ------------------------------- | ----------------------------------------------------- |
| `01-entendimento-do-case.md`    | Entendimento inicial, fonte e estrutura dos dados     |
| `02-processo-de-importacao.md`  | Estratégia e processo de importação                   |
| `03-erros-e-inconsistencias.md` | Problemas e inconsistências identificados na base     |
| `04-regras-de-negocio.md`       | Regras utilizadas para tratamento e validação         |
| `05-estrategia-de-validacao.md` | Estratégia de validação com o cliente                 |
| `06-resultados.md`              | Resultados das consultas, transformações e validações |

---

## Banco de dados

Os scripts SQL estão organizados conforme a sequência lógica de execução:

1. `01-create-tables.sql` — criação das tabelas;
2. `02-import-data.sql` — processo de importação;
3. `03-fixes-and-validations.sql` — validações e identificação de inconsistências;
4. `04-basic-queries.sql` — consultas solicitadas no case;
5. `05-transformations.sql` — transformações dos dados;
6. `06-trigger.sql` — automação relacionada ao fornecedor;
7. `07-client-validation.sql` — consultas de validação final.

---

## Qualidade e rastreabilidade

A base original é preservada sem alterações.

As inconsistências encontradas são documentadas antes da aplicação de qualquer tratamento.

Quando não existe informação suficiente para determinar o valor correto de um dado, o valor original é preservado e a ocorrência é sinalizada para validação.

A rastreabilidade do projeto é mantida por meio da relação entre:

```text
Dado recebido
      ↓
Análise
      ↓
Regra de tratamento
      ↓
Implementação SQL
      ↓
Validação
      ↓
Evidência
      ↓
Resultado
```

Essa abordagem permite acompanhar as decisões tomadas durante a implantação e reproduzir as etapas executadas.

---

## Backup

Antes da disponibilização definitiva da base, será realizado um backup completo do banco PostgreSQL utilizando `pg_dump`.

Exemplo:

```bash
pg_dump -h localhost -p 5433 -U postgres -d systock_case -F c -f backup/systock_case_backup.dump
```

O backup será armazenado em local controlado e utilizado como mecanismo de recuperação da base em caso de necessidade.

---

## Status

✅ **Projeto concluído tecnicamente**

Etapas realizadas:

- análise da estrutura da base;
- análise da qualidade dos dados;
- identificação das inconsistências;
- modelagem do banco PostgreSQL;
- importação dos dados;
- consultas solicitadas no case;
- transformações;
- implementação e teste da trigger;
- documentação das regras de negócio;
- documentação da estratégia de validação;
- validações finais da base;
- geração das evidências das validações.

### Próximas etapas

- realizar o backup final do banco PostgreSQL;
- revisar a documentação;
- verificar a integridade dos arquivos do projeto;
- revisar o `.gitignore`;
- executar a revisão final do Git;
- realizar o commit final;
- publicar a versão final no GitHub.

---
