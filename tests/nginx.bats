source "${BATS_TEST_DIRNAME}/../nginx/plan.sh"

@test "Nginx is running" {
  result=$(hab svc status ${pkg_origin}/${pkg_name} | grep -v "^package" | awk '{print $4}')
  [ "$result" = "up" ]
}

@test "Nginx is istening on port 443" {
  result="$(netstat -peanut | grep nginx | awk '{print $4}' | awk -F':' '{print $2}')"
  [ "${result}" -eq 443 ]
}
