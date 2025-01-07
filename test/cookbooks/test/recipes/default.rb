#
# Cookbook:: test
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.
include_recipe '::pebble'

caddy_build 'caddy' do
end

execute 'cp /etc/pebble/certs/pebble.minica.pem /etc/ssl/certs/pebble.minica.pem'
file '/etc/ssl/certs/pebble.minica.pem' do
  mode '0644'
end

caddy_service 'caddy' do
  acme_staging true
  acme_staging_url 'https://localhost:14000/dir'
  acme_ca_root '/etc/ssl/certs/pebble.minica.pem'
  acme_email 'test@test.com'
  action [:install, :enable, :start]
end

caddy_handler 'hello_test' do
  fqdn 'hello.lab.acep.uaf.edu'
  match ['path /test']
  content <<-EOF
respond "Hello test!"
    EOF
  action :add
end

caddy_handler 'hello' do
  fqdn 'hello.lab.acep.uaf.edu'
  content <<-EOF
respond "Hello World!"
    EOF
  action :add
end

caddy_handler 'test.lab.acep.uaf.edu' do
  reverse_proxy to: 'localhost:9443', with: ['https-insecure']
  action :add
end

caddy_handler 'psi.lab.acep.uaf.edu' do
  redirect 'https://www.uaf.edu/acep/research/power-systems-integration.php'
  action :add
end

caddy_site '*.camio.acep.uaf.edu' do
  dns_verification 'tls-dns'
end

caddy_handler 'foo' do
  domain '*.camio.acep.uaf.edu'
  fqdn 'foo.camio.acep.uaf.edu'
  content <<-EOF
    respond "Hello, Camio!"
  EOF
end
