-- PROJETO: TechStore BR - Analise de Vendas em SQL
-- Descricao: Criacao das tabelas do banco de dados (modelo relacional)
-- =====================================================================

CREATE TABLE categorias (
    id_categoria    INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_categoria  TEXT NOT NULL,
    descricao       TEXT
);

CREATE TABLE produtos (
    id_produto      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_produto    TEXT NOT NULL,
    id_categoria    INTEGER NOT NULL,
    preco_unitario  REAL NOT NULL,
    custo_unitario  REAL NOT NULL,
    estoque_atual   INTEGER NOT NULL DEFAULT 0,
    data_cadastro   TEXT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE clientes (
    id_cliente      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_cliente    TEXT NOT NULL,
    email           TEXT NOT NULL,
    cidade          TEXT NOT NULL,
    estado          TEXT NOT NULL,
    segmento        TEXT NOT NULL,
    data_cadastro   TEXT NOT NULL
);

CREATE TABLE vendedores (
    id_vendedor       INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_vendedor     TEXT NOT NULL,
    regiao            TEXT NOT NULL,
    meta_mensal       REAL NOT NULL,
    data_contratacao  TEXT NOT NULL
);

CREATE TABLE pedidos (
    id_pedido         INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente        INTEGER NOT NULL,
    id_vendedor       INTEGER NOT NULL,
    data_pedido       TEXT NOT NULL,
    status_pedido     TEXT NOT NULL,
    forma_pagamento   TEXT NOT NULL,
    FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor)
);

CREATE TABLE itens_pedido (
    id_item                 INTEGER PRIMARY KEY AUTOINCREMENT,
    id_pedido                INTEGER NOT NULL,
    id_produto                INTEGER NOT NULL,
    quantidade                INTEGER NOT NULL,
    preco_unitario_venda      REAL NOT NULL,
    desconto_percentual       REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (id_pedido)  REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX idx_pedidos_cliente ON pedidos(id_cliente);
CREATE INDEX idx_itens_pedido ON itens_pedido(id_pedido);
CREATE INDEX idx_itens_produto ON itens_pedido(id_produto);
