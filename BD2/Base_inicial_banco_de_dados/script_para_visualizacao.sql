/************************************************************
 * Script: consultas_simples.sql
 * Objetivo: testes de consultas básicas para verificar
 *           estrutura de tabelas, relacionamentos e dados.
 * Instruções: execute este script após ter carregado
 *             os scripts de criação e de inserção de dados.
 ************************************************************/

-- 1) Listar todos os usuários cadastrados
-- ------------------------------------------------
-- Esperado: retorno de 3 registros (Ana Silva, João Oliveira, Carlos Pereira)
SELECT
    id,
    nome,
    email,
    tipoUsuario
FROM
    usuario;


-- 2) Listar apenas os clientes (tipoUsuario = 'Cliente')
-- ------------------------------------------------
-- Esperado: retorno de registros com Ana Silva e Carlos Pereira
SELECT
    id,
    nome,
    email
FROM
    usuario
WHERE
    tipoUsuario = 'Cliente';


-- 3) Listar apenas os funcionários (tipoUsuario = 'Funcionario')
-- ------------------------------------------------
-- Esperado: retorno de registro com João Oliveira
SELECT
    id,
    nome,
    email
FROM
    usuario
WHERE
    tipoUsuario = 'Funcionario';


-- 4) Listar todas as categorias de produto
-- ------------------------------------------------
-- Esperado: retorno de 3 registros (Eletrônicos, Livros, Roupas)
SELECT
    id   AS categoria_id,
    nome AS categoria_nome
FROM
    categoria;


-- 5) Listar todos os produtos com suas categorias associadas
-- ------------------------------------------------
-- JOIN produto → categoria (N:1)
-- Esperado: cada produto aparece acompanhado do nome da categoria
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
-- ------------------------------------------------
-- Esperado: retorno de 3 registros (Cartão de Crédito, Boleto, Pix)
SELECT
    id   AS pagamento_id,
    tipo AS pagamento_tipo,
    status
FROM
    pagamento;


-- 7) Listar todos os pedidos com dados do usuário e do pagamento
-- ------------------------------------------------
-- JOIN pedido → usuario (N:1) e pedido → pagamento (N:1)
-- Esperado: cada pedido indica quem fez (nome do usuário)
--           e o tipo de pagamento utilizado
SELECT
    ped.id             AS pedido_id,
    ped.data           AS pedido_data,
    ped.status         AS pedido_status,
    usu.id             AS usuario_id,
    usu.nome           AS usuario_nome,
    pag.id             AS pagamento_id,
    pag.tipo           AS pagamento_tipo,
    pag.status         AS pagamento_status
FROM
    pedido ped
    INNER JOIN usuario usu ON ped.usuario_id = usu.id
    INNER JOIN pagamento pag ON ped.pagamento_id = pag.id
ORDER BY
    ped.data;


-- 8) Listar todos os pedidos cujo status seja 'Em Processamento'
-- ------------------------------------------------
-- Usado para verificar filtragem por status
SELECT
    id        AS pedido_id,
    data      AS pedido_data,
    status    AS pedido_status
FROM
    pedido
WHERE
    status = 'Em Processamento';


-- 9) Listar itens de um pedido específico (ex: pedido_id = 1)
-- ------------------------------------------------
-- JOIN item_pedido → produto (N:1)
-- Esperado: para o pedido 1, retorna Smartphone XYZ (2 unidades) e Livro "Aprendendo SQL" (1 unidade)
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
-- ------------------------------------------------
-- Exemplo de agregação: soma de todas as quantidades dentro de cada pedido
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
-- ------------------------------------------------
-- Para cada pedido, multiplica quantidade * preço do produto e soma
-- JOIN: item_pedido → produto (para obter preço unitário)
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
-- ------------------------------------------------
-- JOIN admin_pedido → pedido (N:1) e admin_pedido → usuario (N:1)
-- Esperado: João Oliveira realizou duas ações (uma no pedido 1 e outra no pedido 2)
SELECT
    ap.id                  AS admin_id,
    ap.pedido_id           AS pedido_id,
    ap.usuario_id          AS funcionario_id,
    usu.nome               AS funcionario_nome,
    ap.acao,
    ap.dataHora,
    ap.comentario
FROM
    admin_pedido ap
    INNER JOIN usuario usu ON ap.usuario_id = usu.id
ORDER BY
    ap.dataHora;


-- 13) Contar quantos pedidos cada usuário (cliente) possui
-- ------------------------------------------------
-- JOIN pedido → usuario (N:1), agrupar por usuário
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
-- ------------------------------------------------
-- Usamos LEFT JOIN de produto → item_pedido e filtramos itens nulos
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


-- 15) Exemplo de busca de pedidos em um intervalo de datas
-- ------------------------------------------------
-- Buscando pedidos feitos entre 2025-06-01 e 2025-06-30
SELECT
    id             AS pedido_id,
    data           AS pedido_data,
    status         AS pedido_status
FROM
    pedido
WHERE
    data BETWEEN '2025-06-01' AND '2025-06-30'
ORDER BY
    data;


-- 16) Listar usuários (clientes) que fizeram pedido(s) cujo valor total ultrapasse 1000,00
-- ------------------------------------------------
-- Cálculo de valor total por pedido, depois filtra por > 1000 e agrupa usuário
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
    tpp.valor_total > 1000
ORDER BY
    tpp.valor_total DESC;


-- 17) Mostrar pedidos e, para cada um, quantos funcionários já o administraram
-- ------------------------------------------------
-- JOIN pedido → admin_pedido → usuario, agrupando por pedido
SELECT
    ped.id                    AS pedido_id,
    ped.data                  AS pedido_data,
    COUNT(DISTINCT ap.usuario_id) AS qtd_funcionarios
FROM
    pedido ped
    LEFT JOIN admin_pedido ap ON ped.id = ap.pedido_id
GROUP BY
    ped.id,
    ped.data
ORDER BY
    ped.data;


-- 18) Exibir resumo: para cada categoria, quantos produtos existem
-- ------------------------------------------------
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


-- 19) Exemplo de subconsulta: listar pedidos cujo valor total está acima da média de todos os pedidos
-- ------------------------------------------------
-- Primeiro calculamos a média de valor total de pedidos em uma subconsulta,
-- depois filtramos pelo valor de cada pedido
WITH valor_pedido AS (
    SELECT
        ip.pedido_id,
        SUM(ip.quantidade * prod.preco) AS valor_total
    FROM
        item_pedido ip
        INNER JOIN produto prod ON ip.produto_id = prod.id
    GROUP BY
        ip.pedido_id
),
media_valor AS (
    SELECT
        AVG(valor_total) AS media_geral
    FROM
        valor_pedido
)
SELECT
    vp.pedido_id,
    vp.valor_total,
    mv.media_geral
FROM
    valor_pedido vp,
    media_valor mv
WHERE
    vp.valor_total > mv.media_geral
ORDER BY
    vp.valor_total DESC;


-- 20) Exemplo de consulta usando LIKE: buscar produtos cujo nome contenha 'Livro'
-- ------------------------------------------------
-- Esperado: retorna o produto “Livro 'Aprendendo SQL'”
SELECT
    id   AS produto_id,
    nome AS produto_nome,
    preco
FROM
    produto
WHERE
    nome LIKE '%Livro%';

