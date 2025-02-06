# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_site

# related to add actions
property :dns_verification, String
property :log, [true, false], default: true
property :content, Array, default: []

action_class do
  include AcepCaddy::CaddyHelpers
end

action :add do
  import_verify = "import #{new_resource.dns_verification}"
  new_resource.content << import_verify
  
  default_config = default_domain_config

  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:domains] ||= {}
      variables[:domains][new_resource.name] ||= default_config
      variables[:domains][new_resource.name][:content] += new_resource.content
      variables[:domains][new_resource.name][:content].uniq!
      variables[:domains][new_resource.name][:log] = new_resource.log
    end
  end
end
