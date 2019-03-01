### About This Service Package
Set configuration values in your own `.toml` file and override the test
configurations in `default.toml` like this:
```
hab config apply --remote-sup=hab1.mycompany.com myapp.prod 1 /tmp/newconfig.toml
```
See https://www.habitat.sh/docs/using-habitat/#config-updates for more on
configuration updates.

Certificates will be stored at
```
/hab/svc/certbot/config/live/<domain name>/*.pem
```
which means that you can point configs for other services (like `core/nginx` or
`core/apache`) at these directories to load certificates. The usual caveats about
securing `/hab/svc/certbot/config` certainly apply here. You can also consider
backing up this directory.

#### Caveats
At the moment, this package only supports Route53 DNS verification of domain
ownership. Since only a single instance of a Habitat package can be running at
any given time, it's recommended to use this service to register wildcard
LetsEncrypt certificates only, so you should configure the `domain` TOML
key to a value of `*.example.com`, as an example.
