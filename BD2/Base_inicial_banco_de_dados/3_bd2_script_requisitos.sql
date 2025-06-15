-- ============================
-- 1) VIEWS (pelo menos 4)
-- ============================

-- 1.1 Clientes cadastrados
CREATE OR REPLACE VIEW vw_usuarios_clientes AS
SELECT id AS cliente_id,
       nome,
       email
FROM usuario
WHERE tipoUsuario = 'Cliente';

-- 1.2 Produtos sem nenhum pedido
CREATE OR REPLACE VIEW vw_produtos_sem_pedidos AS
SELECT p.id AS produto_id,
       p.nome,
       p.preco
FROM produto p
LEFT JOIN item_pedido ip ON p.id = ip.produto_id
WHERE ip.id IS NULL;

-- 1.3 Total de itens por pedido
CREATE OR REPLACE VIEW vw_total_itens_por_pedido AS
SELECT pedido_id,
       SUM(quantidade) AS total_itens
FROM item_pedido
GROUP BY pedido_id;

-- 1.4 Detalhes completos de cada pedido (valor total incluso)
CREATE OR REPLACE VIEW vw_pedido_detalhes AS
SELECT ped.id AS pedido_id,
       ped.dataPedido AS data,
       ped.statusPedido AS status,
       ped.observacao,
       usu.nome AS cliente,
       pag.tipo AS pagamento_tipo,
       ROUND(SUM(ip.quantidade * prod.preco), 2) AS valor_total
FROM pedido ped
JOIN usuario usu ON ped.usuario_id = usu.id
JOIN pagamento pag ON ped.pagamento_id = pag.id
JOIN item_pedido ip ON ip.pedido_id = ped.id
JOIN produto prod ON ip.produto_id = prod.id
GROUP BY ped.id, ped.dataPedido, ped.statusPedido, ped.observacao, usu.nome, pag.tipo;

-- =================================
-- 2) FUNCTIONS (pelo menos 4)
-- =================================

DELIMITER $$

-- 2.1 Valor total de um pedido
CREATE FUNCTION fn_calcula_valor_total(p_pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE total DECIMAL(10,2) DEFAULT 0;
  SELECT ROUND(SUM(ip.quantidade * pr.preco), 2)
  INTO total
  FROM item_pedido ip
  JOIN produto pr ON pr.id = ip.produto_id
  WHERE ip.pedido_id = p_pedido_id;
  RETURN IFNULL(total, 0);
END$$

-- 2.2 Contar produtos por categoria
CREATE FUNCTION fn_count_produtos_por_categoria(p_categoria_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE cnt INT;
  SELECT COUNT(*) INTO cnt
  FROM produto
  WHERE categoria_id = p_categoria_id;
  RETURN cnt;
END$$

-- 2.3 Total de pedidos por cliente
CREATE FUNCTION fn_total_pedidos_cliente(p_cliente_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total
  FROM pedido
  WHERE usuario_id = p_cliente_id;
  RETURN total;
END$$

-- 2.4 Média de preços por categoria
CREATE FUNCTION fn_media_preco_categoria(p_categoria_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE media DECIMAL(10,2);
  SELECT ROUND(AVG(preco), 2) INTO media
  FROM produto
  WHERE categoria_id = p_categoria_id;
  RETURN IFNULL(media, 0);
END$$

DELIMITER ;

-- =================================
-- 3) PROCEDURES (pelo menos 4)
-- =================================

DELIMITER $$

-- 3.1 Atualizar status do pedido
CREATE PROCEDURE sp_atualizar_status_pedido(
  IN p_pedido_id INT,
  IN p_novo_status VARCHAR(20)
)
BEGIN
  UPDATE pedido
  SET statusPedido = p_novo_status
  WHERE id = p_pedido_id;
END$$

-- 3.2 Inserir nova categoria
CREATE PROCEDURE sp_inserir_categoria(
  IN p_nome VARCHAR(100)
)
BEGIN
  INSERT INTO categoria(nome)
  VALUES (p_nome);
END$$

-- 3.3 Excluir pedido e seus itens
CREATE PROCEDURE sp_excluir_pedido(IN p_pedido_id INT)
BEGIN
  DELETE FROM item_pedido WHERE pedido_id = p_pedido_id;
  DELETE FROM pedido WHERE id = p_pedido_id;
END$$

-- 3.4 Atualizar preço de produto
CREATE PROCEDURE sp_atualizar_preco_produto(
  IN p_produto_id INT,
  IN p_novo_preco DECIMAL(10,2)
)
BEGIN
  UPDATE produto
  SET preco = p_novo_preco
  WHERE id = p_produto_id;
END$$

DELIMITER ;

-- ============================
-- 4) TRIGGERS (pelo menos 2)
-- ============================

DELIMITER $$

-- 4.1 Impedir exclusão de categoria com produtos vinculados
CREATE TRIGGER trg_prevent_categoria_delete
BEFORE DELETE ON categoria
FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM produto WHERE categoria_id = OLD.id) > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Não é possível deletar categoria com produtos vinculados';
  END IF;
END$$

-- 4.2 Impedir atualização de preço para valor negativo
CREATE TRIGGER trg_check_preco_nonnegative
BEFORE UPDATE ON produto
FOR EACH ROW
BEGIN
  IF NEW.preco < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Preço não pode ser negativo';
  END IF;
END$$

DELIMITER ;

-- =================================
-- 5) EXEMPLO DE TRANSAÇÃO (pelo menos 1)
-- =================================

START TRANSACTION;

  INSERT INTO pedido(dataPedido, statusPedido, observacao, usuario_id, pagamento_id)
  VALUES (CURDATE(), 'Em Processamento', 'Pedido via transação', 1, 2);

  SET @novo_pedido_id = LAST_INSERT_ID();

  INSERT INTO item_pedido(pedido_id, produto_id, quantidade)
  VALUES 
    (@novo_pedido_id, 1, 2),
    (@novo_pedido_id, 3, 1);

COMMIT;