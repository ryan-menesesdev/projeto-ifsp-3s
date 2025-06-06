/************************************************************
 * Script: inserts_dados.sql
 * Objetivo: popular as tabelas com dados iniciais representativos,
 *           obedecendo a todas as restrições de PK e FK criadas.
 ************************************************************/

/****************************************************************
 * 1) Inserir categorias de exemplo
 ****************************************************************/
INSERT INTO categoria (nome) VALUES
    ('Bolos'),
    ('Salgados'),
    ('Sobremesas'),
    ('Bebidas');

-- Suponha que ficaram os IDs:
-- id=1 → Bolos
-- id=2 → Salgados
-- id=3 → Sobremesas
-- id=4 → Bebidas

/****************************************************************
 * 2) Inserir produtos de exemplo, vinculando categorias
 ****************************************************************/
INSERT INTO produto (nome, descricao, preco, categoria_id) VALUES
    ('Bolo1',
     'Bolo com recheio de bolo, 1kg de peso.',
     209.90,
     1),   -- pertence à categoria Bolos

    ('Bolo2',
     'Bolo com recheio de bolo2, 500g de peso.',
     104.45,
     1),   -- pertence à categoria Bolos

    ('Salgado1',
     'Muitos salgados',
     89.90,
     2),   -- pertence à categoria Salgados
     
    ('Sobremesa1',
     'Sobremesa, pudim.',
     39.90,
     3),   -- pertence à categoria Sobremesas

    ('Bebida1',
     'Bebida, água.',
     3.90,
     4);   -- pertence à categoria Bebidas
     

/****************************************************************
 * 3) Inserir usuários de exemplo (clientes e funcionários)
 ****************************************************************/
-- Cliente 1
INSERT INTO usuario (nome, email, senha, telefone, cpf, tipoUsuario) VALUES
    ('Ana Silva',
     'ana.silva@example.com',
     -- Em sistemas reais, esse campo deve guardar apenas o hash da senha.
     'senha123',
     '(11) 98765-4321',
     '123.456.789-00',
     'Cliente');

-- Funcionário 1
INSERT INTO usuario (nome, email, senha, telefone, cpf, tipoUsuario) VALUES
    ('João Oliveira',
     'joao.oliveira@empresa.com',
     'senhaFunc!',
     '(11) 91234-5678',
     '987.654.321-00',
     'Funcionario');

-- Cliente 2
INSERT INTO usuario (nome, email, senha, telefone, cpf, tipoUsuario) VALUES
    ('Carlos Pereira',
     'carlos.pereira@example.com',
     'complexaSenha',
     '(11) 99876-5432',
     '111.222.333-44',
     'Cliente');

-- Após estes INSERTs, suponha que:
-- Ana Silva     → id = 1
-- João Oliveira → id = 2
-- Carlos Pereira→ id = 3

/****************************************************************
 * 4) Inserir meios de pagamento de exemplo
 ****************************************************************/
INSERT INTO pagamento (tipo, status) VALUES
    ('Dinheiro', 'Pendente'),
    ('Pix', 'Aprovado');

-- Suponha que:
-- id=1 → Dinheiro / Pendente
-- id=2 → Pix / Aprovado

/****************************************************************
 * 5) Inserir pedidos de exemplo
 ****************************************************************/
-- Pedido 1: feito por Ana Silva (usuario_id=1), paga via Cartão (pagamento_id=1)
INSERT INTO pedido (data, status, observacao, usuario_id, pagamento_id) VALUES
    ('2025-06-01',              -- data do pedido
     'Em Processamento',        -- status atual
     'Entregar à noite, se possível.', -- observação adicional
     1,                         -- usuário 'Ana Silva'
     1);                        -- pagamento: Cartão de Crédito / Aprovado

-- Pedido 2: feito por Carlos Pereira (usuario_id=3), paga via Boleto (pagamento_id=2)
INSERT INTO pedido (data, status, observacao, usuario_id, pagamento_id) VALUES
    ('2025-06-02',
     'Aguardando Pagamento',
     'Consultar disponibilidade antes de confirmar.',
     3,
     2);

-- Suponha que:
-- Pedido 1 → id = 1
-- Pedido 2 → id = 2

/****************************************************************
 * 6) Inserir itens vinculados aos pedidos (item_pedido)
 ****************************************************************/
-- Para o Pedido 1 (id=1), Ana Silva:
--   2x Smartphone XYZ (produto_id=1)
--   1x Livro "Aprendendo SQL" (produto_id=3)
INSERT INTO item_pedido (pedido_id, produto_id, quantidade) VALUES
    (1, 1, 2),  -- 2 unidades do produto com id=1 (Smartphone XYZ)
    (1, 3, 1);  -- 1 unidade do produto id=3 (Livro “Aprendendo SQL”)

-- Para o Pedido 2 (id=2), Carlos Pereira:
--   1x Notebook UltraFit (produto_id=2)
--   3x Camiseta Básica (produto_id=4)
INSERT INTO item_pedido (pedido_id, produto_id, quantidade) VALUES
    (2, 2, 1),  -- 1 unidade do Notebook UltraFit
    (2, 4, 3);  -- 3 unidades da Camiseta Básica

/****************************************************************
 * 7) Inserir ações administrativas sobre pedidos (admin_pedido)
 ****************************************************************/
-- Suponha que o funcionário João Oliveira (usuario_id=2) fez uma
-- atualização de status no Pedido 1 em 01/06/2025 às 20:15:
INSERT INTO admin_pedido (pedido_id, usuario_id, acao, dataHora, comentario) VALUES
    (1,                   -- referente ao Pedido 1
     2,                   -- ação feita pelo Funcionário João Oliveira (id=2)
     'Status alterado para Enviado',
     '2025-06-01 20:15:00',
     'Pedido conferido e expedido para transportadora.');

-- Para o Pedido 2, João Oliveira gerou um comentário em 02/06/2025 às 16:30:
INSERT INTO admin_pedido (pedido_id, usuario_id, acao, dataHora, comentario) VALUES
    (2,
     2,
     'Comentário adicionado',
     '2025-06-02 16:30:00',
     'Cliente solicitou confirmação de estoque de Notebook UltraFit.');

-- Fim do script de inserção de dados.