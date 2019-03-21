#!{{pkgPathFor "core/bash"}}/bin/bash
# shellcheck disable=SC2239
# shellcheck disable=SC1083

service_group() {
  pkg_ident=$1
  hab svc status \
    | grep ${pkg_ident} \
    | grep -v "^package" \
    | awk '{print $7}'
  return $?
}

get_certificates() {
  # shellcheck disable=SC2154
  echo "$(date) Getting any needed LetsEncrypt certificates for '{{cfg.domain}}'"
  certbot certonly \
    --{{cfg.plugin}} \
    --config='{{pkg.svc_config_path}}/certbot.ini' \
    --domain='{{cfg.domain}}' \
    --noninteractive
  return $?
}

renew_certificates() {
  echo "$(date) Renewing LetsEncrypt certificates if neccessary"
  certbot renew \
    --{{cfg.plugin}} \
    --config-dir='{{pkg.svc_data_path}}' \
    --logs-dir='{{pkg.svc_path}}/logs'
  return $?
}

tomlfy_certificates() {
  for key in 'privkey' 'fullchain'
  do
    path=$(find '{{pkg.svc_data_path}}/live/' -name "*${key}*pem")
    if ls "$path" | grep ".pem$" &> '/dev/null'
    then
      echo "$key = '''" > "{{pkg.svc_data_path}}/${key}_certificate.toml"
      echo "$(cat $path)" >> "{{pkg.svc_data_path}}/${key}_certificate.toml"
      echo "'''" >> "{{pkg.svc_data_path}}/${key}_certificate.toml"
    else
      exit 1
    fi
  done
  return $?
}

gossip_certificates() {
  # shellcheck disable=SC2044
  find '{{pkg.svc_data_path}}/' -name "*_certificate.toml" \
    -print0 \
      | xargs -0 cat > '{{pkg.svc_data_path}}/certificates.toml'
  hab config apply "$(service_group {{pkg.name}})" "$(date +%s)" '{{pkg.svc_data_path}}/certificates.toml'
  return $?
}
