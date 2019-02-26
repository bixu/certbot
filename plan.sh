pkg_name=certbot
pkg_origin=bixu
pkg_maintainer="Blake Irvin <blakeirvin@me.com>"
pkg_license=('Apache-2.0')
pkg_description="The Certbot LetsEncrypt client."
pkg_deps=(
  core/python
)
pkg_bin_dirs=(bin)

pkg_version() {
  pip search "$pkg_name" \
    | grep "^$pkg_name " \
    | cut -d'(' -f2 \
    | cut -d')' -f1
}

do_before() {
  update_pkg_version
}

do_prepare() {
  python -m venv "$pkg_prefix"
  # shellcheck source=/dev/null
  source "$pkg_prefix/bin/activate"
}

do_build() {
  return 0
}

do_install() {
  pip install "$pkg_name==$pkg_version"
  # Write out versions of all pip packages to package
  pip freeze > "$pkg_prefix/requirements.txt"
}

do_strip() {
  return 0
}
