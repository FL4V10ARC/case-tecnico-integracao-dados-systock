# Case Técnico --- Analista de Integração de Dados (Implantação)

Projeto desenvolvido como solução para o case técnico de **Analista de
Integração de Dados (Implantação)** da Systock.

Demonstra o processo de análise, importação, tratamento, validação e
consulta de dados utilizando **PostgreSQL e SQL**, com foco em qualidade
de dados, integridade, rastreabilidade e validação dos resultados.

---

## Sobre o projeto

A base foi fornecida em Excel, com dados de vendas, pedidos de compra,
entradas de mercadoria, produtos por filial e fornecedores.

A base original é preservada sem alterações. Tratamentos, consultas,
validações e evidências ficam organizados separadamente no projeto,
permitindo rastrear qualquer resultado de volta ao dado de origem.

## Tecnologias

DBeaver · PostgreSQL 18 · SQL · Git/GitHub · Microsoft Excel

## Estrutura do projeto

```text
case-tecnico-integracao-dados-systock/
├── README.md
├── docs/                  # documentação detalhada
├── database/              # scripts SQL, na ordem de execução
├── data/
│   ├── original/base_teste_systock.xlsx
│   └── processed/*.csv
├── backup/systock_case_backup.dump
└── evidence/              # prints de cada etapa/validação
```

---

## Principais inconsistências identificadas na base

O case avisa que contém erros intencionais. Os principais achados:

- **Produtos vendidos sem cadastro**: P21--P28 aparecem em `venda` mas
  não existem em `produtos_filial`.
- **Filiais sem cobertura**: `venda` movimenta as filiais 1, 2 e 3;
  `produtos_filial` só cadastra a filial 1.
- **`ordem_compra = 0`**: 11 registros de `pedido_compra` com
  referência corrompida.
- **Entradas sem pedido correspondente**: P19 e P20 foram recebidos em
  `entradas_mercadoria` sob uma ordem de compra diferente da
  registrada no pedido --- não é ausência real de recebimento, é
  inconsistência de relacionamento.
- **Divergência pedido × recebimento**: 18 registros com
  `qtde_entregue` diferente da soma de `qtde_recebida`.
- **Inconsistência temporal**: 20 registros com `data_entrega`
  anterior a `data_pedido`.

Nenhuma dessas inconsistências foi corrigida automaticamente --- todas
foram documentadas para validação com o responsável pelo processo.

Detalhamento completo:
[`docs/03-erros-e-inconsistencias.md`](docs/03-erros-e-inconsistencias.md)

---

## Consultas e resultados

---

Requisito do case Script Resultado resumido

---

Consumo por produto `database/04-basic-queries.sql` 14 produtos com
(fev/2025) movimentação no período

Produtos requisitados e `database/04-basic-queries.sql` 11 registros, com nota
não recebidos sobre P19/P20

Concatenação produto + `database/05-transformations.sql` ---
descrição

Formatação de datas `database/05-transformations.sql` ---
(DD/MM/YYYY)

Produtos requisitados \> `database/05-transformations.sql` 0 produtos ultrapassam
10x (formato combinado do (seção 3.3) 10 requisições nesta
enunciado) base --- o exemplo do
enunciado representa o
formato esperado, não
um resultado garantido
nos dados de teste

Trigger de `database/06-trigger.sql` Sequence + trigger
`idfornecedor_numerico` `BEFORE INSERT`,
testada com `ROLLBACK`

---

Resultados detalhados, com evidências:
[`docs/06-resultados.md`](docs/06-resultados.md)

## Automação: identificador numérico do fornecedor

`fornecedor` ganhou a coluna `idfornecedor_numerico`, populada por uma
`SEQUENCE` (`seq_idfornecedor_numerico`) via trigger `BEFORE INSERT`.
`produtos_filial` tem uma segunda trigger que busca esse número
automaticamente a partir do `idfornecedor` (texto) já existente, com FK
garantindo integridade.

Testado inserindo um fornecedor fictício (`F21`) e um produto
relacionado, ambos revertidos com `ROLLBACK` --- nenhum dado de teste
permanece na base final.

Implementação: [`database/06-trigger.sql`](database/06-trigger.sql) ·
Evidências: [`docs/06-resultados.md`](docs/06-resultados.md)

---

## Validação da implantação

Volume de registros, valores nulos/negativos, integridade referencial e
os achados acima foram todos re-verificados como parte da validação
final, com evidência em imagem para cada checagem.

Detalhamento completo: [`docs/06-resultados.md`](docs/06-resultados.md)
· Consultas:
[`database/07-client-validation.sql`](database/07-client-validation.sql)

## Estratégia de validação com o cliente

Roteiro para a reunião de fechamento de fevereiro/2025: pontos a
validar, técnicas de exatidão (reconciliação de contagem, checksum,
checagem de órfãos) e consultas de apoio prontas.

Documento completo:
[`docs/05-estrategia-de-validacao.md`](docs/05-estrategia-de-validacao.md)

---

## Documentação

---

Documento Conteúdo

---

[`01-entendimento-do-case.md`](docs/01-entendimento-do-case.md) Entendimento inicial, fonte e
estrutura dos dados

[`02-processo-de-importacao.md`](docs/02-processo-de-importacao.md) Ferramenta, mapeamento e critérios
de importação

[`03-erros-e-inconsistencias.md`](docs/03-erros-e-inconsistencias.md) Inconsistências identificadas na
base

[`04-regras-de-negocio.md`](docs/04-regras-de-negocio.md) Regras utilizadas para tratamento e
validação

[`05-estrategia-de-validacao.md`](docs/05-estrategia-de-validacao.md) Estratégia de validação com o
cliente

[`06-resultados.md`](docs/06-resultados.md) Resultados, evidências e testes

---

## Banco de dados

Scripts na ordem de execução:

1.  `01-create-tables.sql` --- criação das tabelas
2.  `02-import-data.sql` --- processo de importação
3.  `03-fixes-and-validations.sql` --- validações e inconsistências
4.  `04-basic-queries.sql` --- consultas do case
5.  `05-transformations.sql` --- transformações
6.  `06-trigger.sql` --- identificador numérico do fornecedor
7.  `07-client-validation.sql` --- validação final

## Backup e restauração

```bash
# Gerar
pg_dump -h localhost -p 5433 -U postgres -d systock_case -F c -f backup/systock_case_backup.dump

# Restaurar
pg_restore -h localhost -p 5433 -U postgres -d systock_case backup/systock_case_backup.dump
```

## Como reproduzir

1.  Criar o banco `systock_case`.
2.  Executar `database/01-create-tables.sql`.
3.  Importar os CSVs de `data/processed/` (ordem: fornecedor →
    produtos_filial → venda → pedido_compra → entradas_mercadoria) ---
    detalhes em `database/02-import-data.sql`.
4.  Executar, em ordem: `03-fixes-and-validations.sql` →
    `04-basic-queries.sql` → `05-transformations.sql` → `06-trigger.sql`
    → `07-client-validation.sql`.

---

## Status

✅ Projeto concluído tecnicamente e publicado no GitHub. Todas as etapas
do case (importação, consultas, transformações, trigger, validação,
backup) foram implementadas, testadas e documentadas.
