#!/bin/bash
set -euo pipefail

cd $(dirname $0)

echo ">> Bundling AWS Lambda handler inside a docker image..."

TAG='eks-on-event-handler'

docker build -t ${TAG} .

echo ">> Extrating handler.zip from the build container..."
CONTAINER=$(docker run -d ${TAG} false)
docker cp ${CONTAINER}:/handler.zip handler.zip

echo ">> Stopping container..."
docker rm -f ${CONTAINER}
echo ">> handler.zip is ready"
