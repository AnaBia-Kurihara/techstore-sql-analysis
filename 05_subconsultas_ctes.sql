-- =====================================================================
-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Arquivo: 05_subconsultas_ctes.sql
-- Descricao: Subconsultas (escalar, IN, correlacionada) e CTEs (simples e recursiva)
-- =====================================================================

-- 5.1 Subconsulta escalar: produtos com preco acima da media geral
SELECT
    nome_produto,
    preco_unitario
FROM produtos
WHERE preco_unitario > (SELECT AVG(preco_unitario) FROM produtos)
ORDER BY preco_unitario DESC;

-- 5.2 Subconsulta com IN: clientes que compraram produtos da categoria "Games"
SELECT DISTINCT
    c.nome_cliente,
    c.cidade
FROM clientes c
WHERE c.id_cliente IN (
    SELECT p.id_cliente
    FROM pedidos p
    JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
    JOIN produtos pr     ON pr.id_produto = ip.id_produto
    JOIN categorias cat  ON cat.id_categoria = pr.id_categoria
    WHERE cat.nome_categoria = 'Games'
);

-- 5.3 Subconsulta correlacionada: vendedores cuja receita supera a media da propria regiao
SELECT
    v.nome_vendedor,
    v.regiao,
    (SELECT ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2)
       FROM pedidos p
       JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
      WHERE p.id_vendedor = v.id_vendedor
        AND p.status_pedido = 'Concluido') AS receita_vendedor
FROM vendedores v
WHERE (
        SELECT COALESCE(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 0)
        FROM pedidos p
        JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
        WHERE p.id_vendedor = v.id_vendedor
          AND p.status_pedido = 'Concluido'
      ) > (
        SELECT AVG(receita_regiao) FROM (
            SELECT v2.regiao, v2.id_vendedor,
                   COALESCE(SUM(ip2.quantidade * ip2.preco_unitario_venda * (1 - ip2.desconto_percentual/100.0)), 0) AS receita_regiao
            FROM vendedores v2
            LEFT JOIN pedidos p2 ON p2.id_vendedor = v2.id_vendedor AND p2.status_pedido = 'Concluido'
            LEFT JOIN itens_pedido ip2 ON ip2.id_pedido = p2.id_pedido
            WHERE v2.regiao = v.regiao
            GROUP BY v2.id_vendedor
        )
      )
ORDER BY receita_vendedor DESC;

-- 5.4 CTE simples: ranking de produtos mais vendidos por categoria
WITH vendas_por_produto AS (
    SELECT
        pr.id_produto,
        pr.nome_produto,
        cat.nome_categoria,
        SUM(ip.quantidade) AS unidades_vendidas
    FROM itens_pedido ip
    JOIN produtos pr    ON pr.id_produto = ip.id_produto
    JOIN categorias cat ON cat.id_categoria = pr.id_categoria
    JOIN pedidos p      ON p.id_pedido = ip.id_pedido
    WHERE p.status_pedido = 'Concluido'
    GROUP BY pr.id_produto, pr.nome_produto, cat.nome_categoria
)
SELECT *
FROM vendas_por_produto
ORDER BY nome_categoria, unidades_vendidas DESC;

-- 5.5 Multiplas CTEs encadeadas: ticket medio mensal e variacao percentual (MoM)
WITH receita_mensal AS (
    SELECT
        strftime('%Y-%m', p.data_pedido) AS ano_mes,
        ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita,
        COUNT(DISTINCT p.id_pedido) AS qtd_pedidos
    FROM pedidos p
    JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
    WHERE p.status_pedido = 'Concluido'
    GROUP BY strftime('%Y-%m', p.data_pedido)
),
ticket_medio AS (
    SELECT
        ano_mes,
        receita,
        qtd_pedidos,
        ROUND(receita / qtd_pedidos, 2) AS ticket_medio
    FROM receita_mensal
)
SELECT
    ano_mes,
    receita,
    qtd_pedidos,
    ticket_medio,
    ROUND(
        100.0 * (receita - LAG(receita) OVER (ORDER BY ano_mes)) / NULLIF(LAG(receita) OVER (ORDER BY ano_mes), 0)
    , 2) AS variacao_percentual_mom
FROM ticket_medio
ORDER BY ano_mes;

-- 5.6 CTE recursiva: gerar uma serie de datas (calendario) para analise de sazonalidade
WITH RECURSIVE calendario(data_ref) AS (
    SELECT DATE('2023-09-01')
    UNION ALL
    SELECT DATE(data_ref, '+1 month')
    FROM calendario
    WHERE data_ref < DATE('2026-09-01')
)
SELECT
    strftime('%Y-%m', cal.data_ref) AS mes_referencia,
    COALESCE(rm.receita, 0) AS receita_do_mes
FROM calendario cal
LEFT JOIN (
    SELECT strftime('%Y-%m', p.data_pedido) AS ano_mes,
           ROUND(SUM(ip.quantidade * ip.preco_unitario_venda * (1 - ip.desconto_percentual/100.0)), 2) AS receita
    FROM pedidos p
    JOIN itens_pedido ip ON ip.id_pedido = p.id_pedido
    WHERE p.status_pedido = 'Concluido'
    GROUP BY strftime('%Y-%m', p.data_pedido)
) rm ON rm.ano_mes = strftime('%Y-%m', cal.data_ref)
ORDER BY mes_referencia;
