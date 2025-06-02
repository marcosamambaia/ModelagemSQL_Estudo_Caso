/*****************************************************************************************8
********************************************************************************************
********************************************************************************************
*********************************ESTUDO DE CASO*********************************************
********************************************************************************************
********************************************************************************************/


create database db_estudo_de_caso;
use db_estudo_de_caso;

create table tbl_produto (
    id int not null primary key auto_increment,
    codigo int not null unique,
    nome varchar(100) not null,
    categoria varchar(45), 
    preco float not null, 
    estoque int not null, 
    fornecedor varchar(100)
);

create table tbl_colaborador (
    id int not null primary key auto_increment,
    nome varchar(100) not null,
    cpf varchar(45), 
    setor varchar(45)
);

create table tbl_cliente (
    id int not null primary key auto_increment,
    nome varchar(100) not null,
    cpf varchar(45),
    historico text
);

create table tbl_endereco (
    id int not null primary key auto_increment,
    logradouro varchar(45),  -- Corrigido
    bairro varchar(45),
    cep varchar(45),
    cidade varchar(45),
    estado varchar(45),
    pais varchar(45),
    id_cliente int not null,
    
    constraint FK_Cliente_Endereco
    foreign key (id_cliente)
    references tbl_cliente (id)
);

create table tbl_email (
    id int not null primary key auto_increment,
    email varchar(255) not null,
    id_cliente int not null,
    
    constraint FK_Cliente_Email
    foreign key (id_cliente)
    references tbl_cliente (id)
);

create table tbl_telefone (
    id int not null primary key auto_increment,
    numero varchar(15) not null,
    id_cliente int not null,
    
    constraint FK_Cliente_Telefone
    foreign key (id_cliente)
    references tbl_cliente (id)
);

create table tbl_venda (
    id int not null primary key auto_increment,
    data_Compra date not null,
    hora datetime,
    forma_pagamento varchar(45),
    id_cliente int not null,
    id_colaborador int not null,
    
    constraint FK_Cliente_Venda
    foreign key (id_cliente)
    references tbl_cliente (id),
    
    constraint FK_Colaborador_Venda
    foreign key (id_colaborador)
    references tbl_colaborador (id)
);

create table tbl_compra_produto (
    id int not null primary key auto_increment,
    quantidade int not null,
    id_venda int not null,
    id_produto int not null,
    
    constraint FK_Venda_Compra_Produto
    foreign key (id_venda)
    references tbl_venda (id),
    
    constraint FK_Produto_Compra_Produto
    foreign key (id_produto)
    references tbl_produto (id)
);

-- Definir um delimitador para agrupar comandos no trigger
DELIMITER $$

-- Trigger que reduz o estoque após uma venda
CREATE TRIGGER trg_update_estoque
AFTER INSERT ON tbl_compra_produto -- O trigger será ativado após uma inserção em tbl_compra_produto
FOR EACH ROW -- Executa a ação para cada nova linha inserida
BEGIN
    -- Atualiza o estoque subtraindo a quantidade vendida
    UPDATE tbl_produto
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.id_produto;
END $$

-- Resetar o delimitador padrão
DELIMITER ;

-- Definir um novo delimitador para agrupar o próximo trigger
DELIMITER $$

-- Trigger que impede venda se não houver estoque suficiente
CREATE TRIGGER trg_verifica_estoque
BEFORE INSERT ON tbl_compra_produto -- O trigger será ativado antes de uma inserção em tbl_compra_produto
FOR EACH ROW -- Executa a ação para cada nova linha inserida
BEGIN
    DECLARE estoque_atual INT; -- Declara uma variável para armazenar o estoque atual

    -- Obtém o estoque do produto antes da venda
    SELECT estoque INTO estoque_atual FROM tbl_produto WHERE id = NEW.id_produto;

    -- Se o estoque for menor que a quantidade desejada, bloqueia a inserção
    IF estoque_atual < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000' -- Gera um erro personalizado
        SET MESSAGE_TEXT = 'Erro: Estoque insuficiente para esta venda!';
    END IF;
END $$

-- Resetar o delimitador padrão
DELIMITER ;



/************************************************************************************************************************
**************************************************************************************************************************
**************************PARTE DE TESTES E SIMULAÇOES******************************************************************/

-- Inserir produtos
INSERT INTO tbl_produto (codigo, nome, categoria, preco, estoque, fornecedor) VALUES
(101, 'Notebook Dell Inspiron', 'Eletrônicos', 3500.00, 10, 'Dell'),
(102, 'Smartphone Samsung Galaxy S22', 'Eletrônicos', 4200.00, 15, 'Samsung'),
(103, 'Geladeira Brastemp Frost Free', 'Eletrodomésticos', 3200.00, 8, 'Brastemp'),
(104, 'Cadeira Gamer Xtreme', 'Móveis', 850.00, 20, 'Xtreme Comfort'),
(105, 'Arroz Branco Tipo 1', 'Alimentos', 25.00, 50, 'Camil'),
(106, 'Feijão Preto', 'Alimentos', 12.00, 40, 'Kikaldo'),
(107, 'Óleo de Soja', 'Alimentos', 9.00, 60, 'Soya'),
(108, 'Leite Integral 1L', 'Laticínios', 6.00, 80, 'Italac');

-- Inserir colaboradores
INSERT INTO tbl_colaborador (nome, cpf, setor) VALUES
('Carlos Silva', '12345678900', 'Vendas'),
('Fernanda Souza', '98765432100', 'Administração');

-- Inserir clientes
INSERT INTO tbl_cliente (nome, cpf, historico) VALUES
('João Pereira', '11122233344', 'Cliente frequente, já realizou 5 compras.'),
('Maria Oliveira', '55566677788', 'Primeira compra no sistema.');

SELECT * FROM tbl_produto;
SELECT * FROM tbl_colaborador;
SELECT * FROM tbl_cliente;


#cliente comprando
INSERT INTO tbl_venda (data_Compra, hora, forma_pagamento, id_cliente, id_colaborador) 
VALUES ('2025-06-02', NOW(), 'Pix', 2, 2);

#registrar compra do produto
INSERT INTO tbl_compra_produto (quantidade, id_venda, id_produto) 
VALUES (5, 2, 16); -- Cliente comprou 5 unidades do leite (id_produto = 16)

#Verificar o estoque atualizado
SELECT nome, estoque FROM tbl_produto WHERE id = 16;

/*******************************************************************************************************************************
**********************************   Testes OK!!!  *****************************************************************************/