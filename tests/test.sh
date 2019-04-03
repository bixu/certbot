#!/bin/bash

set -ex

hab pkg install 'core/bats'
hab pkg install 'core/busybox-static'
hab pkg install 'core/hab-sup'

export PATH="$PATH:$(hab pkg path 'core/bats')/bin"
export PATH="$PATH:$(hab pkg path 'core/busybox-static')/bin"

until hab svc status &> '/dev/null'
do
  hab sup run --no-color > 'nohup.out' &
  sleep 3
done

source '/src/.studiorc'

svc load 'certbot'
svc load 'nginx'

sleep 5

until hab svc status | grep 'bixu/nginx' | grep -v 'down' &> '/dev/null'
do
  sleep 1
done

sleep 5

tail '/hab/sup/default/sup.log' | grep 'certbot.default'

bats ./tests/*.bats
