#!/bin/bash
set -e

TELEGRAM_TOKEN=$1
CHAT_ID=$2
KUBECONFIG_PATH=$3
NAMESPACE=$4
DELAY=$5
TAG=$6

echo "Esperando $DELAY segundos antes de obtener el estado..."
sleep "$DELAY"

echo "Obteniendo estado de recursos en el namespace: $NAMESPACE"
export KUBECONFIG="$KUBECONFIG_PATH"
kubectl get all -n "$NAMESPACE" > k8s_status_${TAG}.txt

echo "Enviando archivo a Telegram..."
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
  -F chat_id="${CHAT_ID}" \
  -F document=@"k8s_status_${TAG}.txt" \
  -F caption="📄 Estado del clúster tras deploy versión *${TAG}*" \
  -F parse_mode="Markdown"

rm -f k8s_status_${TAG}.txt
