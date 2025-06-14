-- Definição do Banco de Dados
CREATE DATABASE IF NOT EXISTS sinha_bolos_e_lanches; -- Cria o banco de dados 'sinha_bolos_e_lanches' se não existir

USE sinha_bolos_e_lanches;                           -- Seleciona o banco de dados para uso

-- TABELA: CATEGORIA
-- Define os tipos de produtos que a loja vende.
CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,                             -- Identificador único para cada categoria
    nome VARCHAR(100) NOT NULL,                                    -- Nome da categoria (ex: 'Bolos', 'Salgados')
    CHECK (nome IN ('Bolos', 'Salgados', 'Bebidas', 'Sobremesas')) -- Garante que o nome seja um dos tipos permitidos
);

-- TABELA: PRODUTO
-- Armazena os detalhes de cada item disponível para compra.
CREATE TABLE produto (
    id INT AUTO_INCREMENT PRIMARY KEY,                  -- Identificador único para cada produto
    nome VARCHAR(100) NOT NULL,                         -- Nome do produto (ex: 'Bolo de Chocolate')
    descricao VARCHAR(100),                             -- Uma breve descrição do produto
    preco DECIMAL(10,2) NOT NULL,                       -- O preço do produto
    categoria_id INT NOT NULL,                          -- Chave estrangeira para a categoria do produto
    FOREIGN KEY (categoria_id) REFERENCES categoria(id) -- Vincula o produto à sua categoria
);

-- TABELA: USUARIO
-- Contém as informações de todos os usuários, sejam clientes ou funcionários.
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,                -- Identificador único para cada usuário
    nome VARCHAR(100) NOT NULL,                       -- Nome completo do usuário
    email VARCHAR(100) NOT NULL UNIQUE,               -- Endereço de e-mail exclusivo do usuário
    senha VARCHAR(255) NOT NULL,                      -- Senha (geralmente um hash) do usuário
    telefone VARCHAR(20),                             -- Número de telefone do usuário
    cpf VARCHAR(14) NOT NULL UNIQUE,                  -- CPF exclusivo do usuário (ex: 'XXX.XXX.XXX-XX')
    tipoUsuario VARCHAR(20) NOT NULL,                 -- Indica se o usuário é 'Funcionario' ou 'Cliente'
    CHECK (tipoUsuario IN ('Funcionario', 'Cliente')) -- Restringe os tipos de usuário permitidos
);

-- TABELA: PAGAMENTO
-- Registra cada transação de pagamento.
CREATE TABLE pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,                    -- Identificador único para cada transação de pagamento
    tipo VARCHAR(30) NOT NULL,                            -- O tipo de pagamento utilizado (ex: 'Pix', 'Dinheiro')
    statusPagamento VARCHAR(20) NOT NULL,                 -- O status atual da transação (ex: 'Pendente', 'Aprovado')
    CHECK (tipo IN ('Pix', 'Dinheiro')),                  -- Garante que o tipo de pagamento seja 'Pix' ou 'Dinheiro'
    CHECK (statusPagamento IN ('Pendente', 'Aprovado'))   -- Garante que o status seja 'Pendente' ou 'Aprovado'
);

-- TABELA: PEDIDO
-- Registra os pedidos feitos pelos clientes.
CREATE TABLE pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,                                                 -- Identificador único para cada pedido
    dataPedido DATE NOT NULL,                                                          -- A data em que o pedido foi realizado
    statusPedido VARCHAR(100) NOT NULL,                                                -- O status atual do pedido (ex: 'Em Processamento', 'Concluído')
    observacao VARCHAR(100),                                                           -- Anotações ou detalhes sobre o pedido (ex: "cliente retirará às 18h")
    usuario_id INT NOT NULL,                                                           -- Chave estrangeira para o usuário que fez o pedido
    pagamento_id INT NOT NULL,                                                         -- Chave estrangeira para a transação de pagamento do pedido
    FOREIGN KEY (usuario_id) REFERENCES usuario(id),                                   -- Vincula o pedido ao cliente
    FOREIGN KEY (pagamento_id) REFERENCES pagamento(id),                               -- Vincula o pedido à sua transação de pagamento
    CHECK (statusPedido IN ('Em Processamento', 'Concluído', 'Cancelado', 'Entregue')) -- Restringe os status do pedido
);

-- TABELA: ITEM_PEDIDO
-- Detalha quais produtos e em que quantidade estão incluídos em cada pedido.
CREATE TABLE item_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,                    -- Identificador único para cada item dentro de um pedido
    pedido_id INT NOT NULL,                               -- Chave estrangeira para o pedido correspondente
    produto_id INT NOT NULL,                              -- Chave estrangeira para o produto do item
    quantidade INT NOT NULL,                              -- A quantidade do produto neste item do pedido
    FOREIGN KEY (pedido_id) REFERENCES pedido(id),         -- Vincula o item ao pedido;
    FOREIGN KEY (produto_id) REFERENCES produto(id)       -- Vincula o item ao produto
);

-- TABELA: ADMIN_PEDIDO
-- Registra as ações administrativas realizadas por funcionários em relação aos pedidos.
CREATE TABLE admin_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,                 -- Identificador único para cada registro de ação administrativa
    pedido_id INT NOT NULL,                            -- Chave estrangeira para o pedido que foi administrado
    usuario_id INT NOT NULL,                           -- Chave estrangeira para o funcionário que realizou a ação
    acaoRealizada VARCHAR(100) NOT NULL,               -- A descrição da ação (ex: 'Status alterado', 'Comentário Adicionado')
    dataHora DATETIME NOT NULL,                        -- A data e hora em que a ação foi registrada
    comentario VARCHAR(100),                           -- Comentários adicionais sobre a ação
    FOREIGN KEY (pedido_id) REFERENCES pedido(id),      -- Vincula a ação ao pedido;
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)    -- Vincula a ação ao funcionário
);
