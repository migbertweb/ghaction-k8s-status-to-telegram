# GitHub Action: K8s Status to Telegram

Este Action espera unos segundos tras un deploy a Kubernetes, ejecuta `kubectl get all` y envía la salida como un archivo `.txt` a un chat de Telegram.

## Uso

```yaml
- name: Enviar estado del clúster por Telegram
  uses: migbertweb/ghaction-k8s-status-to-telegram@v1
  with:
    telegram_token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    telegram_chat_id: ${{ secrets.TELEGRAM_CHAT_ID }}
    kubeconfig: ${{ github.workspace }}/apps/deployCICD/kubeconfig.yaml
    namespace: default
    delay: 15
    tag: ${{ steps.tag.outputs.new_tag }}
    job_status: ${{ job.status }}
    deploy_duration: ${{ steps.deploy_duration.outputs.time_in_seconds }}
