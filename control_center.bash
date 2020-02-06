#!/usr/bin/env bash

CONTROL_CENTER_COMPOSE_FILE="docker-compose.yml"
OPTS="ANSIBLE_SCP_IF_SSH=TRUE ANSIBLE_CONFIG=/ansible/provision/ansible.cfg ANSIBLE_GATHERING=smart"
ANSIBLE_OPTS="ansible_python_interpreter=/usr/bin/python3"

function os(){
  UNAME=$( command -v uname)
  case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
    linux*)
      printf 'linux\n'
      ;;
    darwin*)
      printf 'mac\n'
      ;;
    msys*|cygwin*|mingw*)
      # or possible 'bash on windows'
      printf 'windows\n'
      ;;
    nt|win*)
      printf 'windows\n'
      ;;
    *)
      printf 'unknown\n'
      ;;
  esac
}

function verify_ansible_connection() {
  #CMD="ansible-inventory  -i /inventory/hosts  --list "
  CMD="ansible -i /inventory/hosts -m ping all"

  verify=$(CMD="$OPTS $CMD" MSYS_NO_PATHCONV=1 docker-compose -f "$CONTROL_CENTER_COMPOSE_FILE" run --rm service)
  case "$verify" in
    *SUCCESS*)
        echo "Connection SUCCESS :: Ansible Control Center -> VM ";;
    *)
        echo "Error... Ansible Control Center Can Not Reach VM via SSH" ;;
  esac
  #echo "$verify"
}

function configure_vm() {
  PLAYBOOK="/ansible/provision/playbook.yml"
  CMD="ansible-playbook  -i /inventory/hosts -e $ANSIBLE_OPTS -v $PLAYBOOK"
  CMD="$OPTS $CMD --limit=all" MSYS_NO_PATHCONV=1 docker-compose -f "$CONTROL_CENTER_COMPOSE_FILE" run --rm service
}

function control_center_shell() {
  CMD="/bin/bash"
  CMD="$CMD" _docker_compose -f "$CONTROL_CENTER_COMPOSE_FILE" run --rm service
}

#ToDo: Assumes Existence of MonoRepo :-)
function copy_keys(){
  rm -fr keys/* && cp ../multipass-dev-box/keys/multipass/id_rsa_bizapps* keys/
}

function _docker_compose() {
  if [[ "$(os)" == "windows" ]]; then
    realdocker="$(which -a docker-compose | grep -v "$(readlink -f "$0")" | head -1)"
    export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
    printf "%s\0" "$@" > /tmp/args.txt
    winpty bash -c "xargs -0a /tmp/args.txt '$realdocker'"
    return 0
  fi
  docker-compose $@
}

copy_keys
verify_ansible_connection
configure_vm
control_center_shell