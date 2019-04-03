### About This Service Package
Because this service package makes use of the `install` hook, you must set
```
export HAB_FEAT_INSTALL_HOOK="true"
```
before installing the package. Otherwise the initial certificate fetch will not
happen.

Set custom configuration values in your own `.toml` file and override the default
configurations in `default.toml` like this:
```
hab config apply --remote-sup=<hostname> <service>.<group> $(date +%s) ./foo.toml
```
See https://www.habitat.sh/docs/using-habitat/#config-updates for more on
configuration updates.

Certificates will be stored in the Habitat gossip configuration and can be
accessed by binding the service that uses the certs to the Certbot service
group:
```
hab svc load <origin>/nginx --bind=tls_certificates:certbot.<group>
```
and the certificate contents can be written out via Habitat Handlebars templates
like:
```
{{~#each bind.tls_certificates.members as |member|}}{{member.cfg.privkey}}{{~/each}}
```
See the `nginx` directory in this project for working example code. Note that
you _must_ ensure your gossiped configs are secure to protect key contents. See
https://www.habitat.sh/docs/using-habitat/#wire-encryption for more on securing
Habitat inter-service communication.

#### Testing
Local dev testing via BATS should be possible by running `./tests/test.sh` See
https://github.com/sstephenson/bats for more information.

#### AWS Credentials
The current version of this package supports only certificate verification using
Route53 DNS. You should set the appropriate `AWS_SECRET_ACCESS_KEY` and
`AWS_ACCESS_KEY_ID` environment variables for the runtime context of the service.
Here's an example of how `bixu/certbot` might be run as a systemd service with
AWS credentials embedded:
```
[Unit]
Description=Certbot
[Service]
Environment="HAB_AUTH_TOKEN=<some value>"
Environment="AWS_ACCESS_KEY_ID=<some value>"
Environment="AWS_SECRET_ACCESS_KEY=<some value>"
ExecStart=/bin/hab sup run bixu/certbot
KillMode=process
Restart=on-failure
[Install]
WantedBy=default.target
```
Future versions of the service may support other verification plugins as well as
other methods for handling secrets.

#### Caveats
At the moment, this package only supports Route53 DNS verification of domain
ownership. Since only a single instance of a Habitat package can be running at
any given time, it's recommended to use this service to register wildcard
LetsEncrypt certificates only, so you should configure the `domain` TOML
key to a value of `*.example.com`, as an example.

We also only support a single LetsEncrypt domain per running `certbot` service.
