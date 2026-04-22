#!/usr/bin/env python3
import mysql.connector
import time
import os
import statistics

READYSET_HOST = os.getenv("READYSET_HOST", "readyset")
READYSET_PORT = int(os.getenv("READYSET_PORT", 3307))
MYSQL_HOST    = os.getenv("MYSQL_HOST", "mysql")
MYSQL_PORT    = int(os.getenv("MYSQL_PORT", 3306))
DB_USER       = os.getenv("DB_USER", "rsuser")
DB_PASS       = os.getenv("DB_PASS", "readyset")
DB_NAME       = os.getenv("DB_NAME", "demo")
RETRIES       = int(os.getenv("STARTUP_RETRIES", 10))


def connect(host, port):
    for i in range(RETRIES):
        try:
            conn = mysql.connector.connect(
                host=host, port=port,
                user=DB_USER, password=DB_PASS,
                database=DB_NAME,
            )
            return conn
        except Exception:
            print(f"  [WAIT] Tentando {host}:{port} ({i+1}/{RETRIES})...")
            time.sleep(3)
    raise Exception(f"Nao foi possivel conectar em {host}:{port}")


def benchmark(cursor, query, runs=5):
    times = []
    for _ in range(runs):
        t0 = time.time()
        cursor.execute(query)
        cursor.fetchall()
        times.append((time.time() - t0) * 1000)
    return statistics.mean(times)


def create_cache(cursor, name, query):
    clean = " ".join(query.split())
    try:
        cursor.execute(f"CREATE CACHE {name} FROM {clean}")
        print(f"  [OK] Cache '{name}' criado")
    except Exception as e:
        msg = str(e).lower()
        if "already exists" in msg or "duplicate" in msg:
            print(f"  [OK] Cache '{name}' ja existe")
        else:
            print(f"  [AVISO] {name}: {e}")


def main():
    print("=" * 60)
    print("  ReadySet + MySQL -- Demo de Cache")
    print("=" * 60)

    print("\n[1] Conectando...")
    rs_conn    = connect(READYSET_HOST, READYSET_PORT)
    rs_cursor  = rs_conn.cursor()
    print(f"  [OK] ReadySet ({READYSET_HOST}:{READYSET_PORT})")

    my_conn    = connect(MYSQL_HOST, MYSQL_PORT)
    my_cursor  = my_conn.cursor()
    print(f"  [OK] MySQL ({MYSQL_HOST}:{MYSQL_PORT})")

    print("\n[2] Aguardando ReadySet ficar pronto...")
    time.sleep(10)

    queries = {
        "pedidos_por_status": """
            SELECT status, COUNT(*) AS total
            FROM pedidos
            GROUP BY status
        """,
        "produtos_informatica": """
            SELECT nome, preco, estoque
            FROM produtos
            WHERE categoria = 'Informatica'
            ORDER BY preco DESC
        """,
        "top_clientes": """
            SELECT cliente_id, COUNT(*) AS total
            FROM pedidos
            GROUP BY cliente_id
            ORDER BY total DESC
            LIMIT 10
        """
    }

    print("\n[3] Sem cache -- baseline")
    print("-" * 60)
    results = {}
    for name, query in queries.items():
        rs_time = benchmark(rs_cursor, query)
        my_time = benchmark(my_cursor, query)
        results[name] = {"rs": rs_time, "mysql": my_time}
        print(f"  {name}")
        print(f"    ReadySet (sem cache): {rs_time:.1f} ms")
        print(f"    MySQL direto:         {my_time:.1f} ms")

    print("\n[4] Criando caches no ReadySet")
    print("-" * 60)
    for name, query in queries.items():
        create_cache(rs_cursor, name, query)

    print("\n[5] Warmup (primeira execucao com cache)...")
    for query in queries.values():
        clean = " ".join(query.split())
        rs_cursor.execute(clean)
        rs_cursor.fetchall()

    print("\n[6] Com cache ativo")
    print("-" * 60)
    for name, query in queries.items():
        rs_time = benchmark(rs_cursor, query)
        my_time = results[name]["mysql"]
        ganho   = my_time / rs_time if rs_time > 0 else 0
        print(f"  {name}")
        print(f"    MySQL direto:         {my_time:.1f} ms")
        print(f"    ReadySet com cache:   {rs_time:.2f} ms  ({ganho:.1f}x mais rapido)")

    print("\n[7] Testando invalidacao automatica via binlog")
    print("-" * 60)
    my_cursor.execute(
        "INSERT INTO pedidos (cliente_id, produto_id, quantidade, valor_total, status) "
        "VALUES (1, 1, 1, 100.0, 'pendente')"
    )
    my_conn.commit()
    print("  [INSERT] Novo pedido inserido direto no MySQL")
    time.sleep(2)

    rs_cursor.execute("SELECT status, COUNT(*) AS total FROM pedidos GROUP BY status")
    rows = rs_cursor.fetchall()
    print("  [CACHE] Resultado atualizado automaticamente:")
    for r in rows:
        print(f"    {r[0]:<12}: {r[1]} pedidos")

    rs_cursor.close(); rs_conn.close()
    my_cursor.close(); my_conn.close()

    print("\n[CONCLUIDO] Demo finalizado!")
    print("=" * 60)


if __name__ == "__main__":
    main()
