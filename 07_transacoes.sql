-- =====================================================================
-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Arquivo: 07_transacoes.sql
-- Descricao: Exemplos de controle transacional (BEGIN, COMMIT, ROLLBACK)
-- =====================================================================

-- 7.1 Transacao simples: registrar um novo pedido garantindo integridade
-- (cabecalho + itens sao gravados juntos; se algo falhar, nada e persistido)
BEGIN TRANSACTION;

    INSERT INTO pedidos (id_cliente, id_vendedor, data_pedido, status_pedido, forma_pagamento)
    VALUES (1, 1, DATE('now'), 'Em processamento', 'Pix');

    -- captura o id do pedido recem-criado
    -- (em SQLite: last_insert_rowid())
    INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario_venda, desconto_percentual)
    VALUES (last_insert_rowid(), 3, 2, 4799, 0);

COMMIT;

-- 7.2 Transacao com validacao de negocio e ROLLBACK
-- Cenario: so confirmar a venda se houver estoque suficiente
BEGIN TRANSACTION;

    -- Simula a baixa de estoque
    UPDATE produtos
       SET estoque_atual = estoque_atual - 5
     WHERE id_produto = 10;

    -- Regra de negocio: estoque nao pode ficar negativo
    -- Se a condicao abaixo indicar estoque negativo, desfazemos a operacao
    -- (em uma aplicacao real, essa checagem seria feita em codigo/trigger)
    -- SELECT estoque_atual FROM produtos WHERE id_produto = 10;

ROLLBACK;  -- desfaz a baixa de estoque simulada (nada e alterado permanentemente)

-- 7.3 Transacao para cancelamento de pedido (estorno)
-- Atualiza o status do pedido e devolve o estoque dos itens cancelados
BEGIN TRANSACTION;

    UPDATE pedidos
       SET status_pedido = 'Cancelado'
     WHERE id_pedido = 5;

    UPDATE produtos
       SET estoque_atual = estoque_atual + (
            SELECT COALESCE(SUM(ip.quantidade), 0)
              FROM itens_pedido ip
             WHERE ip.id_pedido = 5
               AND ip.id_produto = produtos.id_produto
       )
     WHERE id_produto IN (SELECT id_produto FROM itens_pedido WHERE id_pedido = 5);

COMMIT;

-- 7.4 SAVEPOINT: transacao com ponto de restauracao intermediario
BEGIN TRANSACTION;

    UPDATE vendedores SET meta_mensal = meta_mensal * 1.10 WHERE regiao = 'Sudeste';

    SAVEPOINT antes_do_ajuste_sul;

    UPDATE vendedores SET meta_mensal = meta_mensal * 1.10 WHERE regiao = 'Sul';

    -- Caso o ajuste da regiao Sul precise ser desfeito isoladamente:
    ROLLBACK TO SAVEPOINT antes_do_ajuste_sul;

COMMIT; -- mantem apenas o ajuste da regiao Sudeste
