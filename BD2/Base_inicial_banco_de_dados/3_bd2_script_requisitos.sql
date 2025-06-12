-- ===================================================================
-- Arquivo: pendencias_requisitos.sql
-- Objetivo: implementar Views (≥4), Functions+Procedures (≥4), 
--           Triggers (≥2) e Transação (≥1) conforme requisitos.
-- Baseado no DER fornecido (Admin_Pedido, Usuario, Pedido, Item_Pedido,
-- Produto, Categoria, Pagamento).
-- ===================================================================

-- ============================
-- 1) VIEWS (pelo menos 4)
-- ============================

-- 1.1 Clientes cadastrados
CREATE OR REPLACE VIEW vw_usuarios_clientes AS
SELECT id       AS cliente_id,
       nome,
       email
FROM usuario
WHERE tipoUsuario = 'Cliente';

-- 1.2 Produtos sem nenhum pedido
CREATE OR REPLACE VIEW vw_produtos_sem_pedidos AS
SELECT p.id     AS produto_id,
       p.nome,
       p.preco
FROM produto p
LEFT JOIN item_pedido ip ON p.id = ip.produto_id
WHERE ip.pedido_id IS NULL;

-- 1.3 Total de itens por pedido
CREATE OR REPLACE VIEW vw_total_itens_por_pedido AS
SELECT pedido_id,
       SUM(quantidade) AS total_itens
FROM item_pedido
GROUP BY pedido_id;

-- 1.4 Detalhes completos de cada pedido (valor total incluso)
CREATE OR REPLACE VIEW vw_pedido_detalhes AS
SELECT ped.id                AS pedido_id,
       ped.data,
       ped.status,
       ped.observacao,
       usu.nome               AS cliente,
       pag.tipo               AS pagamento_tipo,
       ROUND(SUM(ip.quantidade * prod.preco),2) AS valor_total
FROM pedido      ped
JOIN usuario     usu ON ped.usuario_id   = usu.id
JOIN pagamento   pag ON ped.pagamento_id = pag.id
JOIN item_pedido ip  ON ip.pedido_id     = ped.id
JOIN produto     prod ON ip.produto_id   = prod.id
GROUP BY ped.id, ped.data, ped.status, ped.observacao, usu.nome, pag.tipo;


-- =================================
-- 2) FUNCTIONS (pelo menos 2)
-- =================================

DELIMITER $$
CREATE FUNCTION fn_calcula_valor_total(p_pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE total DECIMAL(10,2) DEFAULT 0;
  SELECT ROUND(SUM(ip.quantidade * pr.preco),2)
    INTO total
  FROM item_pedido ip
  JOIN produto pr ON pr.id = ip.produto_id
  WHERE ip.pedido_id = p_pedido_id;
  RETURN IFNULL(total,0);
END$$
DELIMITER ;

DELIMITER $$
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
DELIMITER ;


-- =================================
-- 3) PROCEDURES (pelo menos 2)
-- =================================

DELIMITER $$
CREATE PROCEDURE sp_atualizar_status_pedido(
  IN p_pedido_id   INT,
  IN p_novo_status VARCHAR(20)
)
BEGIN
  UPDATE pedido
    SET status = p_novo_status
  WHERE id = p_pedido_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_inserir_categoria(
  IN p_nome VARCHAR(100)
)
BEGIN
  INSERT INTO categoria(nome)
    VALUES (p_nome);
END$$
DELIMITER ;


-- ============================
-- 4) TRIGGERS (pelo menos 2)
-- ============================

DELIMITER $$
CREATE TRIGGER trg_prevent_categoria_delete
BEFORE DELETE ON categoria
FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM produto WHERE categoria_id = OLD.id) > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Não é possível deletar categoria com produtos vinculados';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
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
  INSERT INTO pedido(data, status, observacao, usuario_id, pagamento_id)
    VALUES (CURDATE(), 'Em Processamento', 'Pedido via transação', 1, 2);
  INSERT INTO item_pedido(pedido_id, produto_id, quantidade)
    VALUES (LAST_INSERT_ID(), 1, 2),
           (LAST_INSERT_ID(), 3, 1);
COMMIT;
