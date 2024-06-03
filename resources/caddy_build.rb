# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_build

property :plugins, Array, default: []

load_current_value do 
  `/usr/bin/caddy list-modules --packages -s`.each_line do |line|
    line.match(/github.com\/[\w.\-]+\/[\w.\-]+/) do |m|
      plugins << m[0]
    end
  end if ::File.exists?('/usr/bin/caddy')
end

action :create do 
  build_plugins = new_resource.plugins
  build_plugins << "github.com/caddy-dns/googleclouddns" unless build_plugins.include?("github.com/caddy-dns/googleclouddns")

  apt_repository 'xcaddy' do 
    uri 'https://dl.cloudsmith.io/public/caddy/xcaddy/deb/ubuntu'
    components ['main']
    key 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key'
    action :add
  end

  # Need to install golang in order to build the custom caddy binary
  include_recipe 'golang::default'

  # We're building a custom binary for caddy that includes the googleclouddns
  build_cmd = ["xcaddy", "build", "--output", "/usr/bin/caddy"]
  build_plugins.each do |plugin|
    build_cmd << "--with"
    build_cmd << plugin
  end

  package %w{xcaddy} do
    action :install
  end

  execute 'xcaddy_build' do
    command "/usr/bin/bash -l -c \"#{build_cmd.join(' ')}\""
  end
end