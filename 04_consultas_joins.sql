-- =====================================================================
-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Arquivo: 04_consultas_joins.sql
-- Descricao: Consultas com diferentes tipos de JOIN
-- =====================================================================

-- 4.1 INNER JOIN: pedidos concluidos com dados do cliente e do vendedor
SELECT
    p.id_pedido,
    p.data_pedido,
    c.nome_cliente,
    v.nome_vendedor,
    p.forma_pagamento
FROM pedidos p
INNER JOIN clientes c   ON c.id_cliente  = p.id_cliente
INNER JOIN vendedores v ON v.id_vendedor = p.id_vendedor
WHERE p.status_pedido = 'Concluido'
ORDER BY p.data_pedido DESC
LIMIT 20;

-- 4.2 LEFT JOIN: todos os produtos, mesmo os que nunca foram vendidos
-- (util para identificar produtos parados em estoque)
SELECT
    pr.id_produto,
    pr.nome_produto,
    cat.nome_categoria,
    pr.estoque_atual,
    COALESCE(SUM(ip.quantidade), 0) AS total_vendido
FROM produtos pr
JOIN categorias cat ON cat.id_categoria = pr.id_categoria
LEFT JOIN itens_pedido ip ON ip.id_produto = pr.id_produto
GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria, pr.estoque_atual
HAVING total_vendido = 0
ORDER BY pr.estoque_atual DESC;

-- 4.3 JOIN multiplo (4 tabelas): receita liquida por categoria e por regiao do vendedor
SELECT
    cat.nome_categoria,
    v.regiao,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita_liquida
FROM itens_pedido ip
JOIN produtos pr    ON pr.id_produto = ip.id_produto
JOIN categorias cat ON cat.id_categoria = pr.id_categoria
JOIN pedidos p      ON p.id_pedido = ip.id_pedido
JOIN vendedores v   ON v.id_vendedor = p.id_vendedor
WHERE p.status_pedido = 'Concluido'
GROUP BY cat.nome_categoria, v.regiao
ORDER BY cat.nome_categoria, receita_liquida DESC;

-- 4.4 SELF JOIN: clientes da mesma cidade (para campanhas de marketing local)
SELECT DISTINCT
    c1.nome_cliente AS cliente_1,
    c2.nome_cliente AS cliente_2,
    c1.cidade
FROM clientes c1
JOIN clientes c2
    ON c1.cidade = c2.cidade
   AND c1.id_cliente < c2.id_cliente
ORDER BY c1.cidade
LIMIT 15;

-- 4.5 LEFT JOIN + filtro de ausencia (clientes que nunca compraram)
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.email,
    c.data_cadastro
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.id_pedido IS NULL;
