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

gcp_json = chef_vault_item('credentials', node['gcp']['service_account_vault'])
caddy_service 'caddy' do
  acme_staging true
  acme_staging_url 'https://localhost:14000/dir'
  acme_ca_root '/etc/ssl/certs/pebble.minica.pem'
  acme_email node['caddy']['acme_email']
  gcp_project node['gcp']['project']
  gcp_service_account_json gcp_json['file-content']

  action [:install, :enable, :start]
end

caddy_config 'hello.lab.acep.uaf.edu' do
  content <<-EOF
respond "Hello, World!"
    EOF
  action :add
end

caddy_config 'test.lab.acep.uaf.edu' do
  reverse_proxy to: 'localhost:8080', skip_verify: true
  action :add
end

caddy_config 'psi.lab.acep.uaf.edu' do
  redirect 'https://www.uaf.edu/acep/research/power-systems-integration.php'
  action :add
end

caddy_config 'foo.camio.acep.uaf.edu' do
  domain '*.camio.acep.uaf.edu'
  content <<-EOF
    respond "Hello, Camio!"
  EOF
end
