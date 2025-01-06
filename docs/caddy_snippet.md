## caddy_snippet

Create a snippet that can be referenced in other configuration blocks using `import SNIPPET_NAME`

## Properties

|Name   |Type       |Default             |Description                        |
|-------|-----------|--------------------|-----------------------------------|
|content|string     |``                  |Config block to include with snippet.

## Examples

Example to setup skip certificate checking of sites that use self-signed certificates

```ruby
  caddy_snippet 'https-insecure' do
    content <<-EOF
    transport http {
      tls
      tls_insecure_skip_verify
    }
    EOF
  end
```

Example snippet used to configure google cloud dns hostname verification for  SSL certificates. This is required in order to handle wildcard DNS SSL Certificates

```ruby
  caddy_snippet 'tls-dns' do
    content <<-EOF
    tls {
        dns googleclouddns {
            gcp_project #{gcp_project}
            gcp_application_default #{gcp_service_account_file}
        }
    }
    EOF
  end
```
