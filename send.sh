#!/bin/bash
set -e

# Inputs del action
TELEGRAM_TOKEN="$1"
CHAT_ID="$2"
KUBECONFIG_PATH="$3"
NAMESPACE="$4"
DELAY="$5"
TAG="$6"
JOB_STATUS="$7"
DEPLOY_DURATION="$8"

# Entorno de GitHub
REPO="${GITHUB_REPOSITORY}"
BRANCH="${GITHUB_REF_NAME}"
COMMIT="${GITHUB_SHA}"
COMMIT_URL="https://github.com/$REPO/commit/$COMMIT"
JOB_STATUS="${JOB_STATUS:-success}"
DEPLOY_DURATION="${DEPLOY_DURATION:-0}"

# Mensaje
if [ "$JOB_STATUS" = "success" ]; then
  EMOJI="✅"
  TITLE="*Deploy exitoso*"
  TAG_LINE="📦 Versión: *$TAG*"
else
  EMOJI="❌"
  TITLE="*Error en Deploy*"
  TAG_LINE=""
fi

TEXT="$EMOJI $TITLE

$TAG_LINE
🚀 Proyecto: \`$REPO\`
🌿 Rama: \`$BRANCH\`
🔁 Commit: [\`$COMMIT\`]($COMMIT_URL)
🕒 Duración: *${DEPLOY_DURATION}s*"

# Espera opcional
echo "Esperando $DELAY segundos..."
sleep "$DELAY"

# Generar archivo
export KUBECONFIG="$KUBECONFIG_PATH"
kubectl get all -n "$NAMESPACE" > k8s_status_${TAG}.txt

# Enviar mensaje único con caption
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
  -F chat_id="${CHAT_ID}" \
  -F document=@"k8s_status_${TAG}.txt" \
  -F caption="$TEXT" \
  -F parse_mode="Markdown"

rm -f k8s_status_${TAG}.txt
