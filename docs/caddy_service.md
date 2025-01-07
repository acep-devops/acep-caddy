## caddy_service

Manages global configuration for caddy service

## Properties

|Name   |Type       |Default             |Description                        |
|-------|-----------|--------------------|-----------------------------------|
|user|string|
|group|string|
|cookbook|string|
|source|string|
|acme_email|string|
|acme_staging|true,false|
|acme_staging_url|string|
|acme_ca_root|string|

## Examples

```ruby
caddy_service 'caddy' do
  acme_staging true
  acme_staging_url 'https://localhost:14000/dir'
  acme_ca_root '/etc/ssl/certs/pebble.minica.pem'
  acme_email 'test@test.com'
  action [:install, :enable, :start]
end
```
