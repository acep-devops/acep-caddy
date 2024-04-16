#
# Cookbook:: acep-caddy
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.

if ubuntu_platform?
    include_recipe 'acep-caddy::ubuntu'
end

service 'caddy' do 
    action :enable
end

caddy_config = data_bag_item('caddy', node['caddy']['sites_data_bag'])
gcp_json = chef_vault_item('credentials', node['gcp']['service_account_vault'])

file node['gcp']['service_account_json'] do
    content gcp_json["file-content"]
    owner node['caddy']['user']
    group node['caddy']['group']
    mode '0700'
    action :create
    notifies :restart, 'service[caddy]', :delayed
end

template '/etc/caddy/Caddyfile' do
    source 'Caddyfile.erb'
    owner node['caddy']['user']
    group node['caddy']['group']
    mode '0700'
    variables acme_email: node['caddy']['acme_email'], 
        wildcard_domain: caddy_config[:wildcard_domain],
        gcp_project: caddy_config[:gcp_project],
        gcp_service_account_file: node['gcp']['service_account_json'], 
        sites: caddy_config[:sites]
    action :create
    # notifies :run, 'execute[caddy_fmt]', :immediately
    notifies :restart, 'service[caddy]', :delayed
end

# Take out fmt cause it will change the template config and cause chef
# To always update the config and restart caddy service

# execute 'caddy_fmt' do 
#     command 'caddy fmt /etc/caddy/Caddyfile --overwrite'
#     action :nothing
# end