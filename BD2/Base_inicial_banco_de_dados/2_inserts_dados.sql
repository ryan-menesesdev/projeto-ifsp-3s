-- Insert em Tabela CATEGORIA
INSERT INTO categoria (nome) VALUES
('Bolos'),
('Salgados'),
('Bebidas'),
('Sobremesas');

-- Insert em Tabela PAGAMENTO
INSERT INTO pagamento (tipo, statusPagamento) VALUES
('Pix', 'Aprovado'),
('Dinheiro', 'Aprovado'),
('Pix', 'Pendente'),
('Dinheiro', 'Aprovado'),
('Pix', 'Aprovado'),
('Dinheiro', 'Pendente'),
('Pix', 'Aprovado'),
('Dinheiro', 'Aprovado'),
('Pix', 'Pendente'),
('Dinheiro', 'Aprovado');

-- Insert em Tabela USUARIO
INSERT INTO usuario (nome, email, senha, telefone, cpf, tipoUsuario) VALUES
('Alice Silva', 'alice.s@email.com', 'hashAlice123', '11987654321', '111.222.333-44', 'Cliente'),
('Beto Rocha', 'beto.r@empresa.com', 'hashBeto456', '21998765432', '222.333.444-55', 'Funcionario'),
('Clara Dantas', 'clara.d@email.com', 'hashClara789', '31976543210', '333.444.555-66', 'Cliente'),
('Diogo Mendes', 'diogo.m@empresa.com', 'hashDiogo101', '41965432109', '444.555.666-77', 'Funcionario'),
('Eva Ferraz', 'eva.f@email.com', 'hashEva202', '51954321098', '555.666.777-88', 'Cliente'),
('Fábio Gomes', 'fabio.g@email.com', 'hashFabio303', '61943210987', '666.777.888-99', 'Cliente'),
('Giovanna Alves', 'giovanna.a@email.com', 'hashGiovanna404', '71932109876', '777.888.999-00', 'Cliente'),
('Heitor Cruz', 'heitor.c@email.com', 'hashHeitor505', '81921098765', '010.111.222-33', 'Cliente'),
('Isabela Lins', 'isabela.l@email.com', 'hashIsabela606', '91910987654', '020.222.333-44', 'Cliente'),
('Júlio Cesar', 'julio.c@email.com', 'hashJulio707', '11900000000', '030.333.444-55', 'Cliente');

-- Insert em Tabela PRODUTO
INSERT INTO produto (nome, descricao, preco, categoria_id) VALUES
('Bolo de Chocolate Simples', 'Um bolo de chocolate clássico', 45.00, 1),
('Bolo de Morango com Chantilly', 'Bolo refrescante com morangos frescos', 55.00, 1),
('Coxinha de Frango c/ Catupiry', 'Deliciosa coxinha com recheio cremoso', 8.00, 2),
('Mini Pão de Queijo', 'Porção com 6 mini pães de queijo', 12.00, 2),
('Refrigerante Cola 350ml', 'Lata de refrigerante de cola', 7.00, 3),
('Suco Natural de Laranja 300ml', 'Suco 100% natural e fresco', 9.50, 3),
('Mousse de Chocolate Belga', 'Mousse leve e intensa de chocolate', 18.00, 4),
('Torta de Limão Merengada', 'Torta azedinha com merengue maçaricado', 20.00, 4),
('Bolo de Cenoura com Brigadeiro', 'Bolo macio com cobertura de brigadeiro', 50.00, 1),
('Risole de Carne Seca', 'Risole crocante com recheio de carne seca', 9.50, 2);

-- Insert em Tabela PEDIDO
INSERT INTO pedido (dataPedido, statusPedido, observacao, usuario_id, pagamento_id) VALUES
('2025-06-05', 'Em Processamento', 'Cliente retirará as 18h.', 1, 1),
('2025-06-05', 'Concluído', 'Cliente retirou na loja atrasado.', 3, 2),
('2025-06-05', 'Em Processamento', 'Confirmar sabor do bolo para retirada.', 5, 1),
('2025-06-06', 'Concluído', 'Retirado por terceiro na loja.', 6, 2), 
('2025-06-06', 'Cancelado', 'Item indisponível. Cliente notificado para retirada de estorno.', 7, 1), 
('2025-06-06', 'Em Processamento', 'Pagamento pendente de confirmação para retirada.', 8, 2),
('2025-06-06', 'Concluído', 'Pedido foi uma surpresa! Retirado com sucesso.', 9, 1),
('2025-06-06', 'Em Processamento', 'Verificar estoque de sucos para retirada.', 10, 2),
('2025-06-07', 'Concluído', 'Cliente satisfeito após retirada.', 1, 1),
('2025-06-07', 'Em Processamento', 'Aguardando embalagem para retirada.', 3, 2);

-- Insert em Tabela ITEM_PEDIDO
INSERT INTO item_pedido (pedido_id, produto_id, quantidade) VALUES
(1, 1, 1),
(1, 5, 2),
(2, 3, 5),
(2, 7, 1),
(3, 2, 1),
(3, 6, 3),
(4, 4, 10),
(4, 8, 1),
(5, 9, 1),
(6, 10, 2);

-- Insert em Tabela ADMIN_PEDIDO
INSERT INTO admin_pedido (pedido_id, usuario_id, acaoRealizada, dataHora, comentario) VALUES
(1, 2, 'Status alterado', '2025-06-05 10:00:00', 'Cliente avisado sobre horário de entrega.'),
(2, 4, 'Comentário Adicionado', '2025-06-05 11:30:00', 'Retirada na loja confirmada.'),
(3, 2, 'Status alterado', '2025-06-05 14:00:00', 'Sabor do bolo confirmado: chocolate.'),
(4, 4, 'Status alterado', '2025-06-06 09:15:00', 'Pedido entregue na recepção.'),
(5, 2, 'Status alterado', '2025-06-06 10:30:00', 'Item de Bolo de Cenoura indisponível. Pedido cancelado.'),
(6, 4, 'Comentário Adicionado', '2025-06-06 11:45:00', 'Aguardando retorno do cliente para confirmação do pagamento.'),
(7, 2, 'Status alterado', '2025-06-06 13:00:00', 'Pedido concluído com sucesso e surpresa.'),
(8, 4, 'Comentário Adicionado', '2025-06-06 14:15:00', 'Refrigerantes em falta no estoque. Cliente avisado para possível substituição.'),
(9, 2, 'Status alterado', '2025-06-07 09:00:00', 'Feedback positivo do cliente registrado.'),
(10, 4, 'Comentário Adicionado', '2025-06-07 10:00:00', 'Priorizar embalagem deste pedido.');
