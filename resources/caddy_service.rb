# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
provides :caddy_service
unified_mode true

property :user, String, default: 'caddy'
property :group, String, default: 'caddy'

property :cookbook, String, default: 'acep-caddy'
property :source, String, default: 'Caddyfile_resource.erb'

property :acme_email, String
property :acme_staging, [true, false], default: false
property :acme_staging_url, String, default: 'https://acme-staging-v02.api.letsencrypt.org/directory'
property :acme_ca_root, String
property :gcp_project, String
property :gcp_service_account_json, String

action :install do
  group new_resource.group do
    action :create
    system true
  end

  user new_resource.user do
    group new_resource.group
    manage_home true
    home '/var/lib/caddy'
    system true
    shell '/bin/false'
    action [:create, :manage]
  end

  directory '/etc/caddy' do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    action :create
  end

  directory '/var/lib/caddy' do
    owner new_resource.user
    group new_resource.group
    mode '0750'
    action :create
  end

  gcp_service_account_file = '/etc/caddy/gcp_service_account.json'

  file gcp_service_account_file do
    content new_resource.gcp_service_account_json
    owner new_resource.user
    group new_resource.group
    mode '0700'
    action :create
    notifies :reload, 'service[caddy]', :delayed
  end

  with_run_context :root do
    service 'caddy' do
      supports status: true, restart: true, reload: true
      action :nothing
    end

    template '/etc/caddy/Caddyfile' do
      cookbook new_resource.cookbook
      source new_resource.source
      owner new_resource.user
      group new_resource.group
      mode '0700'
      variables({
          domains: {},
          snippets: {},
          acme_email: new_resource.acme_email,
          acme_staging: new_resource.acme_staging,
          acme_staging_url: new_resource.acme_staging_url,
          acme_ca_root: new_resource.acme_ca_root
      })
      action :nothing
      delayed_action :create
      notifies :restart, 'service[caddy]', :delayed
    end
  end

  caddy_snippet 'https-insecure' do
    content <<-EOF
    transport http {
      tls
      tls_insecure_skip_verify
    }
    EOF
  end

  caddy_snippet 'tls-dns' do
    content <<-EOF
    tls {
        dns googleclouddns {
            gcp_project #{new_resource.gcp_project}
            gcp_application_default #{gcp_service_account_file}
        }
    }
    EOF
  end

  systemd_unit 'caddy.service' do
    content({
        Unit: {
            Description: 'Caddy HTTP/2 web server',
            Documentation: 'https://caddyserver.com/docs/',
            After: 'network.target network-online.target',
            Wants: 'network-online.target',
        },
        Service: {
            ExecStart: '/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile',
            ExecReload: '/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force',
            Restart: 'on-abnormal',
            LimitNOFILE: 1048576,
            Type: 'notify',
            User: 'caddy',
            Group: 'caddy',
            TimeoutStopSec: '5s',
            PrivateTmp: true,
            ProtectSystem: 'full',
            AmbientCapabilities: 'CAP_NET_ADMIN CAP_NET_BIND_SERVICE',
        },
        Install: {
            WantedBy: 'multi-user.target',
        },
    })
    action [:create]
  end
end

action_class do
  def do_service_action(resource_action)
    with_run_context :root do
      declare_resource(:service, 'caddy').delayed_action(resource_action)
    end
  end
end

%i(start stop restart reload enable disable).each do |action_type|
  send(:action, action_type) { do_service_action(action_type) }
end
