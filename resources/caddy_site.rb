# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_site

# related to add actions
property :dns_verification, String
property :content, Array, default: []

action :add do
  import_verify = "import #{new_resource.dns_verification}"
  new_resource.content << import_verify

  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:domains] ||= {}
      variables[:domains][new_resource.name] ||= { content: [], sites: {} }
      variables[:domains][new_resource.name][:content] += new_resource.extras
      variables[:domains][new_resource.name][:content].uniq!
    end
  end
end

