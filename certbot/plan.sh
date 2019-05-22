pkg_name=certbot
pkg_origin=bixu
pkg_maintainer="Blake Irvin <blakeirvin@me.com>, smartB Engineering <dev@smartb.eu>"
pkg_license=("Apache-2.0")
pkg_upstream_url="https://certbot.eff.org"
pkg_description="The Certbot LetsEncrypt client."
pkg_build_deps=(
  "bixu/cacher"
)
pkg_deps=(
  "core/bash/4.4.19"
  "core/findutils"
  "core/gawk/4.2.0"
  "core/python"
)
# The `pkg_plugins` array should be populated with suffixes used to identify
# `certbot` plugins in the Python module ecosystem. For example, `dns-google`,
# as in `certbot-dns-google`:
pkg_plugins=(
  "dns-route53"
)
pkg_bin_dirs=(bin)
pkg_svc_user="root"  #TODO: determine security standards for generated certs

pkg_exports=(
  [domain]="cfg.domain"
  [fullchain]="cfg.fullchain"
  [privkey]="cfg.privkey"
)

do_prepare() {
  python -m venv "$pkg_prefix"
  source "$pkg_prefix/bin/activate"
}

do_build() {
  return 0
}

do_install() {
  for plugin in ${pkg_plugins[@]}
  do
    pip --disable-pip-version-check install "$pkg_name-$plugin==$pkg_version"
  done
}

# This definition of the `do_after` callback allows us to skip artifact creation
# (collecting and compressing files inside our package's installation directory)
# if the `HAB_CREATE_PACKAGE` environment variable is set to 'false'. This can
# be set in our `.studiorc` file, where it will be ignored for automated builds.
do_after() {
  if [ ! -z $HAB_CREATE_PACKAGE ] && [ $HAB_CREATE_PACKAGE == "false" ]
  then
    build_line "WARN: Skipping artifact creation because 'HAB_CREATE_PACKAGE=false'"

    _generate_artifact() {
      return 0
    }

    _prepare_build_outputs() {
      return 0
    }
  fi
  return $?
}

do_strip() {
  return 0
}
