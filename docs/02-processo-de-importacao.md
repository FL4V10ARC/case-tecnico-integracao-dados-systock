# 2. Processo de Importação dos Dados

## 2.1 Objetivo

O processo de importação teve como objetivo carregar os dados fornecidos no arquivo `base_teste_systock.xlsx` para uma base PostgreSQL local, preservando os dados de origem e permitindo a execução das análises e validações solicitadas no case técnico.

A importação foi realizada de forma controlada, considerando a estrutura das planilhas, os tipos de dados esperados e os relacionamentos entre as entidades.

---

## 2.2 Fonte dos dados

A base recebida foi disponibilizada em formato Excel (`.xlsx`) contendo as seguintes planilhas:

| Planilha              | Finalidade                           |
| --------------------- | ------------------------------------ |
| `venda`               | Registros de vendas realizadas       |
| `pedido_compra`       | Pedidos de compra realizados         |
| `entradas_mercadoria` | Entradas/recebimentos de mercadorias |
| `produtos_filial`     | Cadastro de produtos por filial      |
| `fornecedor`          | Cadastro de fornecedores             |

O arquivo original foi preservado no projeto em:

```text
data/original/base_teste_systock.xlsx
```

---

## 2.3 Ferramentas utilizadas

Foram utilizadas as seguintes ferramentas durante o processo:

- **Microsoft Excel** — inspeção inicial da estrutura e dos dados recebidos;
- **DBeaver Community** — administração da base PostgreSQL e execução das consultas;
- **PostgreSQL 18.3** — banco de dados utilizado para armazenamento, tratamento e validação;
- **PowerShell** — execução de comandos auxiliares e geração do backup;
- **Git/GitHub** — versionamento e disponibilização do projeto.

O DBeaver foi utilizado como ferramenta de administração e análise da base PostgreSQL. Como a importação direta do arquivo `.xlsx` não foi utilizada, as planilhas foram convertidas para arquivos CSV antes da carga.

---

## 2.4 Preparação dos dados

O arquivo Excel foi analisado inicialmente para identificação:

- das planilhas disponíveis;
- dos nomes das colunas;
- dos tipos de informação armazenados;
- dos campos utilizados como identificadores;
- dos possíveis relacionamentos entre as tabelas;
- de valores nulos;
- de inconsistências de estrutura ou conteúdo.

Após essa análise, cada planilha foi convertida para CSV, mantendo os dados originais para utilização durante a carga.

Os arquivos processados foram armazenados em:

```text
data/processed/
```

Com os seguintes arquivos:

```text
fornecedor.csv
produtos_filial.csv
venda.csv
pedido_compra.csv
entradas_mercadoria.csv
```

---

## 2.5 Mapeamento dos dados

O mapeamento foi realizado entre os arquivos CSV processados e as respectivas tabelas PostgreSQL.

| Arquivo                   | Tabela PostgreSQL     |
| ------------------------- | --------------------- |
| `fornecedor.csv`          | `fornecedor`          |
| `produtos_filial.csv`     | `produtos_filial`     |
| `venda.csv`               | `venda`               |
| `pedido_compra.csv`       | `pedido_compra`       |
| `entradas_mercadoria.csv` | `entradas_mercadoria` |

Os campos foram carregados considerando os tipos definidos no script:

```text
database/01-create-tables.sql
```

---

## 2.6 Ordem de criação e carga

A estrutura da base foi criada antes da importação dos dados.

A sequência utilizada foi:

```text
1. Criação das tabelas
        ↓
2. Importação dos dados
        ↓
3. Validação da quantidade de registros
        ↓
4. Validação de valores nulos
        ↓
5. Validação de valores negativos
        ↓
6. Validação dos relacionamentos
        ↓
7. Identificação das inconsistências
        ↓
8. Execução das consultas solicitadas
        ↓
9. Implementação e validação da trigger
```

A criação das tabelas está documentada em:

```text
database/01-create-tables.sql
```

A carga dos dados está documentada em:

```text
database/02-import-data.sql
```

---

## 2.7 Critérios de importação

Durante a carga, foram considerados os seguintes critérios:

