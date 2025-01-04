# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode true

provides :caddy_snippet

property :content, String

action :add do
  with_run_context :root do
    edit_resource(:template, '/etc/caddy/Caddyfile') do |new_resource|
      variables[:snippets] ||= {}
      variables[:snippets][new_resource.name] = new_resource.content
    end
  end
end
