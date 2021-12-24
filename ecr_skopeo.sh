#!/usr/bin/env bash

usage() {
	echo "To read file, please use: "
	echo "$0 -a images.txt"
	echo "To read from env variables, just execute script with variables IMAGE and TAG: "
	echo "$0"
}

get_tags() {
	wget -q https://registry.hub.docker.com/v1/repositories/${IMAGE}/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'`
}

login_ecr() {
	echo "Login into ECR and making docker credentials"
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 538412665789.dkr.ecr.us-east-1.amazonaws.com
}

copy_images() {
	IMAGE=${1}
	TAG=${2}
	skopeo copy docker://docker.io/${IMAGE}:${TAG} docker://538412665789.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:${TAG}
}

read_file() {
	FILE=${1}
	while read line; do
		strarr=(${line//:/ })
		IMAGE=${strarr[0]}
		TAG=${strarr[1]}
		echo "copying ${IMAGE} with ${TAG}"
		copy_images $IMAGE $TAG
	done < ${FILE}
}

while getopts "a:" opt; do
	case $opt in
		a)
			if [ -z "${2}" ]; then
				usage
				exit 1
			fi
			echo "-a: reading file ${2}"
			login_ecr
			read_file ${2}
			;;
		*)
			echo "Didn't understand"
			usage
			exit 1
			;;
	esac
done

if [ -z "$1" ]; then
	echo "reading env variables"
	if [[ -z "${TAG}" ]] || [[ -z "${IMAGE}" ]]; then
		echo "cannot find variables"
		usage
		exit 1
	fi
	login_ecr
	copy_images $IMAGE $TAG
	exit
fi
