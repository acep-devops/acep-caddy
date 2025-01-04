# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_config

property :user, String, default: 'caddy'
property :group, String, default: 'caddy'

# related to add actions
property :domain, String
property :fqdn, String, name_property: true
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

  site = []
  unless new_resource.content.nil?
    site << new_resource.content
  end

  site << encode_gzip(new_resource.gzip)

  unless new_resource.redirect.nil?
    site << "redir #{new_resource.redirect}"
  end

  unless new_resource.reverse_proxy.nil?
    new_resource.reverse_proxy[:with] ||= []

    if new_resource.reverse_proxy[:skip_verify]
      new_resource.reverse_proxy[:with] << 'https-insecure'
    end

    site << reverse_proxy(new_resource.reverse_proxy)
  end

  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:dns_verify] = new_resource.domain.include? '*'
      variables[:domains] ||= {}
      variables[:domains][new_resource.domain] ||= {}
      variables[:domains][new_resource.domain][new_resource.fqdn] = site.join("\n")
    end
  end
end
