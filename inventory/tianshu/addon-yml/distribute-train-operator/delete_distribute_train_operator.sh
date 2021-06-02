#!/bin/bash

SOURCE_CODE_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )

HARBOR_HOST=''
HARBOR_USERNAME=''
HARBOR_PWD=''
REDIS_IP=''
REDIS_PASSWOR=''
REDIS_PORT=''

#读取输入
get_input(){
  read -p "请输入harbor服务器地址：" HARBOR_HOST
}

delete_code(){
  rm -rf ${SOURCE_CODE_PATH}/Dubhe
}

delete_image(){
  docker rmi -f ${HARBOR_HOST}/distribute-train/distribute-train-operator:v1
}

delete_yaml(){
  kubectl delete -f ${SOURCE_CODE_PATH}/distribute-train-operator-deploy.yaml
}

get_input
delete_yaml
delete_image
delete_code