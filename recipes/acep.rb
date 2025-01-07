#
# Cookbook:: acep-caddy
# Recipe:: acep
#
# Copyright:: 2025, The Authors, All Rights Reserved.

gcp_service_account_file = '/etc/caddy/gcp_service_account.json'
gcp_service_account_json = chef_vault_item('credentials', node['gcp']['service_account_vault'])

file gcp_service_account_file do
  content gcp_service_account_json['file-content']
  owner node['caddy']['user']
  group node['caddy']['group']
  mode '0700'
  action :create
end

caddy_snippet 'tls-dns' do
  content <<-EOF
  tls {
      dns googleclouddns {
          gcp_project #{node['gcp']['project']}
          gcp_application_default #{gcp_service_account_file}
      }
  }
  EOF
end
