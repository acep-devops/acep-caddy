# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_install

action :install do
  package new_resource.name do
    action :install
  end
end
