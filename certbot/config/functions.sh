#!{{pkgPathFor "core/bash"}}/bin/bash
# shellcheck disable=SC2239
# shellcheck disable=SC1083

service_group() {
  pkg_ident=$1
  hab svc status ${pkg_ident} | grep -v "^package" | awk '{print $7}'
  return $?
}

get_certificates() {
  # shellcheck disable=SC2154
  echo "$(date) Getting any needed LetsEncrypt certificates for '{{cfg.domain}}'"
  certbot certonly \
    --{{cfg.plugin}} \
    --config='/hab/svc/certbot/config/certbot.ini' \
    --domain='{{cfg.domain}}' \
    --noninteractive
  return $?
}

renew_certificates() {
  echo "$(date) Renewing LetsEncrypt certificates if neccessary"
  certbot renew \
    --{{cfg.plugin}} \
    --config-dir='/hab/svc/certbot/config' \
    --logs-dir='/hab/svc/certbot/logs'
  return $?
}

tomlfy_certificates() {
  for key in 'privkey' 'fullchain'
  do
    path=$(find /hab/svc/certbot/config/live/ -name "*${key}*pem")
    echo "${key} = '''$(cat ${path})'''" > "/hab/svc/certbot/config/${key}_certificate.toml"
  done
  return $?
}

gossip_certificates() {
  # shellcheck disable=SC2044
  find '/hab/svc/certbot/config/' -name "*_certificate.toml" \
    -print0 \
      | xargs -0 cat > '/hab/svc/certbot/config/certificates.toml'
  hab config apply "$(service_group $pkg_origin/$pkg_name)" "$(date +%s)" '/hab/svc/certbot/config/certificates.toml'
  return $?
}
