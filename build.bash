#!/usr/bin/env bash

CONTROL_CENTER_COMPOSE_FILE="docker-compose.yml"
OPTS="ANSIBLE_SCP_IF_SSH=TRUE ANSIBLE_CONFIG=/ansible/provision/ansible.cfg ANSIBLE_GATHERING=smart"
ANSIBLE_OPTS="ansible_python_interpreter=/usr/bin/python3"

verify_ansible_connection() {
  CMD="ansible-inventory  -i /inventory/hosts  --list "
  verify=$(CMD="$OPTS $CMD" docker-compose -f "$CONTROL_CENTER_COMPOSE_FILE" run --rm service)
  case "$verify" in
    *SUCCESS*)
        echo "Connection SUCCESS :: Ansible Control Center -> VM ";;
    *)
        echo "Error... Ansible Control Center Can Not Reach VM via SSH" ;;
  esac
  #echo "$verify"
}

configure_vm() {
  PLAYBOOK="/ansible/provision/playbook.yml"
  CMD="ansible-playbook  -i /inventory/hosts -e $ANSIBLE_OPTS -v $PLAYBOOK"
  CMD="$OPTS $CMD --limit=all" docker-compose -f "$CONTROL_CENTER_COMPOSE_FILE" run --rm service
}

control_center_shell() {
  CMD="/bin/bash"
  CMD="$CMD" docker-compose -f "$CONTROL_CENTER_COMPOSE_FILE" run --rm service
}

verify_ansible_connection
configure_vm
#control_center_shell