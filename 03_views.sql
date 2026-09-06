-- =====================================================================
-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Arquivo: 03_views.sql
-- Descricao: Views para simplificar consultas recorrentes de analise
-- =====================================================================

-- View 1: Detalhamento de vendas (join de todas as tabelas de fato/dimensao)
-- Reune pedido + item + produto + cliente + vendedor em uma unica visao
CREATE VIEW vw_vendas_detalhadas AS
SELECT
    p.id_pedido,
    p.data_pedido,
    p.status_pedido,
    p.forma_pagamento,
    c.id_cliente,
    c.nome_cliente,
    c.cidade,
    c.estado,
    c.segmento,
    v.id_vendedor,
    v.nome_vendedor,
    v.regiao,
    pr.id_produto,
    pr.nome_produto,
    cat.nome_categoria,
    ip.quantidade,
    ip.preco_unitario_venda,
    ip.desconto_percentual,
    ROUND(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual / 100.0), 2) AS valor_liquido_item,
    pr.custo_unitario,
    ROUND(ip.quantidade * (ip.preco_unitario_venda * (1 - ip.desconto_percentual / 100.0) - pr.custo_unitario), 2) AS lucro_item
FROM itens_pedido ip
JOIN pedidos   p   ON p.id_pedido   = ip.id_pedido
JOIN clientes  c   ON c.id_cliente  = p.id_cliente
JOIN vendedores v  ON v.id_vendedor = p.id_vendedor
JOIN produtos  pr  ON pr.id_produto = ip.id_produto
JOIN categorias cat ON cat.id_categoria = pr.id_categoria;

-- View 2: Resumo financeiro por pedido (agregando os itens)
CREATE VIEW vw_resumo_pedidos AS
SELECT
    p.id_pedido,
    p.data_pedido,
    p.status_pedido,
    c.nome_cliente,
    v.nome_vendedor,
    COUNT(ip.id_item)                       AS qtd_itens_distintos,
    SUM(ip.quantidade)                      AS qtd_produtos,
    ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual / 100.0)), 2) AS valor_total_pedido
FROM pedidos p
JOIN clientes c   ON c.id_cliente  = p.id_cliente
JOIN vendedores v ON v.id_vendedor = p.id_vendedor
JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
GROUP BY p.id_pedido, p.data_pedido, p.status_pedido, c.nome_cliente, v.nome_vendedor;

-- View 3: Performance de produtos (estoque, giro e margem)
CREATE VIEW vw_performance_produtos AS
SELECT
    pr.id_produto,
    pr.nome_produto,
    cat.nome_categoria,
    pr.estoque_atual,
    pr.preco_unitario,
    pr.custo_unitario,
    ROUND((pr.preco_unitario - pr.custo_unitario) / pr.preco_unitario * 100, 2) AS margem_percentual,
    COALESCE(SUM(ip.quantidade), 0) AS unidades_vendidas,
    COALESCE(ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2), 0) AS receita_total
FROM produtos pr
JOIN categorias cat ON cat.id_categoria = pr.id_categoria
LEFT JOIN itens_pedido ip ON ip.id_produto = pr.id_produto
GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria, pr.estoque_atual, pr.preco_unitario, pr.custo_unitario;
