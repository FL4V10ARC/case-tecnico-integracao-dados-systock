# 5. Estratégia de Validação

## 5.1 Objetivo

A etapa de validação tem como objetivo confirmar, junto ao cliente, que os dados foram importados corretamente, que as regras de negócio foram aplicadas conforme definido e que as inconsistências identificadas durante a implantação foram devidamente documentadas.

A validação deve ocorrer antes da disponibilização definitiva dos dados para utilização operacional.

---

## 5.2 Estratégia de validação

A validação será realizada em etapas, permitindo comparar os dados da origem com os dados carregados no banco de dados.

O processo considera:

1. validação da quantidade de registros;
2. validação dos valores nulos;
3. validação dos valores negativos;
4. validação das chaves e relacionamentos;
5. validação das inconsistências identificadas;
6. validação dos resultados das consultas solicitadas no case;
7. validação das transformações realizadas;
8. validação das automações implementadas;
9. realização de backup antes da disponibilização definitiva.

---

## 5.3 Validação da quantidade de registros

A primeira validação consiste em comparar a quantidade de registros existente na origem com a quantidade de registros carregada no banco.

As tabelas analisadas são:

- `venda`;
- `pedido_compra`;
- `entradas_mercadoria`;
- `produtos_filial`;
- `fornecedor`.

Essa validação permite identificar possíveis perdas ou duplicações durante o processo de importação.

---

## 5.4 Validação de valores nulos

Devem ser verificadas as colunas consideradas obrigatórias pelo modelo de dados.

A existência de valores nulos em campos obrigatórios pode indicar falha na importação ou inconsistência na origem.

---

## 5.5 Validação de valores negativos

Quantidades e valores financeiros devem ser analisados para identificar registros com valores negativos que possam comprometer os resultados das consultas ou regras de negócio.

Os registros identificados devem ser avaliados de acordo com o contexto do processo antes de qualquer correção.

---

## 5.6 Validação dos relacionamentos

Os relacionamentos entre as tabelas devem ser verificados por meio de consultas SQL.

Entre as principais validações estão:

- produtos vendidos sem cadastro correspondente;
- entradas de mercadoria sem pedido de compra correspondente;
- relacionamento entre produto e fornecedor;
- divergência entre quantidade solicitada e quantidade recebida.

---

## 5.7 Validação das regras de negócio

Após a implementação das consultas e transformações, os resultados devem ser apresentados ao cliente para validação.

Entre os principais pontos estão:

- consumo por produto no período solicitado;
- produtos solicitados e não recebidos;
- concatenação de produto e descrição;
- formatação das datas;
- produtos requisitados mais de 10 vezes;
- geração automática do identificador numérico do fornecedor.

---

## 5.8 Validação das inconsistências

As inconsistências identificadas durante a análise não devem ser corrigidas sem uma regra definida ou aprovação do responsável pelo processo.

Cada inconsistência deve possuir:

- identificação;
- descrição;
- evidência;
- impacto;
- regra de tratamento;
- resultado da validação.

Esse procedimento garante rastreabilidade durante a implantação.

---

## 5.9 Reunião de validação com o cliente

Durante a reunião de validação, recomenda-se apresentar:

1. quantidade de registros importados;
2. principais inconsistências encontradas;
3. regras de negócio aplicadas;
4. resultados das consultas solicitadas;
5. transformações realizadas;
6. automações implementadas;
7. pontos que dependem de decisão do cliente.

Após a apresentação, o cliente deve confirmar se os resultados estão de acordo com as regras esperadas para o processo.

---

## 5.10 Critérios para aprovação

A implantação poderá ser considerada validada quando:

- as quantidades de registros forem conferidas;
- os campos obrigatórios estiverem consistentes;
- os relacionamentos principais forem validados;
- as inconsistências estiverem documentadas;
- as consultas solicitadas apresentarem resultados coerentes;
- as transformações forem verificadas;
- as automações forem testadas;
- o backup da base estiver disponível.

---

## 5.11 Backup

Antes da disponibilização definitiva da base, deve ser realizado um backup completo do banco de dados.

O backup deve permitir a recuperação dos dados caso seja necessário restaurar a base para uma situação anterior à implantação.

Para o PostgreSQL, recomenda-se utilizar o `pg_dump` para gerar o arquivo de backup.

Exemplo:

```bash
pg_dump -h localhost -p 5433 -U postgres -d systock_case -F c -f backup/systock_case_backup.dump
```

O arquivo gerado deve ser armazenado em local seguro e controlado.

---

## 5.12 Rastreabilidade

Todas as consultas, transformações, regras e evidências utilizadas durante a implantação estão organizadas no repositório.

A estrutura permite identificar:

- a origem dos dados;
- as regras utilizadas;
- as inconsistências encontradas;
- as consultas executadas;
- as transformações aplicadas;
- os testes realizados;
- as evidências geradas.

Dessa forma, o processo de implantação permanece documentado e reproduzível.
