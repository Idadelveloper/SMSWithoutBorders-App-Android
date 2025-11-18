#!/bin/bash
set -euo pipefail
APP_1="app1"

echo "Building apk output: ${APP_1}"
DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t ${docker_apk_image} --target apk-builder .
docker run --name ${CONTAINER_NAME} -e PASS=$(pass) ${docker_apk_image} && \
	docker cp ${CONTAINER_NAME}:/android/app/build/outputs/apk/release/app-release.apk apk-outputs/${APP_1}
sleep 3
echo "Building apk output: ${APP_2}"
docker run --name ${CONTAINER_NAME_1} -e PASS=$(pass) ${docker_apk_image} && \
	docker cp ${CONTAINER_NAME_1}:/android/app/build/outputs/apk/release/app-release.apk apk-outputs/${APP_2}
diffoscope apk-outputs/${APP_1} apk-outputs/${APP_2}
echo $? | exit