- preservação dos valores fornecidos na base original;
- manutenção dos identificadores existentes;
- conversão dos campos para os tipos compatíveis com PostgreSQL;
- utilização de datas no formato apropriado para o banco;
- manutenção das quantidades e valores financeiros sem alterações arbitrárias;
- respeito às chaves primárias definidas no modelo;
- preservação dos registros mesmo quando posteriormente identificados como inconsistentes.

As inconsistências encontradas durante a análise não foram corrigidas automaticamente sem uma regra de negócio que justificasse a alteração.

Quando uma inconsistência foi identificada, ela foi registrada e analisada separadamente.

---

## 2.8 Validação após a carga

Após a importação, foram executadas validações para confirmar que os dados estavam disponíveis corretamente no banco.

Foram verificadas, entre outras informações:

- quantidade de registros por tabela;
- existência de valores nulos;
- existência de valores negativos;
- integridade dos identificadores;
- relacionamento entre produtos e fornecedores;
- relacionamento entre pedidos e entradas de mercadoria;
- consistência das datas;
- divergências de quantidade;
- produtos vendidos sem cadastro correspondente.

As consultas utilizadas para essas verificações estão disponíveis em:

```text
database/03-fixes-and-validations.sql
database/07-client-validation.sql
```

As evidências das validações estão disponíveis em:

```text
evidence/
```

---

## 2.9 Tratamento das inconsistências

A análise identificou inconsistências na própria base recebida.

Entre os principais casos identificados estão:

- produtos presentes em `venda` sem cadastro correspondente em `produtos_filial`;
- registros de venda utilizando filiais não presentes no cadastro de produtos;
- pedidos com `ordem_compra = 0`;
- entradas de mercadoria sem pedido de compra correspondente;
- registros em que `data_entrega` é anterior à `data_pedido`;
- divergências entre quantidades pedidas e recebidas;
- diferença de representação entre identificadores de fornecedores.

Esses casos foram mantidos como evidências da qualidade da base recebida e documentados no projeto.

Detalhamento:

```text
docs/03-erros-e-inconsistencias.md
```

---

## 2.10 Princípio de rastreabilidade

O processo foi estruturado para permitir rastreabilidade entre a informação recebida e o resultado produzido.

O fluxo adotado foi:

```text
Dado recebido
      ↓
Análise
      ↓
Regra de negócio
      ↓
SQL / Tratamento
      ↓
Validação
      ↓
Evidência
      ↓
Resultado
```

Dessa forma, os resultados apresentados no case podem ser relacionados às consultas SQL, às regras utilizadas e às respectivas evidências.

---

## 2.11 Critério de conclusão da importação

A etapa de importação foi considerada concluída após:

1. criação das tabelas PostgreSQL;
2. carga dos cinco conjuntos de dados;
3. conferência dos volumes importados;
4. execução das validações iniciais;
5. confirmação de que os dados estavam disponíveis para análise;
6. registro das inconsistências identificadas.

Após essa etapa, a base passou a ser utilizada para as consultas, transformações, validações e implementação da trigger solicitadas no case técnico.

---

## 2.12 Scripts relacionados

| Script                         | Objetivo                                      |
| ------------------------------ | --------------------------------------------- |
| `01-create-tables.sql`         | Criação da estrutura da base                  |
| `02-import-data.sql`           | Importação dos dados                          |
| `03-fixes-and-validations.sql` | Validações e identificação de inconsistências |
| `04-basic-queries.sql`         | Consultas principais do case                  |
| `05-transformations.sql`       | Transformações solicitadas                    |
| `06-trigger.sql`               | Implementação da trigger                      |
| `07-client-validation.sql`     | Validação final da solução                    |

---

## 2.13 Resultado

Ao final do processo, os dados fornecidos foram disponibilizados em PostgreSQL e submetidos às etapas de análise e validação previstas no case.

O processo manteve a separação entre:

- **dados recebidos**;
- **inconsistências identificadas**;
- **regras de negócio**;
- **tratamentos aplicados**;
- **consultas solicitadas**;
- **validações realizadas**.

Essa abordagem permite reproduzir o processo e rastrear a origem dos resultados apresentados na entrega.
