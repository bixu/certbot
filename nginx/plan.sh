pkg_name=nginx
pkg_origin=bixu
pkg_version=1.15.6
pkg_description="NGINX web server."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('BSD-2-Clause')
pkg_upstream_url='https://nginx.org/'
pkg_build_deps=(
  'core/bats'
  'core/busybox-static'
  )
pkg_deps=(
  "core/nginx/${pkg_version}"
)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(sbin)
pkg_include_dirs=(include)
pkg_svc_run="nginx"
pkg_svc_run_flags="--bind=tls_certificates:certbot.default"
pkg_svc_user="root"
pkg_exports=(
  [port]=http.listen.port
)
pkg_exposes=(port)
pkg_binds_optional=(
  [tls_certificates]="domain fullchain privkey"
)

do_build() {
  return 0
}

do_install() {
  for file in $(find $(hab pkg path core/nginx)/config -type f | grep -v 'nginx.conf')
  do
    mkdir --parents "$pkg_prefix/config/"
    cp -p "$file" "$pkg_prefix/config/"
  done
  return $?
}
