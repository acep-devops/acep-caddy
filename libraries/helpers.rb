#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#

module AcepCaddy
  module CaddyHelpers
    def default_domain_config
      {
        content: [],
        sites: {},
        log: true,
      }
    end

    def snippet_includes(items)
      items.map { |item| "import #{item}" }.join("\n")
    end

    def reverse_proxy(config)
      <<-EOF
      reverse_proxy #{config[:to]} {
        #{snippet_includes(config[:with])}
        #{config[:extra]}
      }
      EOF
    end

    def encode_gzip(enabled)
      'encode gzip' if enabled
    end

    def site_match(name, resource)
      if resource.match.is_a?(String)
        resource.match = [resource.match]
      end

      <<-EOF
@#{name} {
  #{resource.match.join("\n")}
}
      EOF
    end

    def site(resource)
      content = []

      name = resource.name.gsub('.', '_')

      content << encode_gzip(resource.gzip)
      unless resource.content.nil?
        content << resource.content
      end

      unless resource.reverse_proxy.nil?
        resource.reverse_proxy[:with] ||= []
        resource.reverse_proxy[:with] << 'https-insecure' if resource.reverse_proxy[:skip_verify]
        content << reverse_proxy(resource.reverse_proxy)
      end

      unless resource.redirect.nil?
        content << "redir #{resource.redirect}"
      end

      <<-EOF
#{site_match(name, resource)}
handle @#{name} {
  #{content.join("\n")}
}
      EOF
    end
  end
end

#
# The module you have defined may be extended within the recipe to grant the
# recipe the helper methods you define.
#
# Within your recipe you would write:
#
#     extend AcepCaddy::CaddyHelpers
#
#     my_helper_method
#
# You may also add this to a single resource within a recipe:
#
#     template '/etc/app.conf' do
#       extend AcepCaddy::CaddyHelpers
#       variables specific_key: my_helper_method
#     end
#
