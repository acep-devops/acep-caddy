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

action :add do
  if new_resource.domain.nil?
    new_resource.domain = new_resource.name
  end

  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:dns_verify] = new_resource.domain.include? '*'
      variables[:domains] ||= {}
      variables[:domains][new_resource.domain] ||= {}

      site = []
      unless new_resource.content.nil?
        site << new_resource.content
      end

      site << 'encode gzip' if new_resource.gzip

      unless new_resource.reverse_proxy.nil?
        site << <<-EOF
        reverse_proxy #{new_resource.reverse_proxy[:to]} {
          #{new_resource.reverse_proxy[:skip_verify] ? 'import https-insecure' : ''}
        }
        EOF
      end

      unless new_resource.redirect.nil?
        site << "redir #{new_resource.redirect}"
      end
      variables[:domains][new_resource.domain][new_resource.fqdn] = site.join("\n")
    end
  end
end
