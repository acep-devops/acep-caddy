# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_config
provides :caddy_site

property :user, String, default: 'caddy'
property :group, String, default: 'caddy'

# related to add actions
property :domain, String
property :fqdn, String, required: true
property :match, Array, default: []
property :content, String
property :reverse_proxy, Hash
property :redirect, String
property :gzip, [true, false], default: true

action_class do
  include AcepCaddy::CaddyHelpers
end

action :add do
  if new_resource.domain.nil?
    new_resource.domain = new_resource.fqdn
  end
  
  content = site(new_resource)

  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:dns_verify] = new_resource.domain.include? '*'
      variables[:domains] ||= {}
      variables[:domains][new_resource.domain] ||= {}
      variables[:domains][new_resource.domain][new_resource.name] = content
    end
  end
end
