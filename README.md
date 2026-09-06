# 📊 TechStore BR — Projeto de Análise de Vendas em SQL

Projeto para consolidar os conhecimentos das trilhas **"Conhecendo SQL"** e **"Praticando SQL"** (13 cursos | ~70h). Simula o banco de dados de um e-commerce de eletrônicos e responde perguntas reais de negócio usando **SQL puro**, do modelo relacional à análise final, com um dashboard em Excel para visualização dos resultados.

> 💡 Os dados são **sintéticos** (gerados com Python/Faker), mas o modelo, as regras de negócio e as consultas foram desenhados para refletir um cenário real de análise de vendas.

---

## 🗂️ Estrutura do repositório

```
techstore-br-sql-analysis/
│
├── sql/
│   ├── 01_schema.sql                        # Criação das tabelas (DDL) + índices
│   ├── 02_dados.sql                         # Massa de dados (DML) — INSERTs
│   ├── 03_views.sql                         # Views de apoio à análise
│   ├── 04_consultas_joins.sql               # INNER, LEFT, SELF JOIN, joins múltiplos
│   ├── 05_subconsultas_ctes.sql             # Subconsultas e CTEs (inclusive recursiva)
│   ├── 06_funcoes_string_data_numericas.sql # Funções de string, data e agregação
│   ├── 07_transacoes.sql                    # BEGIN, COMMIT, ROLLBACK, SAVEPOINT
│   └── 08_analise_negocio.sql               # Consultas finais que alimentam o dashboard
│
├── excel/
│   └── TechStoreBR_Dashboard_Vendas.xlsx    # Dashboard com gráficos (resultado das queries)
│
├── data/
│   └── techstore.db                         # Banco SQLite pronto para uso (opcional)
│
└── README.md
```

---

## 🧩 Modelo de dados

Banco relacional com 6 tabelas, normalizado em 3FN:

```
categorias 1───N produtos 1───N itens_pedido N───1 pedidos N───1 clientes
                                                        └──────1 vendedores
```

| Tabela | Registros | Descrição |
|---|---|---|
| `categorias` | 8 | Categorias de produtos (Smartphones, Notebooks, Games...) |
| `produtos` | 40 | Catálogo com preço, custo e estoque |
| `clientes` | 180 | Clientes com localização e segmento |
| `vendedores` | 8 | Equipe de vendas por região |
| `pedidos` | 950 | Cabeçalho dos pedidos (status, pagamento, data) |
| `itens_pedido` | ~2.400 | Itens de cada pedido (quantidade, desconto) |

---

## ⚙️ Conceitos de SQL demonstrados

| Conceito | Onde encontrar |
|---|---|
| DDL — criação de tabelas, PK/FK, índices | `01_schema.sql` |
| DML — inserção de dados | `02_dados.sql` |
| Views | `03_views.sql` |
| INNER / LEFT / SELF JOIN, joins múltiplos | `04_consultas_joins.sql` |
| Subconsultas (escalar, `IN`, correlacionada) | `05_subconsultas_ctes.sql` |
| CTEs simples, encadeadas e **recursivas** | `05_subconsultas_ctes.sql` |
| Window function (`LAG`) para variação mês a mês | `05_subconsultas_ctes.sql` |
| Funções de string (`UPPER`, `SUBSTR`, `TRIM`, `REPLACE`, `INSTR`) | `06_funcoes_string_data_numericas.sql` |
| Funções de data (`strftime`, `julianday`, extração de ano/mês/dia da semana) | `06_funcoes_string_data_numericas.sql` |
| Funções numéricas e de agregação (`SUM`, `AVG`, `MIN`, `MAX`, `ROUND`, `HAVING`) | `06_funcoes_string_data_numericas.sql` |
| Transações (`BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`) | `07_transacoes.sql` |
| Análise de negócio (RFM, funil de status, geografia, performance de vendas) | `08_analise_negocio.sql` |

> As consultas foram escritas e testadas em **SQLite**. Funções de data usam `strftime`/`julianday`, que têm equivalentes diretos em outros SGBDs (ex.: `DATE_FORMAT` no MySQL, `TO_CHAR` no PostgreSQL) — comentado no topo do arquivo `06`.

---

## 📈 Perguntas de negócio respondidas

1. Como a receita líquida evoluiu mês a mês? Houve sazonalidade (Black Friday)?
2. Quais são os 10 produtos que mais geram receita?
3. Qual categoria concentra a maior participação nas vendas?
4. Quais vendedores estão batendo a meta e quais estão abaixo?
5. Como a receita se distribui entre os estados?
6. Qual a taxa de cancelamento/devolução de pedidos?
7. Quais formas de pagamento os clientes mais utilizam?
8. Quem são os clientes mais valiosos (RFM — recência, frequência, valor)?
9. Quais produtos têm baixo giro de estoque (parados)?

---

## 📊 Dashboard em Excel

O arquivo [`excel/TechStoreBR_Dashboard_Vendas.xlsx`](excel/TechStoreBR_Dashboard_Vendas.xlsx) traz os resultados das consultas de `08_analise_negocio.sql` organizados em abas, cada uma com tabela + gráfico nativo:

- **Resumo Executivo** — KPIs principais + evolução de receita
- **Receita Mensal** — série temporal completa
- **Top Produtos** — ranking de receita
- **Receita por Categoria** — participação (gráfico de pizza)
- **Performance Vendedores** — receita vs. meta
- **Receita por Estado** — distribuição geográfica
- **Status e Pagamento** — funil de pedidos e formas de pagamento
- **Top Clientes (RFM)** — clientes mais valiosos
- **Giro de Estoque** — produtos parados vs. mais vendidos

---

## ▶️ Como executar

```bash
# 1. Criar o banco e carregar schema + dados + views
sqlite3 techstore.db < sql/01_schema.sql
sqlite3 techstore.db < sql/02_dados.sql
sqlite3 techstore.db < sql/03_views.sql

# 2. Rodar as análises
sqlite3 techstore.db < sql/08_analise_negocio.sql
```

Ou use o arquivo pronto em `data/techstore.db` com o **DB Browser for SQLite** ou qualquer client compatível.

---

## 🛠️ Tecnologias

`SQL (SQLite)` · `Python` (geração da massa de dados sintética) · `Excel` (dashboard)

---

## 🎓 Formação

Projeto desenvolvido após conclusão das trilhas:
- **Conhecendo SQL** — 4 cursos | 34h
- **Praticando SQL** — 9 cursos | 36h

