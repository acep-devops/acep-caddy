## caddy_handler

Site handler configuration accumulator, 

## Properties

|Name   |Type       |Default             |Description                        |
|-------|-----------|--------------------|-----------------------------------|
|domain|String||Domain used for SSL verification, used when specifying wildcard domains, otherwise uses the FQDN.
|fqdn|String||FQDN used to match client requests
|match|Array|`[]`|Additional match options used for matching requests. See [Caddy Request Matchers](https://caddyserver.com/docs/caddyfile/matchers)
|content|String||Content block to provide completely custom config block for site. Overrides any other config specificed.
|reverse_proxy|Hash||Configure basic reverse_proxy setting. See more info below.
|redirect|String||URL to redirect requests to see more info below
|gzip|true,false|true|Enable gzip compression for site requests

### `reverse_proxy`

Configure simple reverse proxy for site

|Name  |Type       |Description                                             |
|------|-----------|--------------------------------------------------------|
|to    | string    | Space seperated list of upstream hosts.                |
|with  | Array     | Any snippets to import into the request, useful when upstream hosts use self-signed cerificates and using `https-insecure` snippet. |
|extra | String    | Additional config that should be included as part of the reverse proxy handling |

### `redirect`

Configure simple url redirects

## Examples

```ruby
caddy_site 'hello_test' do
  fqdn 'hello.lab.acep.uaf.edu'
  match ['path /test']
  content <<-EOF
respond "Hello test!"
    EOF
  action :add
end

caddy_site 'hello' do
  fqdn 'hello.lab.acep.uaf.edu'
  content <<-EOF
respond "Hello World!"
    EOF
  action :add
end

caddy_site 'test' do
  fqdn 'test.lab.acep.uaf.edu'
  reverse_proxy to: 'localhost:8080', with: ['https-insecure']
  action :add
end

caddy_site 'psi' do 
  fqdn 'psi.lab.acep.uaf.edu'
  redirect 'https://www.uaf.edu/acep/research/power-systems-integration.php'
  action :add
end
```
