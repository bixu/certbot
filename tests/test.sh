#!/bin/bash

set -e

until hab svc status &> '/dev/null'
do
  hab pkg install 'core/hab-sup'
  hab sup run > 'nohup.out' &
  sleep 3
done

. '.studiorc'
run 'certbot'
run 'nginx'

until grep 'no renewal failures' '/hab/svc/certbot/logs/letsencrypt.log' &> '/dev/null'
do
  sleep 1
done

sleep 5

for pkg in 'busybox-static' 'bats'
do
  hab pkg install "core/${pkg}"
done

for pkg_and_binary in 'core/busybox-static ps' 'core/busybox-static netstat' 'core/busybox-static wc' 'core/busybox-static uniq' 'core/bats bats'
do
  hab pkg binlink ${pkg_and_binary}
done

bats ./tests/*.bats
