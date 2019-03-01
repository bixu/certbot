pkg_name=certbot
pkg_origin=bixu
pkg_maintainer='Blake Irvin <blakeirvin@me.com>, smartB Engineering <dev@smartb.eu>'
pkg_license=('Apache-2.0')
pkg_upstream_url='https://certbot.eff.org'
pkg_description='The Certbot LetsEncrypt client.'
pkg_build_deps=(
  'bixu/cacher'
)

pkg_deps=(
  'core/bash'
  'core/python'
)
pkg_plugins=(
  'dns-route53'
)
pkg_bin_dirs=(bin)
pkg_svc_user='root'  #TODO: determine security standards for generated certs

pkg_version() {
  pip --disable-pip-version-check search "$pkg_name" \
    | grep "^$pkg_name " \
    | cut -d'(' -f2 \
    | cut -d')' -f1
}

do_before() {
  update_pkg_version
}

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

do_after() {
  if [ $HAB_CREATE_PACKAGE == 'false' ]
  then
    build_line "WARN: Skipping artifact creation because 'HAB_CREATE_PACKAGE=false'"

    _generate_artifact() {
      return 0
    }

    _prepare_build_outputs() {
      return 0
    }
  fi
}

do_strip() {
  return 0
}
