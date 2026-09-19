# Case Técnico — Analista de Integração de Dados (Implantação)

Projeto desenvolvido como solução para o case técnico de **Analista de Integração de Dados (Implantação)** da Systock.

O objetivo é demonstrar o processo de análise, importação, tratamento, validação e consulta de dados utilizando **PostgreSQL e SQL**, com foco em qualidade de dados, integridade e rastreabilidade.

---

## Sobre o projeto

O projeto utiliza uma base de dados fornecida em formato Excel contendo informações relacionadas a:

* vendas;
* pedidos de compra;
* entradas de mercadoria;
* produtos por filial;
* fornecedores.

A solução foi estruturada para reproduzir um cenário de integração de dados, considerando tanto a estrutura esperada quanto possíveis inconsistências presentes na fonte recebida.

---

## Objetivos

* Analisar a estrutura e qualidade dos dados recebidos;
* Identificar inconsistências e problemas de integridade;
* Modelar os dados em um banco PostgreSQL;
* Importar os dados para o banco;
* Aplicar tratamentos e validações utilizando SQL;
* Desenvolver as consultas solicitadas no case;
* Documentar as decisões tomadas durante o processo;
* Validar os resultados obtidos;
* Gerar um backup do banco ao final do processo.

---

## Tecnologias

* DBeaver
* PostgreSQL
* SQL
* Git
* GitHub
* Microsoft Excel

---

## Estrutura do projeto

```text
case-tecnico-integracao-dados-systock/
│
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
│
├── backup/
└── evidence/
```

---

## Processo da solução

O desenvolvimento seguirá o fluxo:

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
Importação
      ↓
Correções e validações
      ↓
Consultas SQL
      ↓
Validação dos resultados
      ↓
Backup
```

---

## Qualidade e rastreabilidade

A base original será preservada sem alterações.

As inconsistências encontradas serão documentadas antes da aplicação de qualquer tratamento.

Quando não houver informação suficiente para determinar o valor correto de um dado, a informação original será preservada e a ocorrência será sinalizada para validação.

Essa abordagem busca manter a rastreabilidade entre:

**dado recebido → tratamento → resultado validado.**

---

## Documentação

A documentação do projeto está organizada em etapas:

| Documento                       | Conteúdo                                          |
| ------------------------------- | ------------------------------------------------- |
| `01-entendimento-do-case.md`    | Entendimento inicial, fonte e estrutura dos dados |
| `02-processo-de-importacao.md`  | Estratégia e processo de importação               |
| `03-erros-e-inconsistencias.md` | Problemas identificados na base                   |
| `04-regras-de-negocio.md`       | Regras utilizadas para tratamento e validação     |
| `05-estrategia-de-validacao.md` | Estratégia de validação com o cliente             |
| `06-resultados.md`              | Resultados finais da análise                      |

---

## Banco de dados

Os scripts SQL estão organizados conforme a sequência lógica de execução:

1. Criação das tabelas;
2. Importação dos dados;
3. Correções e validações;
4. Consultas básicas;
5. Transformações;
6. Trigger;
7. Validações finais.

---

## Status

🚧 **Em desenvolvimento**

O projeto está sendo construído de forma incremental, com documentação e versionamento das principais etapas.
