#!/bin/bash
# rules.sh - Настройка сетевой изоляции для проекта

# IP-адреса
PROXY_IP="192.168.56.11"
BACKEND_IP="192.168.56.10"
# Порты
POSTGRES_PORT="5432"
BACKEND_PORT="8080"
REDIS_PORT="6379"
PROXY_PORT="5000"

# Определяем текущий IP машины
CURRENT_IP=$(hostname -I | awk '{print $2}')
echo "=== Настройка iptables для $CURRENT_IP ==="
# Сбрасываем старые правила
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Политики по умолчанию
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Разрешаем локальный трафик (loopback)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Разрешаем установленные соединения (чтобы ответы проходили)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Определяем роль машины по IP
if [ "$CURRENT_IP" == "$BACKEND_IP" ]; then
    echo "Применяем правила для BACKEND (Ubuntu)..."
    
    # Backend принимает запросы ТОЛЬКО от Proxy на порт приложения
    iptables -A INPUT -p tcp -s $PROXY_IP --dport $BACKEND_PORT -j ACCEPT
    
    # Backend имеет доступ к PostgreSQL (локально)
    iptables -A INPUT -p tcp -s 127.0.0.1 --dport $POSTGRES_PORT -j ACCEPT
    
    # Разрешаем ICMP (ping) для диагностики
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
    
    # Разрешаем SSH
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

    echo "Правила для BACKEND применены"
    
elif [ "$CURRENT_IP" == "$PROXY_IP" ]; then
    echo "Применяем правила для PROXY (CentOS)..."
    
    # Proxy принимает запросы от ЛЮБОГО источника
    iptables -A INPUT -p tcp --dport $PROXY_PORT -j ACCEPT
    
    # Proxy имеет доступ к Redis (локально)
    iptables -A INPUT -p tcp -s 127.0.0.1 --dport $REDIS_PORT -j ACCEPT
    
    # Разрешаем ICMP
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
    
    # Разрешаем SSH
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

    echo " Правила для PROXY применены"
else
    echo "Неизвестный IP: $CURRENT_IP. Правила не применены."
    exit 1
fi
echo ""
echo "=== Текущие правила iptables ==="
iptables -L -n -v --line-numbers
echo ""
echo "Настройка завершена!"
