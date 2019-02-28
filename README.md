### About This Service Package
Set configuration values in your own `.toml` file and override the test
configurations in `default.toml` like this:
```
hab config apply --remote-sup=hab1.mycompany.com myapp.prod 1 /tmp/newconfig.toml
```
See https://www.habitat.sh/docs/using-habitat/#config-updates for more on
configuration updates.

#### Caveats
At the moment, this package only supports Route53 DNS verification of domain
ownership. Since only a single instance of a Habitat package can be running at
any given time, it's recommended to use this service to register wildcard
LetsEncrypt certificates only, so you should configure the `domain` TOML
key to a value of `*.example.com`, as an example.
