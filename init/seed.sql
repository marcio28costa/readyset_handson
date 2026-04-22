INSERT INTO produtos (nome, categoria, preco, estoque) VALUES
('Notebook Pro 15', 'Informatica', 4999.90, 50),
('Mouse Sem Fio', 'Informatica', 89.90, 200),
('Teclado Mecanico', 'Informatica', 349.90, 80),
('Monitor 27 4K', 'Informatica', 2199.90, 30),
('Headset Gamer', 'Informatica', 599.90, 60),
('Camiseta Premium', 'Vestuario', 79.90, 300),
('Tenis Running', 'Calcados', 399.90, 120),
('Mochila Executiva', 'Acessorios', 249.90, 90),
('Cafeteira Express', 'Eletrodomesticos', 899.90, 45),
('Livro: Clean Code', 'Livros', 79.90, 150);

INSERT INTO clientes (nome, email, cidade) VALUES
('Ana Souza', 'ana@demo.com', 'Sao Paulo'),
('Bruno Lima', 'bruno@demo.com', 'Rio de Janeiro'),
('Carlos Mota', 'carlos@demo.com', 'Belo Horizonte'),
('Diana Ferreira', 'diana@demo.com', 'Curitiba'),
('Eduardo Costa', 'eduardo@demo.com', 'Porto Alegre'),
('Fernanda Alves', 'fernanda@demo.com', 'Ribeirao Preto'),
('Gabriel Rocha', 'gabriel@demo.com', 'Campinas'),
('Helena Nunes', 'helena@demo.com', 'Salvador');

INSERT INTO pedidos (cliente_id, produto_id, quantidade, valor_total, status) VALUES
(1, 1, 1, 4999.90, 'entregue'), (1, 2, 2, 179.80, 'entregue'),
(2, 3, 1, 349.90, 'pago'), (3, 4, 1, 2199.90, 'enviado'),
(4, 5, 1, 599.90, 'pendente'), (5, 6, 3, 239.70, 'pago'),
(6, 7, 1, 399.90, 'entregue'), (7, 8, 2, 499.80, 'enviado'),
(8, 9, 1, 899.90, 'pendente'), (1, 10, 2, 159.80, 'pago'),
(2, 1, 1, 4999.90, 'pago'), (3, 2, 3, 269.70, 'entregue'),
(4, 3, 2, 699.80, 'enviado'), (5, 4, 1, 2199.90, 'pendente'),
(6, 5, 1, 599.90, 'pago');

GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'rsuser'@'%';
FLUSH PRIVILEGES;
