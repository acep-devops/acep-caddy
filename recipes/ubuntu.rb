#
# Cookbook:: acep-caddy
# Recipe:: debian
#
# Copyright:: 2024, The Authors, All Rights Reserved.

# If we are just using stock caddy then we could use the following
# apt_repository 'caddy' do
#     uri 'https://dl.cloudsmith.io/public/caddy/stable/deb/ubuntu'
#     components ['main']
#     key 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key'
#     action :add
# end

apt_repository 'xcaddy' do
  uri 'https://dl.cloudsmith.io/public/caddy/xcaddy/deb/ubuntu'
  components ['main']
  key 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key'
  action :add
end

# Need to install golang in order to build the custom caddy binary
include_recipe 'golang::default'
package %w(xcaddy) do
  action :install
  notifies :run, 'execute[xcaddy_build]', :immediately
end

# We're building a custom binary for caddy that includes the googleclouddns
# TODO: Create a resource for this
execute 'xcaddy_build' do
  command '/usr/bin/bash -l -c "xcaddy build --with github.com/caddy-dns/googleclouddns --output /usr/bin/caddy"'
  action :nothing
end

######################
# These items are not needed if we are using the stock caddy
######################

group node['caddy']['group'] do
  action :create
  system true
end

user node['caddy']['user'] do
  group node['caddy']['group']
  manage_home true
  home '/var/lib/caddy'
  system true
  shell '/bin/false'
  action [:create, :manage]
end

directory '/etc/caddy' do
  owner node['caddy']['user']
  group node['caddy']['group']
  mode '0755'
  action :create
end

directory '/var/lib/caddy' do
  owner 'caddy'
  group 'caddy'
  mode '0750'
  action :create
end

systemd_unit 'caddy.service' do
  content({
      Unit: {
          Description: 'Caddy HTTP/2 web server',
          Documentation: 'https://caddyserver.com/docs/',
          After: 'network.target network-online.target',
          Wants: 'network-online.target',
      },
      Service: {
          ExecStart: '/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile',
          ExecReload: '/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force',
          Restart: 'on-abnormal',
          LimitNOFILE: 1048576,
          Type: 'notify',
          User: 'caddy',
          Group: 'caddy',
          TimeoutStopSec: '5s',
          PrivateTmp: true,
          ProtectSystem: 'full',
          AmbientCapabilities: 'CAP_NET_ADMIN CAP_NET_BIND_SERVICE',
      },
      Install: {
          WantedBy: 'multi-user.target',
      },
  })
  action [:create, :enable]
end
