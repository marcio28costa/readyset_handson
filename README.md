# 🚀 ReadySet + MySQL Lab  
Cache inteligente com ganho real de performance

---

## 📌 Sobre o projeto

Este laboratório demonstra, de forma prática, o uso do ReadySet como camada de cache para o MySQL.

O objetivo é evidenciar ganhos de performance em cenários de leitura, sem necessidade de alteração na aplicação.

---

## 🧠 Arquitetura

Aplicação  
↓  
ReadySet (porta 3307)  
↓  
MySQL (porta 3306)  
↔  
Binlog (CDC)

- ReadySet atua como camada de cache  
- MySQL permanece como fonte de verdade  
- Sincronização automática via binlog (CDC)  

---

## 🧱 Estrutura do projeto
<pre> ```
.
├── app
│   ├── benchmark.py
│   └── Dockerfile
├── docker-compose.yml
├── init
│   ├── schema.sql
│   └── seed.sql
└── mysql-config
    └── custom.cnf
``` </pre>
---

## ⚙️ Pré-requisitos

- Oracle Linux 8 (ou compatível)
- Docker
- Docker Compose

Instalação do Docker:

dnf remove -y podman podman-compose buildah  
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo  
dnf install -y docker-ce docker-ce-cli containerd.io  
systemctl enable docker  
systemctl start docker  

---

## 🚀 Como executar

mkdir -p /dados/readyset  
cd /dados/readyset  

docker compose up -d  

---

## 🔌 Conexões

### MySQL direto

mysql -h 127.0.0.1 -P 3306 -u rsuser -preadyset demo  

### ReadySet

mysql -h 127.0.0.1 -P 3307 -u rsuser -preadyset demo  

---

## 🧪 Teste de performance

SELECT status, COUNT(*) AS total, SUM(valor_total)  
FROM pedidos  
GROUP BY status;

---

## 📊 Resultados observados

### Cenário simples

- MySQL: ~25ms  
- ReadySet: ~14ms  

---

### Cenário com volume (500k registros)

Sem cache: ~2.55s  
Com cache: ~0.015s  

---

## 📈 Conclusão dos testes

- Redução superior a 99% no tempo de resposta  
- Eliminação do custo de execução da query no banco  
- Ganhos mais evidentes com aumento de volume  

---

## 🔄 Invalidação automática

INSERT INTO pedidos (...)  

---

## 🛠️ Comandos úteis

docker compose ps  
docker compose logs -f readyset  
docker compose down  
docker compose down -v  

---

## ⚠️ Observações

- Nem todas as queries se beneficiam igualmente  
- Queries muito dinâmicas podem ter menor ganho  
- CDC depende do binlog configurado corretamente  

---

## 🔭 Próximos passos

- Testes com maior volume de dados  
- Simulação de carga concorrente  
- Integração com ambiente produtivo  

---

## 📄 Licença

Uso livre para estudos e laboratório.
