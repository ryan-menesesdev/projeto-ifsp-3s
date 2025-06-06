/************************************************************
 * Script: criação_banco.sql
 * Objetivo: criar o banco de dados e todas as tabelas do
 *          projeto de extensão, definindo PK, FK, tipos de dados
 *          e comentários explicativos.
 ************************************************************/

-- 1) Cria o banco de dados (substitua “projeto_extensao” pelo nome
--    específico que a equipe definiu, se houver outro nome sugerido).
CREATE DATABASE IF NOT EXISTS projeto_extensao
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
 
-- 2) Seleciona o banco recém-criado
USE projeto_extensao;

-------------------------------------------------------------------
-- TABELA: CATEGORIA
-- Objetivo: armazenar as categorias de produtos (ex.: Eletrônicos,
--           Livros, Vestuário, etc.).
-------------------------------------------------------------------
CREATE TABLE categoria (
    -- identificador único da categoria
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- nome descritivo da categoria
    nome VARCHAR(100) NOT NULL
);

-------------------------------------------------------------------
-- TABELA: PRODUTO
-- Objetivo: armazenar dados dos produtos oferecidos no sistema.
-------------------------------------------------------------------
CREATE TABLE produto (
    -- identificador único do produto
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- nome do produto
    nome VARCHAR(100) NOT NULL,
    
    -- descrição detalhada do produto
    descricao TEXT,
    
    -- preço unitário do produto (em R$)
    preco DECIMAL(10,2) NOT NULL,
    
    -- chave estrangeira para a tabela categoria
    categoria_id INT NOT NULL,
    
    -- define a FK que aponta para categoria(id)
    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categoria(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-------------------------------------------------------------------
-- TABELA: USUARIO
-- Objetivo: cadastrar todos os usuários do sistema, sejam clientes
--           ou funcionários. O campo tipoUsuario define se é ‘Cliente’
--           ou ‘Funcionario’.
-------------------------------------------------------------------
CREATE TABLE usuario (
    -- identificador único do usuário
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- nome completo do usuário (cliente ou funcionário)
    nome VARCHAR(100) NOT NULL,
    
    -- e-mail do usuário (deve ser único para login)
    email VARCHAR(100) NOT NULL UNIQUE,
    
    -- senha para autenticação (armazenar hash em produções reais)
    senha VARCHAR(255) NOT NULL,
    
    -- telefone de contato (pode incluir DDD e caracteres de formatação)
    telefone VARCHAR(20),
    
    -- CPF do usuário (formato: “000.000.000-00” ou somente números, conforme padrão)
    cpf VARCHAR(14) NOT NULL UNIQUE,
    
    -- define se o usuário é 'Funcionario' ou 'Cliente'
    tipoUsuario VARCHAR(20) NOT NULL
    -- Exemplo de valores: 'Funcionario', 'Cliente'
);

-------------------------------------------------------------------
-- TABELA: PAGAMENTO
-- Objetivo: registrar as formas/tipos de pagamento e o status
--           de cada uma (ex.: Pendente, Confirmado, Cancelado).
-------------------------------------------------------------------
CREATE TABLE pagamento (
    -- identificador único do pagamento
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- tipo de pagamento, ex: 'Cartão de Crédito', 'Boleto', 'Pix'
    tipo VARCHAR(50) NOT NULL,
    
    -- status do pagamento, ex: 'Pendente', 'Aprovado', 'Cancelado'
    status VARCHAR(20) NOT NULL
);

-------------------------------------------------------------------
-- TABELA: PEDIDO
-- Objetivo: representar cada pedido efetuado por um usuário, 
--           contendo data, status de processamento e vínculo com
--           o pagamento e o usuário que realizou.
-------------------------------------------------------------------
CREATE TABLE pedido (
    -- identificador único do pedido
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- data em que o pedido foi criado
    data DATE NOT NULL,
    
    -- status atual do pedido, ex: 'Em Processamento', 'Enviado', 'Concluído'
    status VARCHAR(20) NOT NULL,
    
    -- observações gerais sobre o pedido (anotações adicionais)
    observacao TEXT,
    
    -- FK para usuário(id), indica quem fez o pedido
    usuario_id INT NOT NULL,
    
    -- FK para pagamento(id), método de pagamento utilizado
    pagamento_id INT NOT NULL,
    
    -- define a FK que aponta para usuario(id)
    CONSTRAINT fk_pedido_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    
    -- define a FK que aponta para pagamento(id)
    CONSTRAINT fk_pedido_pagamento
        FOREIGN KEY (pagamento_id)
        REFERENCES pagamento(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-------------------------------------------------------------------
-- TABELA: ITEM_PEDIDO
-- Objetivo: relacionar cada item (produto) que faz parte de um pedido,
--           indicando a quantidade de cada produto naquele pedido.
-------------------------------------------------------------------
CREATE TABLE item_pedido (
    -- identificador único do item (no contexto do sistema)
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- FK para pedido(id), diz a qual pedido este item pertence
    pedido_id INT NOT NULL,
    
    -- FK para produto(id), diz qual produto está sendo pedido
    produto_id INT NOT NULL,
    
    -- quantidade solicitada deste produto dentro do pedido
    quantidade INT NOT NULL,
    
    -- define a FK que aponta para pedido(id)
    CONSTRAINT fk_itempedido_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedido(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    -- define a FK que aponta para produto(id)
    CONSTRAINT fk_itempedido_produto
        FOREIGN KEY (produto_id)
        REFERENCES produto(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-------------------------------------------------------------------
-- TABELA: ADMIN_PEDIDO
-- Objetivo: armazenar todas as ações administrativas feitas sobre um pedido,
--           como quem (funcionário) fez a ação, qual foi a ação, data/hora,
--           e comentários adicionais.
-------------------------------------------------------------------
CREATE TABLE admin_pedido (
    -- identificador único da ação administrativa
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- FK para pedido(id): indica qual pedido está sendo administrado
    pedido_id INT NOT NULL,
    
    -- FK para usuario(id): indica qual funcionário realizou a ação
    usuario_id INT NOT NULL,
    
    -- tipo de ação realizada (ex.: 'Status alterado', 'Comentário Adicionado', 'Estorno')
    acao VARCHAR(50) NOT NULL,
    
    -- data e hora em que a ação foi realizada
    dataHora DATETIME NOT NULL,
    
    -- observações ou comentários adicionais sobre esta ação
    comentario TEXT,
    
    -- define a FK que aponta para pedido(id)
    CONSTRAINT fk_adminpedido_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedido(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    -- define a FK que aponta para usuario(id)
    -- Observação: este usuário deve ser um funcionário (tipoUsuario='Funcionario')
    CONSTRAINT fk_adminpedido_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Fim do script de criação de tabelas.