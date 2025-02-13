# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_handler

# related to add actions
property :domain, String
property :dns_verification, String, default: 'tls-dns'
property :log, [true, false], default: true
property :match, [String, Array], default: []
property :content, String
property :reverse_proxy, Hash
property :redirect, String
property :gzip, [true, false], default: true

action_class do
  include AcepCaddy::CaddyHelpers
end

action :add do
  if new_resource.domain.nil?
    new_resource.domain = new_resource.name
  end

  new_resource.name = new_resource.name.gsub(%r{[\*\.\/\:]}, '_')

  content = site(new_resource)
  default_config = default_domain_config

  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:domains] ||= {}
      variables[:domains][new_resource.domain] ||= default_config
      variables[:domains][new_resource.domain][:sites][new_resource.name] = content
      variables[:domains][new_resource.domain][:log] = new_resource.log
    end
  end
end
