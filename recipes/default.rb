#
# Cookbook:: acep-caddy
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.

caddy_build 'caddy' do 
end

caddy_service 'caddy' do 
    action [:install, :enable]
    delayed_action :start
end

gcp_json = chef_vault_item('credentials', node['gcp']['service_account_vault'])

caddy_config 'default' do 
    acme_staging true
    acme_email node['caddy']['acme_email']
    gcp_project node['gcp']['project']
    gcp_service_account_json gcp_json['file-content']
    action :create
end

caddy_config 'hello.lab.acep.uaf.edu' do
    domain '*.lab.acep.uaf.edu'
    content <<-EOF
encode gzip
respond "Hello, World!"
    EOF
    action :add
end

# Take out fmt cause it will change the template config and cause chef
# To always update the config and restart caddy service

# execute 'caddy_fmt' do 
#     command 'caddy fmt /etc/caddy/Caddyfile --overwrite'
#     action :nothing
# end