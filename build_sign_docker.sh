#!/bin/bash
set -euo pipefail

tagVersion=$(sed -n '5p' version.properties | cut -d "=" -f 2)
label=$(sed -n '4p' version.properties | cut -d "=" -f 2)
branch=$(git symbolic-ref HEAD | cut -d "/" -f 3)
track=$(python3 track.py "$branch")

docker_apk_image=swob_app_apk_image
docker_apk_image_commit_check=docker_apk_image_commit_check
docker_app_image=swob_app_app_image

APP_1=$label.apk
APP_2=$label_1.apk

CONTAINER_NAME=swob_app_container_$label
CONTAINER_NAME_1=swob_app_container_$label_1
CONTAINER_NAME_BUNDLE=swob_app_container_$label_bundle
CONTAINER_NAME_COMMIT_CHECK=$(commit)_commit_check

minSdk=24

venv/bin/python bump_version.py "$(git symbolic-ref HEAD)"

git add .
git commit -m "release: making release"
git tag -f "$tagVersion"

echo "[+] Building apk output: $APP_1"
DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t $docker_apk_image --target apk-builder .
docker run --name $CONTAINER_NAME -e PASS=$1 $docker_apk_image && \
	docker cp $CONTAINER_NAME:/android/app/build/outputs/apk/release/app-release.apk apk-outputs/$APP_1

echo "[+] Building apk output: $APP_2"
docker run --name $CONTAINER_NAME_1 -e PASS=$1 $docker_apk_image && \
	docker cp $CONTAINER_NAME_1:/android/app/build/outputs/apk/release/app-release.apk apk-outputs/$APP_2

diffoscope apk-outputs/$APP_1 apk-outputs/$APP_2
