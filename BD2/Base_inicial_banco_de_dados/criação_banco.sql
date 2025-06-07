CREATE DATABASE IF NOT EXISTS projeto_extensao;
 
USE projeto_extensao;

-- TABELA: CATEGORIA
CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    CHECK (nome IN ('Bolos', 'Salgados', 'Bebidas', 'Sobremesas'))
);

-- TABELA: PRODUTO
CREATE TABLE produto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(100),
    preco DECIMAL(10,2) NOT NULL,
    categoria_id INT NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

-- TABELA: USUARIO
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    cpf VARCHAR(14) NOT NULL UNIQUE,

    -- 'Funcionario' ou 'Cliente'
    tipoUsuario VARCHAR(20) NOT NULL,
    CHECK (tipoUsuario IN ('Funcionario', 'Cliente')) 
);

-- TABELA: PAGAMENTO
CREATE TABLE pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- 'Pix' ou 'Dinheiro'
    tipo VARCHAR(30) NOT NULL,

    -- 'Pix' ou 'Dinheiro'
    statusPagamento VARCHAR(20) NOT NULL,
    CHECK (tipo IN ('Pix', 'Dinheiro')),
    CHECK (statusPagamento IN ('Pendente', 'Aprovado'))
);

-- TABELA: PEDIDO
CREATE TABLE pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dataPedido DATE NOT NULL,

    -- 'Em Processamento', 'Concluído', 'Cancelado' ou 'Entregue'
    statusPedido VARCHAR(100) NOT NULL,
    observacao VARCHAR(100),
    usuario_id INT NOT NULL,
    pagamento_id INT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
    FOREIGN KEY (pagamento_id) REFERENCES pagamento(id)
    CHECK (statusPedido IN ('Em Processamento', 'Concluído', 'Cancelado', 'Entregue'))
);

-- TABELA: ITEM_PEDIDO
CREATE TABLE item_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedido(id)
    FOREIGN KEY (produto_id) REFERENCES produto(id)
);

-- TABELA: ADMIN_PEDIDO
CREATE TABLE admin_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    usuario_id INT NOT NULL,
    acaoRealizada VARCHAR(100) NOT NULL,
    dataHora DATETIME NOT NULL,
    comentario VARCHAR(100),
    FOREIGN KEY (pedido_id) REFERENCES pedido(id)
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);
