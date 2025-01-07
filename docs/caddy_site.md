## caddy_site

Manages site level configuration

## Properties

|Name            |Type       |Default   |Description                                          |
|----------------|-----------|----------|-----------------------------------------------------|
|dns_verification|string     |          |Set the snippet name to use for dns verification for the site|
|content         |Array      |          |Array of configuration lines to add to at the site level|
## Examples

```ruby
caddy_site '*.camio.acep.uaf.edu' do 
  dns_verification 'tls-dns'
end
```
