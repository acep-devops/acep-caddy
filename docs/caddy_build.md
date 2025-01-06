## caddy_build

Build custom caddy executable. This may be needed to install caddy with any special plugins

## Properties

|Name   |Type       |Default             |Description                        |
|-------|-----------|--------------------|-----------------------------------|
|plugins|Array      |`['github.com/caddy-dns/googleclouddns']`|List of plugins to use when building caddy.|

## Examples

```ruby

caddy_build 'install' do 
    plugins 'github.com/caddy-dns/googleclouddns'
end
