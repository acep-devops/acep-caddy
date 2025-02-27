# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_repo

action :add do
  apt_repository "caddy-#{new_resource.name}" do
    uri "https://dl.cloudsmith.io/public/caddy/#{new_resource.name}/deb/ubuntu"
    components ['main']
    key "https://dl.cloudsmith.io/public/caddy/#{new_resource.name}/gpg.key"
    action :add
  end
end

action :remove do
  apt_repository "caddy-#{new_resource.name}" do
    action :remove
  end
end
