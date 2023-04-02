#!/usr/bin/env bash

cd $(dirname $0)

cat << EOF > .env
UID=$(id -u $USER)
GID=$(id -g $USER)
USERNAME=$USER
HOMEDIR=/home/$USER
COMPOSE_PROJECT_NAME=${PROJECTNAME}
EOF

mkdir -p ${HOME}/.aws
mkdir -p ${HOME}/.config/gh
