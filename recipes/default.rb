#
# Cookbook:: acep-caddy
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.

if ubuntu_platform?
    include_recipe 'acep-caddy::ubuntu'
end

directory '/etc/caddy' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

service 'caddy' do 
    action :enable
end

#   item = ChefVault::Item.load("credentials", "gcp_service_account_json")
#   log item

gcp_json = chef_vault_item('credentials', 'gcp_service_account_json')

file '/etc/caddy/gcp_service_account.json' do
    content gcp_json["file-content"]
    owner 'caddy'
    group 'root'
    mode '0700'
    action :create
    notifies :restart, 'service[caddy]', :delayed
end

template '/etc/caddy/Caddyfile' do
    source 'Caddyfile.erb'
    owner 'caddy'
    group 'root'
    mode '0700'
    variables acme_email: "uaf-acep-ci@alaska.edu",
        proxy_domain: '*.lab.acep.uaf.edu',
        gcp_project: 'clound-dns-321021',
        gcp_service_account_file: '/etc/caddy/gcp_service_account.json',
        sites: [{
            name: "test",
            fqdn: "test.camio.lab.acep.uaf.edu",
            upstream: "http://localhost:8080",
            self_signed: false
        }]
    action :create
    notifies :run, 'execute[caddy_fmt]', :immediately
    notifies :restart, 'service[caddy]', :delayed
end

execute 'caddy_fmt' do 
    command 'caddy fmt /etc/caddy/Caddyfile --overwrite'
    action :nothing
end