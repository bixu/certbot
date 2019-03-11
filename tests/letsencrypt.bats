@test "Certificate served by Nginx is valid and via LetsEncrypt" {
  result="$(echo | hab pkg exec 'core/openssl' openssl s_client -showcerts -servername gnupg.org -connect localhost:443 2>/dev/null | hab pkg exec 'core/openssl' openssl x509 -inform pem -noout -text | grep "Issuer: C=US, O=Let's Encrypt, CN=Let's Encrypt Authority X3")"
  [ "$result" = "        Issuer: C=US, O=Let's Encrypt, CN=Let's Encrypt Authority X3" ]
}

@test "Certificate Common Name (CN) matches our TOML-configured 'domain' key" {
  result="$(echo | hab pkg exec 'core/openssl' openssl s_client -showcerts -servername gnupg.org -connect localhost:443 2>/dev/null | hab pkg exec 'core/openssl' openssl x509 -inform pem -noout -text | grep "Subject: CN=" | cut -d= -f2)"
  [ "$result" = "$(grep domain ./certbot/default.toml | cut -d"\"" -f2)" ]
}

@test "Certificate will expire in more than 60 days/5184000 seconds" {
  result="$(hab pkg exec core/openssl openssl x509 -checkend 5184000 -in /hab/svc/nginx/config/fullchain.pem)"
  [ "$result" = "Certificate will not expire" ]
}
