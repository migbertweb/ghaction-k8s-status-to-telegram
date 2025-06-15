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

SHORT_SHA=$(echo "$COMMIT" | cut -c1-7)
# Archivos modificados
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r "$COMMIT")
FORMATTED_FILES=$(echo "$CHANGED_FILES" | sed '/^$/d' | sed 's/^/• /')

# Verificar si hay nueva version de imagen
if [ -n "$TAG" ]; then
    TAG_LINE="📦 Nueva Versión de Imagen: *$TAG*"
    FILE="k8s_status_${TAG}.txt"
else
    TAG_LINE="📦 Utilizando misma Version de Imagen"
    FILE="k8s_status.txt"
fi

# Mensaje
if [ "$JOB_STATUS" = "success" ]; then
  EMOJI="✅"
  TITLE="*Deploy exitoso*"
else
  EMOJI="❌"
  TITLE="*Error en Deploy*"
fi

TEXT="$EMOJI $TITLE

$TAG_LINE
🚀 *Proyecto:* [\`$REPO\`](https://github.com/$REPO)
🌿 *Rama:* \`$BRANCH\`
🔁 *Commit:* [\`$SHORT_SHA\`]($COMMIT_URL)
🕒 *Duración:* *${DEPLOY_DURATION}*

🧾 *Archivos modificados:*
\`\`
$FORMATTED_FILES
\`\`
"

# Espera opcional
echo "Esperando $DELAY segundos..."
sleep "$DELAY"

# Generar archivo de estado
if [ "$JOB_STATUS" = "success" ]; then
export KUBECONFIG="$KUBECONFIG_PATH"
kubectl get all -n "$NAMESPACE" > "$FILE"
else
  echo "El despliegue falló, no se generará el archivo de estado."
  echo "Error en el despliegue" > "$FILE"
fi

# Enviar mensaje único con caption
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
  -F chat_id="${CHAT_ID}" \
  -F document=@"$FILE" \
  -F caption="$TEXT" \
  -F parse_mode="Markdown"

rm -f $FILE
echo "Mensaje enviado a Telegram con éxito."
# Fin del script
