-- =====================================================================
-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Arquivo: 08_analise_negocio.sql
-- Descricao: Consultas finais respondendo perguntas de negocio.
--            Os resultados destas consultas alimentam o dashboard em Excel.
-- =====================================================================

-- 8.1 Receita liquida mensal (serie temporal)
SELECT
    strftime('%Y-%m', p.data_pedido) AS mes,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita_liquida
FROM pedidos p
JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
WHERE p.status_pedido = 'Concluido'
GROUP BY mes
ORDER BY mes;

-- 8.2 Top 10 produtos por receita
SELECT
    pr.nome_produto,
    cat.nome_categoria,
    SUM(ip.quantidade) AS unidades_vendidas,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita
FROM itens_pedido ip
JOIN produtos pr ON pr.id_produto = ip.id_produto
JOIN categorias cat ON cat.id_categoria = pr.id_categoria
JOIN pedidos p ON p.id_pedido = ip.id_pedido
WHERE p.status_pedido = 'Concluido'
GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria
ORDER BY receita DESC
LIMIT 10;

-- 8.3 Receita e participacao por categoria
SELECT
    cat.nome_categoria,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita
FROM itens_pedido ip
JOIN produtos pr ON pr.id_produto = ip.id_produto
JOIN categorias cat ON cat.id_categoria = pr.id_categoria
JOIN pedidos p ON p.id_pedido = ip.id_pedido
WHERE p.status_pedido = 'Concluido'
GROUP BY cat.nome_categoria
ORDER BY receita DESC;

-- 8.4 Performance de vendedores (receita, pedidos, ticket medio, atingimento de meta)
SELECT
    v.nome_vendedor,
    v.regiao,
    COUNT(DISTINCT p.id_pedido) AS qtd_pedidos,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita_total,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)) / COUNT(DISTINCT p.id_pedido), 2) AS ticket_medio,
    v.meta_mensal
FROM vendedores v
JOIN pedidos p ON p.id_vendedor = v.id_vendedor AND p.status_pedido = 'Concluido'
JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
GROUP BY v.id_vendedor, v.nome_vendedor, v.regiao, v.meta_mensal
ORDER BY receita_total DESC;

-- 8.5 Receita por estado (distribuicao geografica)
SELECT
    c.estado,
    COUNT(DISTINCT p.id_pedido) AS qtd_pedidos,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente AND p.status_pedido = 'Concluido'
JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
GROUP BY c.estado
ORDER BY receita DESC;

-- 8.6 Status dos pedidos (funil de vendas / taxa de cancelamento e devolucao)
SELECT
    status_pedido,
    COUNT(*) AS qtd_pedidos,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pedidos), 2) AS percentual
FROM pedidos
GROUP BY status_pedido
ORDER BY qtd_pedidos DESC;

-- 8.7 Formas de pagamento preferidas
SELECT
    forma_pagamento,
    COUNT(*) AS qtd_pedidos,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pedidos), 2) AS percentual
FROM pedidos
GROUP BY forma_pagamento
ORDER BY qtd_pedidos DESC;

-- 8.8 Segmentacao de clientes (RFM simplificado: Recencia, Frequencia, Valor)
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.segmento,
    CAST(julianday('now') - julianday(MAX(p.data_pedido)) AS INTEGER) AS dias_desde_ultima_compra,
    COUNT(DISTINCT p.id_pedido) AS frequencia_pedidos,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS valor_total_gasto
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente AND p.status_pedido = 'Concluido'
JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
GROUP BY c.id_cliente, c.nome_cliente, c.segmento
ORDER BY valor_total_gasto DESC
LIMIT 20;
