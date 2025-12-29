#!/bin/bash

# Resumo rápido sobre ficheiros temporários
echo "Ficheiros temporários são arquivos criados por programas ou pelo sistema para armazenar dados de forma temporária, geralmente no diretório /tmp. Eles ajudam a reduzir o uso de memória, mas podem ser deletados com segurança para liberar espaço no disco, embora alguns possam estar em uso por processos ativos."

# Avisa que precisa de premissão de administrador
 if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa de permissões de administrador. Running with sudo..."
  exec sudo "$0" "$@"
fi

# Diretório de ficheiros temporários 
TMP_DIR="/tmp"

# Arquivo de log
LOG_FILE="$HOME/temp_clean_log.txt"  # Usando diretório home para evitar necessidade de root no log

# Encontrar todos os ficheiros em /tmp
files=$(find "$TMP_DIR" -type f 2>/dev/null)

# Se não houver ficheiros sai
if [ -z "$files" ]; then
    echo "Não há ficheiros temporários para eliminar em $TMP_DIR."
    exit 0
fi

# Contar por tipo de extensão
declare -A ext_count
total_deleted=0

> "$LOG_FILE"  # Limpar ou criar o log
echo "Resumo dos ficheiros eliminados em $(date):" >> "$LOG_FILE"

for file in $files; do
    ext="${file##*.}"
    if [ "$ext" = "$file" ]; then
        ext="sem_extensao"
    fi
    ((ext_count[$ext]++))
    ((total_deleted++))
    echo "$file" >> "$LOG_FILE"  # Registrar cada um dos ficheiros deletados
done

# Elimina os ficheiros
find "$TMP_DIR" -type f -delete 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Todos os ficheiros temporários foram eliminados com sucesso." >> "$LOG_FILE"
    echo "Total de ficheiros eliminados: $total_deleted" >> "$LOG_FILE"
else
    echo "Falha ao eliminar alguns ficheiros (possivelmente em uso)." >> "$LOG_FILE"
fi

# No final, exibe todos os tipos de ficheiros e a quantidade
echo "Tipos de ficheiros eliminados e quantidades:"
for ext in "${!ext_count[@]}"; do
    echo "Tipo: .$ext - Quantidade: ${ext_count[$ext]}"
done

# Adicionar ao log 
echo "Tipos e quantidades:" >> "$LOG_FILE"
for ext in "${!ext_count[@]}"; do
    echo "Tipo: .$ext - Quantidade: ${ext_count[$ext]}" >> "$LOG_FILE"
done 