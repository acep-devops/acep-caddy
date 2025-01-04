#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#

module AcepCaddy
  module CaddyHelpers
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
