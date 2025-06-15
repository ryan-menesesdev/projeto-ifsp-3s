-- 1) Listar todos os usuários cadastrados
SELECT
    id,
    nome,
    email,
    tipoUsuario
FROM
    usuario;


-- 2) Listar apenas os clientes (tipoUsuario = 'Cliente')
SELECT
    id,
    nome,
    email
FROM
    usuario
WHERE
    tipoUsuario = 'Cliente';


-- 3) Listar apenas os funcionários (tipoUsuario = 'Funcionario')
SELECT
    id,
    nome,
    email
FROM
    usuario
WHERE
    tipoUsuario = 'Funcionario';


-- 4) Listar todas as categorias de produto
SELECT
    id   AS categoria_id,
    nome AS categoria_nome
FROM
    categoria;


-- 5) Listar todos os produtos com suas categorias associadas
SELECT
    p.id            AS produto_id,
    p.nome          AS produto_nome,
    p.preco         AS produto_preco,
    c.id            AS categoria_id,
    c.nome          AS categoria_nome
FROM
    produto p
    INNER JOIN categoria c ON p.categoria_id = c.id
ORDER BY
    c.nome, p.nome;


-- 6) Listar todos os meios de pagamento cadastrados
SELECT
    id   AS pagamento_id,
    tipo AS pagamento_tipo,
    statusPagamento AS pagamento_status
FROM
    pagamento;


-- 7) Listar todos os pedidos com dados do usuário e do pagamento
SELECT
    ped.id             AS pedido_id,
    ped.dataPedido     AS pedido_data,
    ped.statusPedido   AS pedido_status,
    usu.id             AS usuario_id,
    usu.nome           AS usuario_nome,
    pag.id             AS pagamento_id,
    pag.tipo           AS pagamento_tipo,
    pag.statusPagamento AS pagamento_status
FROM
    pedido ped
    INNER JOIN usuario usu ON ped.usuario_id = usu.id
    INNER JOIN pagamento pag ON ped.pagamento_id = pag.id
ORDER BY
    ped.dataPedido;


-- 8) Listar todos os pedidos cujo status seja 'Em Processamento'
SELECT
    id            AS pedido_id,
    dataPedido    AS pedido_data,
    statusPedido  AS pedido_status
FROM
    pedido
WHERE
    statusPedido = 'Em Processamento';


-- 9) Listar itens de um pedido específico (ex: pedido_id = 1)
SELECT
    ip.id               AS item_id,
    ip.pedido_id        AS pedido_id,
    prod.id             AS produto_id,
    prod.nome           AS produto_nome,
    ip.quantidade       AS quantidade
FROM
    item_pedido ip
    INNER JOIN produto prod ON ip.produto_id = prod.id
WHERE
    ip.pedido_id = 1
ORDER BY
    prod.nome;


-- 10) Calcular a quantidade total de itens por pedido
SELECT
    ip.pedido_id,
    SUM(ip.quantidade) AS total_itens
FROM
    item_pedido ip
GROUP BY
    ip.pedido_id
ORDER BY
    ip.pedido_id;


-- 11) Calcular o valor total de cada pedido
SELECT
    ip.pedido_id,
    ROUND(SUM(ip.quantidade * prod.preco), 2) AS valor_total_pedido
FROM
    item_pedido ip
    INNER JOIN produto prod ON ip.produto_id = prod.id
GROUP BY
    ip.pedido_id
ORDER BY
    ip.pedido_id;


-- 12) Listar ações administrativas de todos os pedidos
SELECT
    ap.id                  AS admin_id,
    ap.pedido_id           AS pedido_id,
    ap.usuario_id          AS funcionario_id,
    usu.nome               AS funcionario_nome,
    ap.acaoRealizada       AS acao,
    ap.dataHora,
    ap.comentario
FROM
    admin_pedido ap
    INNER JOIN usuario usu ON ap.usuario_id = usu.id
ORDER BY
    ap.dataHora;


-- 13) Contar quantos pedidos cada usuário (cliente) possui
SELECT
    usu.id            AS usuario_id,
    usu.nome          AS usuario_nome,
    COUNT(ped.id)     AS total_pedidos
FROM
    usuario usu
    LEFT JOIN pedido ped ON usu.id = ped.usuario_id
WHERE
    usu.tipoUsuario = 'Cliente'
GROUP BY
    usu.id,
    usu.nome
ORDER BY
    total_pedidos DESC;


-- 14) Mostrar todos os produtos que ainda não foram pedidos
SELECT
    prod.id       AS produto_id,
    prod.nome     AS produto_nome
FROM
    produto prod
    LEFT JOIN item_pedido ip ON prod.id = ip.produto_id
WHERE
    ip.id IS NULL
ORDER BY
    prod.nome;


-- 15) Buscar pedidos feitos entre 2025-06-01 e 2025-06-30
SELECT
    id             AS pedido_id,
    dataPedido     AS pedido_data,
    statusPedido   AS pedido_status
FROM
    pedido
WHERE
    dataPedido BETWEEN '2025-06-01' AND '2025-06-30'
ORDER BY
    dataPedido;


-- 16) Listar usuários (clientes) que fizeram pedido(s) cujo valor total ultrapasse 1000,00
WITH total_por_pedido AS (
    SELECT
        ip.pedido_id,
        SUM(ip.quantidade * prod.preco) AS valor_total
    FROM
        item_pedido ip
        INNER JOIN produto prod ON ip.produto_id = prod.id
    GROUP BY
        ip.pedido_id
)
SELECT
    u.id         AS usuario_id,
    u.nome       AS usuario_nome,
    tpp.valor_total
FROM
    pedido p
    INNER JOIN usuario u ON p.usuario_id = u.id
    INNER JOIN total_por_pedido tpp ON p.id = tpp.pedido_id
WHERE
    tpp.valor_total > 100
ORDER BY
    tpp.valor_total DESC;


-- 17) Mostrar pedidos e quantos funcionários já o administraram
SELECT
    ped.id                         AS pedido_id,
    ped.dataPedido                 AS pedido_data,
    COUNT(DISTINCT ap.usuario_id) AS qtd_funcionarios
FROM
    pedido ped
    LEFT JOIN admin_pedido ap ON ped.id = ap.pedido_id
GROUP BY
    ped.id,
    ped.dataPedido
ORDER BY
    ped.dataPedido;


-- 18) Exibir resumo: para cada categoria, quantos produtos existem
SELECT
    c.id            AS categoria_id,
    c.nome          AS categoria_nome,
    COUNT(p.id)     AS qtd_produtos
FROM
    categoria c
    LEFT JOIN produto p ON c.id = p.categoria_id
GROUP BY
    c.id,
    c.nome
ORDER BY
    c.nome;


-- 19) Listar pedidos cujo valor total está acima da média de todos os pedidos
WITH valor_pedido AS (
    SELECT
        ip.pedido_id,
        SUM(ip.quantidade * prod.preco) AS valor_total
    FROM
        item_pedido ip
        INNER JOIN produto prod ON ip.produto_id = prod.id
    GROUP BY
        ip.pedido_id
)


-- 20) Buscar produtos cujo nome contenha 'Bolo'
SELECT
    id   AS produto_id,
    nome AS produto_nome,
    preco
FROM
    produto
WHERE
    nome LIKE '%Bolo%';
