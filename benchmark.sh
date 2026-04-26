#!/usr/bin/env bash
# ================================================================
#  benchmark.sh — ReadySet vs MySQL direto
#  Uso: ./benchmark.sh
# ================================================================

RS="mysql -h 127.0.0.1 -P 3307 -u rsuser -preadyset demo"
MY="mysql -h 127.0.0.1 -P 3306 -u rsuser -preadyset demo"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

declare -A QUERIES
QUERIES["pedidos_por_status"]="SELECT status, COUNT(*) AS total, SUM(valor_total) AS receita FROM pedidos GROUP BY status"
QUERIES["top_gastadores"]="SELECT c.nome, CAST(SUM(pe.valor_total) AS UNSIGNED) AS total_gasto, COUNT(*) AS pedidos FROM pedidos pe JOIN clientes c ON pe.cliente_id = c.id GROUP BY c.id, c.nome HAVING SUM(pe.valor_total) > 10000 ORDER BY total_gasto DESC LIMIT 10"
QUERIES["produtos_informatica"]="SELECT nome, preco, estoque FROM produtos WHERE categoria = 'Informatica' ORDER BY preco DESC"

RUNS=5

run_ms() {
    local cmd=$1 query=$2
    local total=0
    for i in $(seq 1 $RUNS); do
        ms=$( { time $cmd -e "$query" > /dev/null; } 2>&1 | grep real | sed 's/.*m//;s/s//' )
        ms=$(echo "$ms * 1000" | bc)
        total=$(echo "$total + $ms" | bc)
    done
    echo "scale=0; $total / $RUNS" | bc
}

speedup() {
    echo "scale=1; $1 / $2" | bc 2>/dev/null
}

bar() {
    local s=${1%.*}
    local b=""
    for i in $(seq 1 $(( s > 20 ? 20 : s ))); do b+="█"; done
    echo "$b"
}

echo ""
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}  ReadySet + MySQL — Benchmark Shell  (${RUNS} runs por query)${NC}"
echo -e "${BOLD}================================================================${NC}"

# Verifica conexões
echo -e "\n${CYAN}[1] Verificando conexoes...${NC}"
$RS -e "SELECT 'ReadySet OK'" 2>/dev/null | grep -q "OK" && \
    echo -e "  ${GREEN}[OK]${NC} ReadySet  127.0.0.1:3307" || \
    { echo -e "  ${RED}[ERRO]${NC} ReadySet nao disponivel"; exit 1; }
$MY -e "SELECT 'MySQL OK'" 2>/dev/null | grep -q "OK" && \
    echo -e "  ${GREEN}[OK]${NC} MySQL     127.0.0.1:3306" || \
    { echo -e "  ${RED}[ERRO]${NC} MySQL nao disponivel"; exit 1; }

# Caches ativos
echo -e "\n${CYAN}[2] Caches ativos no ReadySet:${NC}"
$RS -e "SHOW CACHES\G" 2>/dev/null | grep "cache name" | \
    awk '{print "  • " $3}'

# Warmup
echo -e "\n${CYAN}[3] Warmup (3x cada query no ReadySet)...${NC}"
for name in "${!QUERIES[@]}"; do
    for i in 1 2 3; do
        $RS -e "${QUERIES[$name]}" > /dev/null 2>&1
    done
    echo "  [OK] $name"
done

# Benchmark
echo -e "\n${CYAN}[4] Benchmark${NC}"
echo -e "${BOLD}----------------------------------------------------------------${NC}"
printf "  %-26s %10s %10s %10s\n" "Query" "MySQL" "ReadySet" "Speedup"
echo -e "${BOLD}----------------------------------------------------------------${NC}"

declare -A RESULTS_MY RESULTS_RS RESULTS_SP

for name in "${!QUERIES[@]}"; do
    query="${QUERIES[$name]}"

    # MySQL direto
    ms_my=$(run_ms "$MY" "$query")

    # ReadySet com cache
    ms_rs=$(run_ms "$RS" "$query")

    sp=$(speedup $ms_my $ms_rs)
    RESULTS_MY[$name]=$ms_my
    RESULTS_RS[$name]=$ms_rs
    RESULTS_SP[$name]=$sp

    printf "  %-26s %9sms %9sms %8sx\n" "$name" "$ms_my" "$ms_rs" "$sp"
    echo -e "  $(bar $sp) ${GREEN}${sp}x${NC}"
    echo ""
done

# Resumo
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}  RESUMO${NC}"
echo -e "${BOLD}----------------------------------------------------------------${NC}"
for name in "${!QUERIES[@]}"; do
    my=${RESULTS_MY[$name]}
    rs=${RESULTS_RS[$name]}
    sp=${RESULTS_SP[$name]}
    echo -e "  ${BOLD}$name${NC}"
    echo -e "    MySQL:    ${RED}${my}ms${NC}"
    echo -e "    ReadySet: ${GREEN}${rs}ms${NC}  →  ${BOLD}${CYAN}${sp}x mais rapido${NC}"
done

# Invalidação CDC
echo -e "\n${CYAN}[5] Testando invalidacao automatica (CDC via binlog)${NC}"
echo -e "${BOLD}----------------------------------------------------------------${NC}"

antes=$($RS -e "SELECT COUNT(*) FROM pedidos WHERE status='pendente'" 2>/dev/null \
    | grep -v COUNT | tr -d ' ')
echo "  Antes do INSERT:  pendente = $antes"

$MY -e "INSERT INTO pedidos (cliente_id, produto_id, quantidade, valor_total, status) \
    VALUES (1, 1, 1, 999.90, 'pendente');" 2>/dev/null
echo "  [INSERT] novo pedido pendente inserido direto no MySQL"

sleep 2

depois=$($RS -e "SELECT COUNT(*) FROM pedidos WHERE status='pendente'" 2>/dev/null \
    | grep -v COUNT | tr -d ' ')
diff=$(( depois - antes ))
echo "  Depois do INSERT: pendente = $depois  (+$diff)"

if [ "$diff" -gt 0 ]; then
    echo -e "  ${GREEN}[OK] CDC funcionando — cache atualizado automaticamente!${NC}"
else
    echo -e "  ${YELLOW}[AGUARDE] CDC ainda propagando...${NC}"
fi

echo -e "\n${BOLD}[CONCLUIDO]${NC}"
echo -e "${BOLD}================================================================${NC}"
