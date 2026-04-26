INSERT INTO clientes (nome, email, cidade)
SELECT 
  CONCAT('Cliente ', @i := @i + 1) AS nome,
  CONCAT('cliente', @i, '@teste', @i, '.com') AS email,
  ELT(1 + FLOOR(RAND()*5),
      'São Paulo','Rio','BH','Curitiba','Porto Alegre') AS cidade
FROM 
  (SELECT @i := 0) init
CROSS JOIN information_schema.COLUMNS t1
CROSS JOIN information_schema.COLUMNS t2
LIMIT 500000;

INSERT INTO produtos (nome, categoria, preco, estoque)
SELECT
  CONCAT('Produto ', @i := @i + 1),
  ELT(1 + FLOOR(RAND()*4),
    'Eletrônicos','Roupas','Alimentos','Livros'),
  ROUND(RAND()*500,2),
  FLOOR(RAND()*100)
FROM 
  (SELECT @i := 0) init
CROSS JOIN information_schema.COLUMNS t1
CROSS JOIN information_schema.COLUMNS t2
LIMIT 500000;

INSERT INTO pedidos (cliente_id, produto_id, quantidade, valor_total, status)
SELECT
  c.id,
  p.id,
  FLOOR(1 + RAND()*5),
  ROUND(RAND()*1000,2),
  ELT(1 + FLOOR(RAND()*5),
    'pendente','pago','enviado','entregue','cancelado')
FROM 
  clientes c
JOIN produtos p
LIMIT 500000;
