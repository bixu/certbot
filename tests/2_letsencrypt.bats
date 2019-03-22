@test "Nginx is serving a valid LetsEncrypt Staging certificate" {
  result="$(echo | hab pkg exec 'core/openssl' openssl s_client -showcerts -servername 'gnupg.org' -connect localhost:443 2>/dev/null | hab pkg exec 'core/openssl' openssl x509 -inform pem -noout -text | grep "Issuer: CN=")"
  [ "$result" = "        Issuer: CN=Fake LE Intermediate X1" ]
}

@test "Nginx Certificate Common Name (CN) matches the 'domain' key in 'default.toml'" {
  result="$(echo | hab pkg exec 'core/openssl' openssl s_client -showcerts -servername 'gnupg.org' -connect localhost:443 2>/dev/null | hab pkg exec 'core/openssl' openssl x509 -inform pem -noout -text | grep "Subject: CN=" | cut -d= -f2)"
  [ "$result" = "$(grep domain './certbot/default.toml' | cut -d"\"" -f2)" ]
}

@test "Certificate will expire in more than 60 days/5184000 seconds" {
  result="$(hab pkg exec 'core/openssl' openssl x509 -checkend 5184000 -in '/hab/svc/nginx/config/fullchain.pem')"
  [ "$result" = "Certificate will not expire" ]
}
