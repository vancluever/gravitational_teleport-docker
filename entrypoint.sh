#!/usr/bin/env bash

# message prints text with a color, redirected to stderr.
message() {
  declare -A __colors=(
    ["error"]="31"   # red
    ["warning"]="33" # yellow
    ["begin"]="32"   # green
    ["ok"]="32"      # green
    ["info"]="1"     # bold
    ["reset"]="0"    # here just to note reset code
  )
  local __type="$1"
  local __message="$2"
  if [ -z "${__colors[$__type]}" ]; then
    __type="info"
  fi
  echo -e "\e[${__colors[$__type]}m${__message}\e[0m" 1>&2
}

if [ -z "${TELEPORT_ROLES_DIR}" ]; then
  TELEPORT_ROLES_DIR="/etc/teleport.roles.d"
fi

message begin "Starting teleport in subshell..." >&2
(/usr/local/bin/teleport start "$@") &
teleport_pid=$!

while ! /usr/local/bin/tctl nodes ls >/dev/null 2>&1; do
  message warning "Waiting 3s for teleport to start"
  sleep 3
done

message begin "Loading any roles from ${TELEPORT_ROLES_DIR}..." >&2
for role_file in ${TELEPORT_ROLES_DIR}/*.yaml; do
  message info "Loading role from ${role_file}..." >&2
  tctl upsert -f "${role_file}"
done

message ok "Foregrounding teleport process (pid ${teleport_pid})." >&2
wait
