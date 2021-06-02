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
  read -p "请输入harbor 用户名：" HARBOR_USERNAME
  read -p "请输入harbor 密码：" HARBOR_PWD
  read -p "请输入redis ip：" REDIS_IP
  read -p "请输入redis 密码(未设置直接回车)：" REDIS_PASSWOR
  read -p "请输入reids 端口：" REDIS_PORT
}

git_clone_code(){
  echo -e "\033[31m 从聚码坊(http://codelab.org.cn/)拉取天枢开源代码,请输入用户名和密码 \033[0m"
  git clone http://repo.codelab.org.cn/codeup/codelab/Dubhe.git ${SOURCE_CODE_PATH}/Dubhe
}

mvn_package(){
  cd ${SOURCE_CODE_PATH}/Dubhe/distribute-train-operator/ && mvn clean compile package
}

build_image(){
  mv ${SOURCE_CODE_PATH}/Dockerfile ${SOURCE_CODE_PATH}/Dubhe/distribute-train-operator/target/Dockerfile && \
  cd  ${SOURCE_CODE_PATH}/Dubhe/distribute-train-operator/target/ && docker build -t ${HARBOR_HOST}/distribute-train/distribute-train-operator:v1 .
}

create_harbor_project(){
  cat > createproject.json <<EOF
{"project_name": "distribute-train","metadata": {"public": "true"}}
EOF

  curl -k -u "${HARBOR_USERNAME}:${HARBOR_PWD}" -X POST -H "Content-Type: application/json" "https://${HARBOR_HOST}/api/projects" -d @createproject.json
}

push_image(){
  docker login -u ${HARBOR_USERNAME} -p ${HARBOR_PWD} ${HARBOR_HOST}
  docker push ${HARBOR_HOST}/distribute-train/distribute-train-operator:v1
}

deploy_yaml(){
  sed -i "s#k8s-host-name#${HOSTNAME}#g;s#harbor-url#${HARBOR_HOST}#g;s#rdis-ip#${REDIS_IP}#g;s#redis-password#${REDIS_PASSWOR}#g;s#redis-port#${REDIS_PORT}#g" ${SOURCE_CODE_PATH}/distribute-train-operator-deploy.yaml && \
  kubectl apply -f ${SOURCE_CODE_PATH}/distribute-train-operator-deploy.yaml
}

get_input
git_clone_code
mvn_package
build_image
create_harbor_project
push_image
deploy_yaml