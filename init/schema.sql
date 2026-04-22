CREATE TABLE IF NOT EXISTS produtos (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(200) NOT NULL,
    categoria  VARCHAR(100) NOT NULL,
    preco      DECIMAL(10,2) NOT NULL,
    estoque    INT NOT NULL DEFAULT 0,
    criado_em  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_categoria (categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS clientes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(200) NOT NULL,
    email      VARCHAR(200) UNIQUE NOT NULL,
    cidade     VARCHAR(100),
    criado_em  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS pedidos (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT NOT NULL,
    produto_id   INT NOT NULL,
    quantidade   INT NOT NULL DEFAULT 1,
    valor_total  DECIMAL(10,2) NOT NULL,
    status       ENUM('pendente','pago','enviado','entregue','cancelado') DEFAULT 'pendente',
    criado_em    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id),
    INDEX idx_status (status),
    INDEX idx_cliente (cliente_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
