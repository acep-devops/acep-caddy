# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_build

property :plugins, Array, default: []

load_current_value do
  `/usr/bin/caddy list-modules --packages -s`.each_line do |line|
    line.match(%r{github.com/[\w.\-]+/[\w.\-]+}) do |m|
      plugins << m[0]
    end
  end if ::File.exist?('/usr/bin/caddy')
end

action :create do
  build_plugins = new_resource.plugins
  build_plugins << 'github.com/caddy-dns/googleclouddns' unless build_plugins.include?('github.com/caddy-dns/googleclouddns')

  caddy_install 'xcaddy' do 
    repo 'xcaddy'
    action [:add_repo, :install]
  end

  # Need to install golang in order to build the custom caddy binary
  include_recipe 'golang::default'

  # We're building a custom binary for caddy that includes the googleclouddns
  build_cmd = ['xcaddy', 'build', '--output', '/usr/bin/caddy']
  build_plugins.each do |plugin|
    build_cmd << '--with'
    build_cmd << plugin
  end

  execute 'xcaddy_build' do
    command "/usr/bin/bash -l -c \"#{build_cmd.join(' ')}\""
    environment 'GOCACHE' => ::File.join(Chef::Config[:file_cache_path], 'gocache')
  end
end
