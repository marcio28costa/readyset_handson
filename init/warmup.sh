#!/bin/bash

# Cache: pedidos_status
mysql -h 127.0.0.1 -P 3307 -u rsuser -preadyset demo \
  -e "SELECT status, COUNT(*) AS total, SUM(valor_total) AS receita FROM pedidos GROUP BY status;"

# Cache: produtos_categoria (exemplo com uma categoria)
mysql -h 127.0.0.1 -P 3307 -u rsuser -preadyset demo \
  -e "SELECT nome, preco, estoque FROM produtos WHERE categoria = 'eletronicos' ORDER BY preco DESC;"

# Cache: top_clientes
mysql -h 127.0.0.1 -P 3307 -u rsuser -preadyset demo \
  -e "SELECT c.nome, COUNT(p.id) AS num_pedidos, SUM(p.valor_total) AS total_gasto FROM clientes c JOIN pedidos p ON c.id = p.cliente_id GROUP BY c.id, c.nome ORDER BY total_gasto DESC;"
