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

caddy_sites = data_bag_item('caddy', node['caddy']['sites_data_bag'])[:sites]
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
        wildcard_domain: node['caddy']['wildcard_domain'],
        gcp_project: node['gcp']['project'],
        gcp_service_account_file: node['gcp']['service_account_json'], 
        sites: caddy_sites
    action :create
    notifies :run, 'execute[caddy_fmt]', :immediately
    notifies :restart, 'service[caddy]', :delayed
end

execute 'caddy_fmt' do 
    command 'caddy fmt /etc/caddy/Caddyfile --overwrite'
    action :nothing
end