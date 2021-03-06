#!/usr/bin/env bash
set -ex

ENV="${1}"
DIR_TO_BACKUP="${2:-/_OUTPUT_}"
DIR_TO_BACKUP="${DIR_TO_BACKUP%/}"
BUCKET_PREFIX="${3:-grafana-backup-storage}"
REGION="${4:-eu-central-1}"
EXPIRES_IN_DAYS=${5:-365}

EXPIRES_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d "+${EXPIRES_IN_DAYS} days")

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Usage:
    watch.sh <ENV> [DIR_TO_BACKUP] [BUCKET_PREFIX] [REGION]                 Specifying an ENV is mandatory
    Destination bucket will be forge like this: s3://\${BUCKET_PREFIX}-\${ENV}/
    DIR_TO_BACKUP default "/_OUTPUT_"
    BUCKET_PREFIX default "grafana-backup-storage-"
    REGION default "eu-central-1"
EOF
}

if [[ -z "${ENV}" ]]
then
    script_usage
    exit 1
fi

echo "Start watching"
fswatch -1 --event Created -v -e "${DIR_TO_BACKUP}/.*" -i "${DIR_TO_BACKUP}/.*\\.tar\\.gz$" -0 "${DIR_TO_BACKUP}" | xargs -0 -n 1 -I {} echo "File {} changed"
echo "Stop watching... Copy will start in 10s."
CMD="s5cmd -r 1 --log debug  --endpoint-url \"https://s3.${REGION}.amazonaws.com\" cp --expires \"${EXPIRES_DATE}\" \"${DIR_TO_BACKUP}/*.tar.gz\" \"s3://${BUCKET_PREFIX}-${ENV}/\""
echo "Launched command: ${CMD}"
sleep 10
eval "${CMD}"
