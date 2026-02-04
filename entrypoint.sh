set -e

echo "======KRAKEN FRONT======"
echo "$(date)"
echo "[INFO] - Pod is starting"
echo "$(ls -blargh assets/)"
echo "$(nginx -version)"

nginx -g daemon off