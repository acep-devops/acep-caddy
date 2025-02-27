# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_install

property :repo, String, default: 'stable'
property :package, String, name_property: true

action :add_repo do
  apt_repository "caddy-#{new_resource.repo}" do
    uri "https://dl.cloudsmith.io/public/caddy/#{new_resource.repo}/deb/ubuntu"
    components ['main']
    key "https://dl.cloudsmith.io/public/caddy/#{new_resource.repo}/gpg.key"
    action :add
  end
end

action :install do
  package new_resource.package do
    action :install
  end
end
