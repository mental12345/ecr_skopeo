#! /usr/bin/env bash

usage() {
    echo "Read image list from file, use: "
    echo "$0 -a IMAGES_FILE,SOURCE_REGISTRY,AWS_ACCOUNT"
    echo "$0 -a images.txt,docker.io,123456789012"
    echo "Read from environment variables, set variables IMAGE and TAG: "
    echo "$0 -e"
    exit 1;
}

login_ecr() {
    AWS_ACCOUNT=${1}
    echo "Login into ECR and making docker credentials"
    aws ecr get-login-password --region us-east-1 | skopeo login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com    
}

copy_images_env() { 
    echo "Reading environment variables!"
    echo "if TAG is not set, latest will be used"
    if [[ -z "${AWS_ACCOUNT}" || -z "${SOURCE_REGISTRY}" || -z "${IMAGE}" ]]; then
        echo "Can't find environment variables"
    else
        login_ecr ${AWS_ACCOUNT}    
        if [[ -z "${TAG}" ]]; then
            TAG="latest"
            skopeo copy docker://${SOURCE_REGISTRY}/${IMAGE}:${TAG} docker://${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:${TAG} --all
        else 
            skopeo copy docker://${SOURCE_REGISTRY}/${IMAGE}:${TAG} docker://${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:${TAG} --all 
        fi
    fi 
}

copy_images_file() {
    IFS=","
    read -a ARG_ARR <<< ${1}
    IMAGES_FILE=${ARG_ARR[0]}
    REGISTRY=${ARG_ARR[1]}
    AWS_ACCOUNT=${ARG_ARR[2]}
    login_ecr ${AWS_ACCOUNT}
    while read IMAGE TAG; do
        echo "Copying $IMAGE with $TAG"
        skopeo copy docker://${REGISTRY}/${IMAGE}:${TAG} docker://${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE}:${TAG} --all
    done < ${IMAGES_FILE}
    echo "Done"
}

while getopts ":a:e" OPTION; do
    case "${OPTION}" in
        a) 
           copy_images_file ${OPTARG}
           ;;
        e)
           copy_images_env
           ;;
        *)
           usage
           ;;
    esac
done
