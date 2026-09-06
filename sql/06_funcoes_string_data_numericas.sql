-- =====================================================================
-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Arquivo: 06_funcoes_string_data_numericas.sql
-- Descricao: Funcoes de string, data/hora, numericas e de agregacao
-- Observacao: sintaxe de data (strftime) e especifica do SQLite.
--             Em MySQL usar DATE_FORMAT() -- em PostgreSQL usar TO_CHAR()
-- =====================================================================

-- 6.1 FUNCOES DE STRING -------------------------------------------------

-- Normalizar nomes (maiusculas) e extrair iniciais do cliente
SELECT
    nome_cliente,
    UPPER(nome_cliente)                         AS nome_maiusculo,
    LOWER(email)                                AS email_padronizado,
    SUBSTR(nome_cliente, 1, 1)                  AS inicial,
    LENGTH(nome_cliente)                        AS tamanho_nome,
    TRIM(nome_cliente)                          AS nome_sem_espacos,
    REPLACE(email, '@', ' [at] ')               AS email_mascarado
FROM clientes
LIMIT 10;

-- Extrair dominio do e-mail dos clientes e contar por dominio
SELECT
    SUBSTR(email, INSTR(email, '@') + 1) AS dominio_email,
    COUNT(*) AS qtd_clientes
FROM clientes
GROUP BY dominio_email
ORDER BY qtd_clientes DESC;

-- Concatenacao: montar "etiqueta" cliente + cidade/estado
SELECT
    nome_cliente || ' (' || cidade || '/' || estado || ')' AS cliente_localizacao
FROM clientes
LIMIT 10;

-- 6.2 FUNCOES DE DATA ----------------------------------------------------

-- Idade do cadastro do cliente (em dias) e classificacao por antiguidade
SELECT
    nome_cliente,
    data_cadastro,
    CAST(julianday('now') - julianday(data_cadastro) AS INTEGER) AS dias_como_cliente,
    CASE
        WHEN julianday('now') - julianday(data_cadastro) < 180  THEN 'Novo'
        WHEN julianday('now') - julianday(data_cadastro) < 730  THEN 'Recorrente'
        ELSE 'Fidelizado'
    END AS perfil_antiguidade
FROM clientes
ORDER BY dias_como_cliente DESC
LIMIT 15;

-- Extrair ano, mes, dia da semana do pedido (sazonalidade)
SELECT
    id_pedido,
    data_pedido,
    strftime('%Y', data_pedido)              AS ano,
    strftime('%m', data_pedido)              AS mes,
    CASE CAST(strftime('%w', data_pedido) AS INTEGER)
        WHEN 0 THEN 'Domingo' WHEN 1 THEN 'Segunda' WHEN 2 THEN 'Terca'
        WHEN 3 THEN 'Quarta'  WHEN 4 THEN 'Quinta'  WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sabado'
    END AS dia_semana
FROM pedidos
LIMIT 15;

-- Tempo entre o cadastro do cliente e a data do primeiro pedido
SELECT
    c.nome_cliente,
    c.data_cadastro,
    MIN(p.data_pedido) AS data_primeiro_pedido,
    CAST(julianday(MIN(p.data_pedido)) - julianday(c.data_cadastro) AS INTEGER) AS dias_ate_primeira_compra
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome_cliente, c.data_cadastro
HAVING dias_ate_primeira_compra >= 0
ORDER BY dias_ate_primeira_compra DESC
LIMIT 15;

-- 6.3 FUNCOES NUMERICAS E DE AGREGACAO -----------------------------------

-- Estatisticas de preco por categoria: min, max, media, desvio aproximado
SELECT
    cat.nome_categoria,
    COUNT(pr.id_produto)                         AS qtd_produtos,
    ROUND(MIN(pr.preco_unitario), 2)              AS menor_preco,
    ROUND(MAX(pr.preco_unitario), 2)              AS maior_preco,
    ROUND(AVG(pr.preco_unitario), 2)              AS preco_medio,
    ROUND(SUM(pr.preco_unitario), 2)              AS soma_precos
FROM produtos pr
JOIN categorias cat ON cat.id_categoria = pr.id_categoria
GROUP BY cat.nome_categoria
ORDER BY preco_medio DESC;

-- Arredondamentos e calculo de margem/lucro por item vendido
SELECT
    pr.nome_produto,
    ip.quantidade,
    ROUND(ip.preco_unitario_venda, 2)                                  AS preco_venda,
    ROUND(ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0), 2) AS preco_com_desconto,
    ROUND(pr.custo_unitario, 2)                                        AS custo,
    ABS(ROUND(ip.preco_unitario_venda - pr.custo_unitario, 2))         AS diferenca_absoluta,
    ROUND((ip.preco_unitario_venda - pr.custo_unitario) / ip.preco_unitario_venda * 100, 1) AS margem_pct,
    CEIL(ip.quantidade / 2.0)  AS caixas_necessarias  -- ex: 2 unidades por caixa
FROM itens_pedido ip
JOIN produtos pr ON pr.id_produto = ip.id_produto
LIMIT 15;

-- GROUP BY + HAVING: clientes com receita total acima de R$ 10.000
SELECT
    c.nome_cliente,
    COUNT(DISTINCT p.id_pedido) AS qtd_pedidos,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita_total
FROM clientes c
JOIN pedidos p       ON p.id_cliente = c.id_cliente
JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
WHERE p.status_pedido = 'Concluido'
GROUP BY c.id_cliente, c.nome_cliente
HAVING receita_total > 10000
ORDER BY receita_total DESC;
